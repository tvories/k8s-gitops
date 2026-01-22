output "sidero_ip" {
  value = vsphere_virtual_machine.sidero.guest_ip_addresses[0]
}
output "sidero_cluster_endpoint" {
  value = dns_a_record_set.cluster_endpoint_dns.id
}
output "sidero_dns_name" {
  value = dns_a_record_set.instance_dns.id
}