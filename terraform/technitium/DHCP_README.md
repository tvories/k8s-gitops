# Technitium DNS/DHCP Terraform Configuration

This directory contains Terraform configuration for managing Technitium DNS zones, DNS records, DHCP scopes, and DHCP reservations.

## Files

- `dhcp-scopes.tf` - DHCP scope definitions (7 scopes)
- `dhcp-reservations.tf` - DHCP reserved leases (80+ reservations)
- `dns-zones.tf` - DNS zone definitions (9 zones: 6 forward, 3 reverse)
- `dns-records.tf` - DNS A records (4 records)
- `main.tf` - Main Terraform configuration
- `providers.tf` - Provider configuration for Technitium

## DHCP Scopes

| Scope Name | Network | Range | Domain | DNS Servers | Notes |
|------------|---------|-------|--------|-------------|-------|
| Legacy Network | 192.168.1.0/24 | .20-.210 | mcbadass.local | 192.168.1.243, 192.168.1.240 | 7-day lease, NTP enabled |
| Primary | 192.168.20.0/24 | .100-.200 | mcbadass.local | 192.168.1.243, 192.168.1.240 | 1-hour lease, NTP enabled |
| Guest Wifi | 192.168.40.0/24 | .100-.200 | guest.local | 192.168.1.243 | 2-hour lease |
| IoT | 192.168.50.0/24 | .50-.220 | mcbadass.local | 192.168.1.243, 192.168.1.240 | 1-hour lease |
| Joey | 192.168.70.0/24 | .100-.200 | ad.piccola.us | 1.1.1.1 | 8-hour lease |
| K8s | 192.168.80.0/24 | .50-.200 | mcbadass.local | 192.168.1.240, 192.168.1.241 | 45-min lease, **PXE boot enabled** |
| Cameras | 192.168.90.0/24 | .50-.150 | mcbadass.local | 192.168.1.243, 192.168.1.240 | 8-hour lease |

## Usage

### Initialize Terraform

```bash
cd /Users/tvories/Documents/gits/nix-config/terraform/technitium
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Configuration

```bash
terraform apply
```

### Import Existing Resources

If you need to import existing DHCP scopes or reservations:

```bash
# Import a scope
terraform import technitium_dhcp_scope.home_network "Home Network"

# Import a reservation
terraform import technitium_dhcp_reserved_lease.deskmonster "Home Network - deskmonster"
```

## Notes

### DHCP Scope Limitations

From the provider documentation:
> The API does a lot of magic behind the scenes when creating a new scope, so most changes will require deleting and recreating the scope.

This means:
- Changing scope parameters (range, subnet, etc.) requires destroy/recreate
- Be careful when modifying existing scopes
- Consider using `terraform plan` before applying changes

### DHCP Options

The Terraform provider supports these DHCP options through scope attributes:
- Router address (`router_address`)
- DNS servers (`dns_servers`)
- Domain name (`domain_name`)
- Use Technitium DNS server (`use_this_dns_server`)
- NTP servers (`ntp_servers`)
- Ping check settings (`ping_check_enabled`, `ping_check_timeout`, `ping_check_retries`)
- PXE boot options (`bootstrap_server_address`, `bootstrap_server_host_name`, `boot_file_name`)

**PXE Boot Configuration**: The K8s scope includes PXE boot support for netboot.xyz, configured with:
- Bootstrap server: `192.168.1.1`
- Boot file: `netboot.xyz.efi`

### Reservations

- Each reservation requires a unique `name` attribute for Terraform resource identification
- `hardware_address` uses dash-separated MAC addresses (e.g., `00-50-56-a4-19-a8`)
- `host_name` and `comments` are optional but recommended for documentation

## DNS Zones

### Forward Lookup Zones
- `mcbadass.com`
- `mcbadass.local`
- `taylorvories.com`
- `tmtech.me`
- `tvo.hopto.org`
- `t-vo.us`

### Reverse Lookup Zones
- `1.168.192.in-addr.arpa` (192.168.1.0/24)
- `180.168.192.in-addr.arpa` (192.168.180.0/24)
- `181.168.192.in-addr.arpa` (192.168.181.0/24)

### DNS Records

Currently managing A records in the `t-vo.us` zone:
- `grafana.cluster-0.t-vo.us` → 192.168.83.181
- `authentik.cluster-0.t-vo.us` → 192.168.83.181
- `search.t-vo.us` → 192.168.83.180 (Searxng)
- `tautulli.t-vo.us` → 192.168.83.180

## Migration from Active Directory

This configuration was migrated from Active Directory DNS/DHCP Server using PowerShell export scripts:
- `Export-DHCPScopes.ps1` - Exported DHCP scopes to JSON
- `Export-ADDnsZones.ps1` - Exported DNS zones
- `export-ad-dhcp-leases.ps1` - Exported DHCP leases
- Source data in `old infra exports/` directory

## Maintenance

### Adding New Reservations

1. Add a new `technitium_dhcp_reserved_lease` resource to `dhcp-reservations.tf`
2. Use a descriptive resource name (e.g., `new_device_name`)
3. Include the scope name prefix in the `name` attribute for clarity
4. Run `terraform plan` to verify
5. Run `terraform apply` to create

Example:
```hcl
resource "technitium_dhcp_reserved_lease" "new_device" {
  name             = "IoT - new-device"
  hardware_address = "aa-bb-cc-dd-ee-ff"
  ip_address       = "192.168.50.150"
  host_name        = "new-device.mcbadass.local"
  comments         = "Description of device"
}
```

### Adding New Scopes

1. Add a new `technitium_dhcp_scope` resource to `dhcp-scopes.tf`
2. Ensure the network doesn't overlap with existing scopes
3. Configure appropriate DNS servers and domain name
4. Set lease time using `lease_time_days`, `lease_time_hours`, or `lease_time_minutes`
5. Consider enabling ping checks for conflict detection
6. Run `terraform plan` and `terraform apply`

### Adding DNS Zones

1. Add a new `technitium_dns_zone` resource to `dns-zones.tf`
2. Set the zone type (typically "Primary")
3. Run `terraform plan` and `terraform apply`

### Adding DNS Records

1. Add a new `technitium_dns_zone_record` resource to `dns-records.tf`
2. Reference the zone using `technitium_dns_zone.<resource_name>.name`
3. Specify the record type (A, CNAME, etc.) and required attributes
4. Run `terraform plan` and `terraform apply`

## Troubleshooting

### State Drift

If manual changes were made in Technitium UI:
```bash
terraform refresh
terraform plan
```

### Removing Resources

To remove a scope or reservation:
1. Remove the resource from the `.tf` file
2. Run `terraform plan` to see what will be destroyed
3. Run `terraform apply` to remove from Technitium

Or use targeted destroy:
```bash
terraform destroy -target=technitium_dhcp_reserved_lease.old_device
```
