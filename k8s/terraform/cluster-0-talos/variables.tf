variable "instance_name" {
  description = "Name for the gitlab instance"
  default     = "sidero"
}

variable "vm_folder" {
  description = "VMware folder location"
  default     = "Linux"
}


variable "vsphere_user" {
  description = "vSphere user name"
}

variable "vsphere_password" {
  description = "vSphere password"
}

variable "vsphere_vcenter" {
  description = "vCenter server FQDN or IP"
}

variable "vsphere_unverified_ssl" {
  description = "Is the vCenter using a self signed certificate (true/false)"
}

# DC Variables
variable "dc_server" {
  description = "The domain controller to set DNS"
  default     = "dc1.mcbadass.local"
}

variable "instance_id" {
  description = "The instance-id that re-triggers a cloud-init run"
  type        = string
  default     = "tfubuntu01"
}

variable "controlplane_instances" {
  description = "The number of control plane systems"
  type        = number
  default     = 1
}
variable "worker_instances" {
  description = "The number of control plane systems"
  type        = number
  default     = 1
}

variable "name_prefix" {
  description = "The name-prefix for naming the name."
  type        = string
}

variable "worker_memory" {
  description = "The amount of memory for worker nodes"
  type        = number
}

variable "cp_memory" {
  description = "The amount of memory for controlplane nodes"
  type        = number
}

variable "ovf_url" {
  description = "The ofv url for the deployment"
  type        = string
}
