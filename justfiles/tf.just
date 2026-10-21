# Terraform roots under terraform/. One root = one directory = one GCS state
# prefix. Secrets come from each root's .env_vars (op:// references only),
# resolved by `op run` for the duration of the command.
#
#   just tf plan opnsense
#   just tf apply authentik
#   just tf run vault state list

# Modules don't inherit the root justfile's settings.
set quiet
set shell := ['bash', '-euo', 'pipefail', '-c']

tf_dir := source_directory() / ".." / "terraform"

[private]
default:
    @just --list tf

[doc('List Terraform roots')]
roots:
    find "{{ tf_dir }}" -mindepth 2 -maxdepth 2 -name '*.tf' -printf '%h\n' | xargs -n1 basename | sort -u | grep -vx modules

[doc('terraform init (pass -upgrade or -migrate-state as extra args)')]
init root *args:
    just tf run "{{ root }}" init {{ args }}

[doc('terraform plan')]
plan root *args:
    just tf run "{{ root }}" plan {{ args }}

[doc('terraform apply')]
apply root *args:
    just tf run "{{ root }}" apply {{ args }}

[doc('fmt + validate every root (no credentials needed)')]
check:
    #!/usr/bin/env bash
    set -uo pipefail
    failed=()
    terraform -chdir="{{ tf_dir }}" fmt -recursive -check || failed+=(fmt)
    for d in $(just tf roots); do
      printf '%-14s ' "$d"
      # Separate data dir: the root's own .terraform holds backend config, which
      # would make validation need GCS credentials.
      export TF_DATA_DIR="{{ tf_dir }}/.check/$d"
      if out=$(terraform -chdir="{{ tf_dir }}/$d" init -backend=false -input=false -no-color 2>&1 >/dev/null \
               && terraform -chdir="{{ tf_dir }}/$d" validate -no-color 2>&1); then
        echo ok
      else
        echo FAILED; echo "$out" | grep -E 'Error|│' | sed 's/^/    /' | head -8; failed+=("$d")
      fi
    done
    (( ${#failed[@]} == 0 )) || { echo "failed: ${failed[*]}"; exit 1; }

# Any terraform subcommand, with the root's secrets in the environment.
[doc('Run any terraform subcommand in a root')]
run root +args:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="{{ tf_dir }}/{{ root }}"
    [[ -d "$dir" ]] || { echo "no such root: {{ root }} (see: just tf roots)" >&2; exit 1; }
    if [[ -f "$dir/.env_vars" ]]; then
      exec op run --env-file="$dir/.env_vars" -- terraform -chdir="$dir" {{ args }}
    else
      exec terraform -chdir="$dir" {{ args }}
    fi
