terraform {
  backend "gcs" {
    bucket      = "tvo-homelab-tfstate"
    prefix      = "terraform/state/talos-cluster-test"
    credentials = "/mnt/c/Users/taylor/gits/homelab/terraform/keys/terraform.json"
  }
  required_providers {
    vsphere = {
      version = "2.3.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.54.0"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_vcenter
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = "true"
}

data "vsphere_datacenter" "dc" {
  name = "Home"
}
data "vsphere_resource_pool" "resource_pool" {
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  datacenter_id = data.vsphere_datacenter.dc.id
  name          = "VLAN 80 - K8s"
}
data "vsphere_datastore" "datastore" {
  name          = "SATAStorage"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "host" {
  datacenter_id = data.vsphere_datacenter.dc.id
  name          = "esx4.mcbadass.local"
}

resource "vsphere_virtual_machine" "talos-cp" {
  count                      = var.controlplane_instances
  name                       = "${var.name_prefix}-cp-${count.index + 1}"
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.dc.id
  wait_for_guest_net_timeout = -1
  host_system_id             = data.vsphere_host.host.id
  num_cpus                   = "4"
  memory                     = 8192
  folder                     = "k8/talos-test"
  # firmware = "efi"


  ovf_deploy {
    remote_ovf_url    = var.ovf_url
    disk_provisioning = "thin"
  }

  disk {
    label = "${var.name_prefix}-cp-${count.index + 1}-disk0"
    size  = "30"
  }

  disk {
    label       = "${var.name_prefix}-cp-${count.index + 1}-disk1"
    size        = "40"
    unit_number = 1
  }

  network_interface {
    network_id     = data.vsphere_network.network.id
    adapter_type   = "vmxnet3"
    mac_address    = "00:50:56:ab:f1:5${count.index}"
    use_static_mac = true
  }

  lifecycle {
    ignore_changes = [
      disk[0].io_share_count,
      disk[0].thin_provisioned,
      disk[1].io_share_count,
      disk[1].io_share_count,
      ovf_deploy
    ]
  }
}

resource "vsphere_virtual_machine" "talos-worker" {
  count                      = var.worker_instances
  name                       = "${var.name_prefix}-worker-${count.index + 1}"
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  datacenter_id              = data.vsphere_datacenter.dc.id
  wait_for_guest_net_timeout = -1
  host_system_id             = data.vsphere_host.host.id
  num_cpus                   = "8"
  memory                     = 12288
  folder                     = "k8/talos-test"
  # firmware = "efi"


  ovf_deploy {
    remote_ovf_url    = var.ovf_url
    disk_provisioning = "thin"
  }

  disk {
    label = "${var.name_prefix}-worker-${count.index + 1}-disk0"
    size  = "30"
  }

  disk {
    label       = "${var.name_prefix}-worker-${count.index + 1}-disk1"
    size        = "100"
    unit_number = 1
  }

  network_interface {
    network_id     = data.vsphere_network.network.id
    adapter_type   = "vmxnet3"
    mac_address    = "00:50:56:ab:f1:6${count.index}"
    use_static_mac = true
  }

  lifecycle {
    ignore_changes = [
      disk[0].io_share_count,
      disk[0].thin_provisioned,
      disk[1].io_share_count,
      disk[1].io_share_count,
      ovf_deploy
    ]
  }
}
