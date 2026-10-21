# Terraform

One directory per technology. Each directory is its own root with its own
state in GCS (`gs://tvo-homelab-tfstate/terraform/state/<root>`), so a broken
service (a sealed Vault, Authentik down) never blocks planning anything else —
in particular OPNsense and Technitium, which have to work when the cluster
doesn't.

| Root | Manages | Provider |
|---|---|---|
| `authentik/` | applications, providers, flows, LDAP | goauthentik/authentik |
| `cloudflared/` | tunnel, Access apps and policies, DNS record | cloudflare/cloudflare |
| `external-dns/` | scoped Cloudflare API token for external-dns | cloudflare/cloudflare |
| `opnsense/` | firewall rules, NAT, aliases | browningluke/opnsense |
| `rustfs/` | GitLab's S3 bucket | hashicorp/aws |
| `technitium/` | DNS zones and records, DHCP scopes and reservations | darkhonor/technitium |
| `vault/` | auth backends, policies, engines | hashicorp/vault |

## Usage

```sh
just tf roots              # list roots
just tf init opnsense      # first time, or after a provider bump (-upgrade)
just tf plan opnsense
just tf apply opnsense
just tf run vault state list
just tf check              # fmt + validate everything, no credentials needed
```

## Secrets

Each root reads credentials from environment variables. `.env_vars` holds
`op://` references only — never a literal — and `just tf` resolves them with
`op run` for the length of the command. Prefer provider env vars
(`OPNSENSE_API_KEY`, `TECHNITIUM_TOKEN`, …) or `TF_VAR_<name>` over `.tfvars`.

## Adding a root

1. `mkdir terraform/<name>` and add `versions.tf` with a `gcs` backend whose
   prefix is `terraform/state/<name>`.
2. Put credentials in 1Password and reference them from `<name>/.env_vars`.
3. `just tf init <name>`.

Moving a root between directories needs no state work — state lives at the
bucket prefix, not the path. A root on local state moves into GCS once with
`just tf init <name> -migrate-state`.

## Technitium provider

`darkhonor/technitium` from the registry. It replaced `kenske/technitium`
(no releases since 0.2.2, DHCP scope options only in an unmerged PR, which
needed a `dev_overrides` build). Things to know:

- `technitium_dhcp_scope.enabled` defaults to **false** — every scope sets
  `enabled = true` explicitly, or a plan would disable DHCP.
- Reserved-lease MACs are validated; AD-exported client identifiers and
  placeholders are rejected (two were dropped, see `dhcp-reservations.tf`).
- STIG compliance validation exists but is opt-in (`stig_compliance` block in
  the provider); not enabled.
- Import IDs: zone `<name>`, record `<zone>::<fqdn>::<type>::<value>`, scope
  `<name>`, reserved lease `<scope>::<MAC>`.
