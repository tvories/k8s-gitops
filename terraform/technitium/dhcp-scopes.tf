# Home Network - 192.168.1.0/24
resource "technitium_dhcp_scope" "legacy_network" {
  name             = "Legacy Network"
  enabled          = true
  starting_address = "192.168.1.20"
  ending_address   = "192.168.1.210"
  subnet_mask      = "255.255.255.0"

  lease_time_days = 7

  router_address     = "192.168.1.1"
  dns_servers        = ["192.168.1.243", "192.168.83.241"]
  domain_name        = "mcbadass.local"
  ping_check_enabled = true
  ping_check_timeout = 1000
  ping_check_retries = 2

  ntp_servers = ["192.168.1.1"]
}

# Allen Primary - 192.168.10.0/24
resource "technitium_dhcp_scope" "allen_primary" {
  name             = "Allen Primary"
  enabled          = true
  starting_address = "192.168.10.100"
  ending_address   = "192.168.10.200"
  subnet_mask      = "255.255.255.0"

  lease_time_hours = 1

  router_address     = "192.168.10.1"
  dns_servers        = ["192.168.1.243", "192.168.83.241"]
  domain_name        = "mcbadass.local"
  ping_check_enabled = true
  ping_check_timeout = 1000
  ping_check_retries = 2

  ntp_servers = ["192.168.1.1"]
}

# Primary Network - 192.168.20.0/24
resource "technitium_dhcp_scope" "primary" {
  name             = "Primary"
  enabled          = true
  starting_address = "192.168.20.100"
  ending_address   = "192.168.20.200"
  subnet_mask      = "255.255.255.0"

  lease_time_hours = 1

  router_address     = "192.168.20.1"
  dns_servers        = ["192.168.1.243", "192.168.83.241"]
  domain_name        = "mcbadass.local"
  ping_check_enabled = true
  ping_check_timeout = 1000
  ping_check_retries = 2

  ntp_servers = ["192.168.1.1"]
}

# Guest WiFi - 192.168.40.0/24
resource "technitium_dhcp_scope" "guest_wifi" {
  name             = "Guest Wifi"
  enabled          = true
  starting_address = "192.168.40.100"
  ending_address   = "192.168.40.200"
  subnet_mask      = "255.255.255.0"

  lease_time_hours = 2

  router_address = "192.168.40.1"
  dns_servers    = ["192.168.1.243", "192.168.83.241"]
  domain_name    = "guest.local"
}

# IoT Network - 192.168.50.0/24
resource "technitium_dhcp_scope" "iot" {
  name             = "IoT"
  enabled          = true
  starting_address = "192.168.50.50"
  ending_address   = "192.168.50.220"
  subnet_mask      = "255.255.255.0"

  lease_time_hours = 1

  router_address = "192.168.50.1"
  dns_servers    = ["192.168.1.243", "192.168.83.241"]
  domain_name    = "mcbadass.local"
}

# Joey's Network - 192.168.70.0/24
resource "technitium_dhcp_scope" "joey" {
  name             = "Joey"
  enabled          = true
  starting_address = "192.168.70.100"
  ending_address   = "192.168.70.200"
  subnet_mask      = "255.255.255.0"

  lease_time_hours = 8

  router_address = "192.168.70.1"
  dns_servers    = ["1.1.1.1"]
  domain_name    = "ad.piccola.us"
}

# K8s Network - 192.168.80.0/24
resource "technitium_dhcp_scope" "k8s" {
  name             = "K8s"
  enabled          = true
  starting_address = "192.168.80.50"
  ending_address   = "192.168.80.200"
  subnet_mask      = "255.255.255.0"

  lease_time_minutes = 45

  router_address      = "192.168.80.1"
  dns_servers         = ["192.168.83.241", "192.168.83.241"]
  domain_name         = "mcbadass.local"
  use_this_dns_server = false

  # server_address (next-server) is unset live; only the host name is.
  server_host_name = "192.168.1.1"
  boot_file_name   = "netboot.xyz.efi"
}

# Cameras Network - 192.168.90.0/24
resource "technitium_dhcp_scope" "cameras" {
  name             = "Cameras"
  enabled          = true
  starting_address = "192.168.90.50"
  ending_address   = "192.168.90.150"
  subnet_mask      = "255.255.255.0"

  lease_time_hours = 8

  router_address = "192.168.90.1"
  dns_servers    = ["192.168.1.243", "192.168.83.241"]
  domain_name    = "mcbadass.local"
}
