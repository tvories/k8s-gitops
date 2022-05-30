packer {
  required_version = ">= 1.7.9"
  required_plugins {
    vsphere = {
      version = " >= v1.0.3"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

# assumes you have already imported the cloud image for ubuntu
# https://cloud-images.ubuntu.com/

source "vsphere-clone" "sidero" {
  vcenter_server = var.vsphere_server
  username = var.vsphere_username
  password = var.vsphere_password
  insecure_connection = var.vsphere_insecure_cert
  cluster = var.vsphere_cluster
  datacenter = var.vsphere_datacenter
  # host = var.vsphere_host
  datastore = var.vsphere_datastore
  convert_to_template = true
  folder = var.vsphere_folder

  ip_wait_timeout = "120m"
  communicator = "ssh"
  ssh_username = var.connection_username
  ssh_password = var.connection_password
  # ssh_timeout = "1hr"
  ssh_port = "22"
  ssh_handshake_attempts = "100"
  shutdown_timeout = "15m"
  vm_name = "sidero-packer"
  template = "ubuntu-focal-20.04-cloudimg"
  # the vapp properties allow us to set a username and password on first boot
  vapp {
    properties = {
      hostname  = "sidero-packer"
      user-data = base64encode(file("./data/user-data"))
      # meta-data = file("${abspath(path.root)}/data/meta-data")
    }
  }
}

build {
  sources = [
    "source.vsphere-clone.sidero"
  ]
  provisioner "ansible" {
    playbook_file = "./pb-sidero.yaml"
    user = var.connection_username
    extra_arguments = ["--extra-vars", "ansible_ssh_pass=${var.connection_password} ansible_user_key='${var.ansible_user_key}' ansible_username=${var.ansible_username}"]
  }
  provisioner "shell" {
      execute_command = "echo '${var.connection_password}' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
      scripts = [
          "scripts/cleanup.sh",
          # "scripts/ubuntu-prep.sh",
          "scripts/clean-ssh-hostkeys.sh"
      ]
    }
}
