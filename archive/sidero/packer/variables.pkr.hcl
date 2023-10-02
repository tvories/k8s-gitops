variable "vsphere_server" {
    description = "vCenter server to build the VM on"
}

variable "vsphere_username" {
    description = "Username to authenticate to vCenter"
}

variable "vsphere_password" {
    description = "Password to authenticate to vCenter"
    default     = ""
}

variable "vsphere_cluster" {
}

variable "vsphere_datacenter" {
}

# variable "vsphere_host" {
# }

variable "vsphere_datastore" {
}

variable "vsphere_folder" {
}
variable "vsphere_insecure_cert" {
    description = "Trust insecure self-signed certs"
    type = bool
    default = false
}

variable "connection_username" {
    default = "vagrant"
}
variable "connection_password" {
    default = "vagrant"
    sensitive = true
}
variable "connection_password_encrypted" {
    type = string
    sensitive = true
    description = "The encrypted password to login the guest operating system."
}

variable "vm_hardware_version" {
    default = "13"
}
variable "iso_checksum" {
    description = "ISO Checksum for iso image."
    default = ""
}

variable "os_version" {
    description = "The version of the OS"
    default = ""
}

variable "os_iso_path" {
    default = ""
}

variable "guest_os_type" {
    default = ""
}
variable "root_disk_size" {
    default = 48000
}
variable "nic_type" {
    default = "vmxnet3"
}
variable "vm_network" { }
variable "num_cpu" {
    default = 4
}
variable "num_cores" {
    default = 1
}
variable "vm_ram" {
    default = 4096
}

variable "os_family" {
    default = ""
}
variable "os_iso_url" {
    default = ""
}
variable "host_ip" { 
    default = ""
}
variable "boot_command" {
    default = []
    type = list(string)
} # TODO: Figure out stupid default for this
variable "boot_config_url" {
    default = ""
}
variable "ignition_data" {
    description = "The ignition configuration data in base64"
    default = ""
}
variable "ansible_user_key" {
    description = "The public key for the ansible user"
    type = string
}
variable "ansible_username" {
    description = "The username for future ansible tasks."
    type = string
}