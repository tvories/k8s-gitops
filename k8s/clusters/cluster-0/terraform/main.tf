#TODO: Move all cluster-0 terraform to this dir?

terraform {
  backend "gcs" {
    bucket      = "tvo-homelab-tfstate"
    prefix      = "terraform/state/talos-cluster-0"
    credentials = "/mnt/c/Users/taylor/gits/homelab/terraform/keys/terraform.json"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.19.0"
    }
  }
}

# ## Infra
# provider "vsphere" {
#   vsphere_server = var.vsphere_vcenter
#   user           = var.vsphere_user
#   password       = var.vsphere_password

#   allow_unverified_ssl = "true"
# }

# data "terraform_remote_state" "vcenter" {
#   backend = "gcs"
#   config = {
#     bucket      = "tvo-homelab-tfstate"
#     prefix      = "terraform/state/vsphere"
#     credentials = "/mnt/c/Users/taylor/gits/homelab/terraform/keys/terraform.json"
#   }
# }

# data "vsphere_datacenter" "dc" {
#   name = "Home"
# }
# data "vsphere_resource_pool" "resource_pool" {
#   name          = "Resources"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }
# data "vsphere_network" "network" {
#   datacenter_id = data.vsphere_datacenter.dc.id
#   name          = "VLAN 80 - K8s"
# }
# data "vsphere_datastore" "datastore" {
#   name          = "SATAStorage"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }
# data "vsphere_host" "host" {
#   datacenter_id = data.vsphere_datacenter.dc.id
#   name          = "esx4.mcbadass.local"
# }

# resource "vsphere_virtual_machine" "talos-cp" {
#   count                      = var.controlplane_instances
#   name                       = "talos-cp-${count.index + 1}"
#   resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
#   datastore_id               = data.vsphere_datastore.datastore.id
#   datacenter_id              = data.vsphere_datacenter.dc.id
#   wait_for_guest_net_timeout = -1
#   host_system_id             = data.vsphere_host.host.id
#   num_cpus                   = "8"
#   memory                     = var.cp_memory
#   folder                     = "k8"
#   # firmware = "efi"


#   ovf_deploy {
#     remote_ovf_url    = var.ovf_url
#     disk_provisioning = "thin"
#   }

#   disk {
#     label = "talos-cp-${count.index + 1}-disk0"
#     size  = "80"
#   }

#   disk {
#     label       = "talos-cp-${count.index + 1}-disk1"
#     size        = "500"
#     unit_number = 1
#   }

#   network_interface {
#     network_id     = data.vsphere_network.network.id
#     adapter_type   = "vmxnet3"
#     mac_address    = "00:50:56:ab:f1:3${count.index}"
#     use_static_mac = true
#   }

#   lifecycle {
#     ignore_changes = [
#       disk[0].io_share_count,
#       disk[0].thin_provisioned,
#       disk[1].io_share_count,
#       disk[1].io_share_count,
#       ovf_deploy,
#       tags,
#       extra_config_reboot_required
#     ]
#   }
# }

# resource "vsphere_virtual_machine" "talos-worker" {
#   count                      = var.worker_instances
#   name                       = "talos-worker-${count.index + 1}"
#   resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
#   datastore_id               = data.vsphere_datastore.datastore.id
#   datacenter_id              = data.vsphere_datacenter.dc.id
#   wait_for_guest_net_timeout = -1
#   host_system_id             = data.vsphere_host.host.id
#   num_cpus                   = "8"
#   memory                     = var.worker_memory
#   folder                     = "k8"
#   # firmware = "efi"


#   ovf_deploy {
#     remote_ovf_url    = var.ovf_url
#     disk_provisioning = "thin"
#   }

#   disk {
#     label = "talos-worker-${count.index + 1}-disk0"
#     size  = "30"
#   }

#   disk {
#     label       = "talos-worker-${count.index + 1}-disk1"
#     size        = "200"
#     unit_number = 1
#   }

#   network_interface {
#     network_id     = data.vsphere_network.network.id
#     adapter_type   = "vmxnet3"
#     mac_address    = "00:50:56:ab:f1:4${count.index}"
#     use_static_mac = true
#   }

#   lifecycle {
#     ignore_changes = [
#       disk[0].io_share_count,
#       disk[0].thin_provisioned,
#       disk[1].io_share_count,
#       disk[1].io_share_count,
#       ovf_deploy
#     ]
#   }
# }
