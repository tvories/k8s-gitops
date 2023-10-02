terraform {
  backend "gcs" { }
  required_providers {
    vsphere = {
      version = "2.4.3"
    }
    dns = {
      source = "hashicorp/dns"
      version = "3.3.2"
    }
  }
}

provider "vsphere" {
  vsphere_server = var.vsphere_vcenter
  user           = var.vsphere_user
  password       = var.vsphere_password

  allow_unverified_ssl = "true"
}

provider "dns" {
  update {
    server = var.dns_server # Using the hostname is important in order for an SPN to match
  }
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}
data "vsphere_datastore" "datastore" {
  name = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "cluster" {
  name = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_tag_category" "ansible" {
  name = "ansible"
}
data "vsphere_tag" "debian" {
  name = "debian"
  category_id = data.vsphere_tag_category.ansible.id
}
data "vsphere_virtual_machine" "template" {
  name = "sidero-packer"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create a vSphere VM in the folder #
resource "vsphere_virtual_machine" "sidero" {
  # VM placement #
  name             = var.instance_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder
  tags             = [data.vsphere_tag.debian.id]

  # VM resources #
  num_cpus = 2
  memory   = 4096

  # Guest OS #
  guest_id = data.vsphere_virtual_machine.template.guest_id

  # VM storage #
  disk {
    label            = "${var.instance_name}.vmdk"
    size             = 40
    thin_provisioned = true
    # eagerly_scrub    = data.terraform_remote_state.vcenter.outputs.ubuntu_2104_template.disks[0].eagerly_scrub
  }

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  # VM networking #
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  # Customization of the VM #
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
  cdrom {
    client_device = true
  }

  vapp {
    # Cleans up vapp properties from packer run
    properties = null
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(templatefile("${path.module}/metadata.tpl",{
      hostname = var.instance_name
      ip_address = var.ip_address
      gateway = var.gateway
      nameservers = var.nameservers
      instance_id = var.instance_id
      search_domains = var.search_domains
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(file("${path.module}/userdata.tpl"))
    "guestinfo.userdata.encoding" = "base64"
  }

    lifecycle {
    ignore_changes = [
      disk[0].io_share_count,
      disk[0].thin_provisioned,
      clone,
    ]
  }

  enable_disk_uuid = true
  firmware = data.vsphere_virtual_machine.template.firmware
}

resource "dns_a_record_set" "cluster_endpoint_dns" {
  zone = "${var.dns_domain}."
  name = var.cluster_dns_a_record
  addresses = [var.ip_address]
  ttl = 0
}

resource "dns_a_record_set" "instance_dns" {
  zone = "${var.dns_domain}."
  name = var.instance_name
  addresses = [var.ip_address]
}