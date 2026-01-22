variable "instance_name" {
  description = "Name for the sidero instance"
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
# variable "vsphere_resource_pool" {
#   description = "vSphere datacenter"
# }
variable "vsphere_datacenter" {
  type = string
  description = "Datacenter"
}
variable "vsphere_datastore" {
  type = string
  description = "Datastore"
}
variable "vsphere_cluster" {
  type = string
  description = "Cluster"
}
variable "vsphere_network" {
  type = string
  description = "Network"
}
variable "vsphere_unverified_ssl" {
  description = "Is the vCenter using a self signed certificate (true/false)"
}
variable "instance_id" {
  description = "The instance-id that re-triggers a cloud-init run"
  type = string
  default = "tfubuntu01"
}
variable "ip_address" {
  type = string
}
variable "gateway" {
  type = string
}
variable "nameservers" {
  type = list(string)
}
variable "search_domains" {
  type = list(string)
}
variable "dns_server" {
  type = string
  description = "The DNS server used to update a dns record"
}
variable "dns_domain" {
  type = string
  description = "The dns domain used to set dns records"
}
variable "cluster_dns_a_record" {
  type = string
  description = "The dns a record name for the cluster endpoint"
}