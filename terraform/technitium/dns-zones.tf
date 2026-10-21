# DNS Zones migrated from Active Directory
# Source: dns_zones_export.csv

# Forward Lookup Zones

resource "technitium_zone" "mcbadass_com" {
  name = "mcbadass.com"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}

resource "technitium_zone" "mcbadass_local" {
  name = "mcbadass.local"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}

resource "technitium_zone" "taylorvories_com" {
  name = "taylorvories.com"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}

resource "technitium_zone" "tmtech_me" {
  name = "tmtech.me"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}

resource "technitium_zone" "tvo_hopto_org" {
  name = "tvo.hopto.org"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}

resource "technitium_zone" "t_vo_us" {
  name = "t-vo.us"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}

# Reverse Lookup Zones

resource "technitium_zone" "reverse_192_168_1" {
  name = "1.168.192.in-addr.arpa"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}


resource "technitium_zone" "reverse_192_168_180" {
  name = "180.168.192.in-addr.arpa"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}

resource "technitium_zone" "reverse_192_168_181" {
  name = "181.168.192.in-addr.arpa"
  type = "Primary"

  soa_serial_date_scheme = false # live: incrementing serials; darkhonor defaults to true
}
