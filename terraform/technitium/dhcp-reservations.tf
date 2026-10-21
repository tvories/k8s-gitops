# DHCP Reserved Leases
# Migrated from Active Directory DHCP Server

# Home Network Reservations (192.168.1.0)

resource "technitium_dhcp_reserved_lease" "mineos" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "00-50-56-a4-19-a8"
  ip_address       = "192.168.1.139"
  host_name        = "mineos"
  comments         = "MineOS"
}

resource "technitium_dhcp_reserved_lease" "xboxone" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "30-59-b7-62-95-79"
  ip_address       = "192.168.1.51"
  host_name        = "XboxOne"
}

resource "technitium_dhcp_reserved_lease" "nas" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "1c-6f-65-34-cd-dc"
  ip_address       = "192.168.1.20"
  host_name        = "nas"
  comments         = "Open Media Vault"
}

resource "technitium_dhcp_reserved_lease" "deskmonster" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "30-9c-23-b7-f8-66"
  ip_address       = "192.168.1.50"
  host_name        = "deskmonster"
  comments         = "DESKMONSTER"
}

resource "technitium_dhcp_reserved_lease" "deskmonster_alt" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "50-2b-73-d8-0b-6e"
  ip_address       = "192.168.1.73"
  host_name        = "deskmonster"
}

resource "technitium_dhcp_reserved_lease" "mpsmpi" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "50-2b-73-d8-0b-58"
  ip_address       = "192.168.1.71"
  host_name        = "mpsmpi"
}

resource "technitium_dhcp_reserved_lease" "tback" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "dc-a6-32-0e-24-67"
  ip_address       = "192.168.1.74"
  host_name        = "tback"
}

resource "technitium_dhcp_reserved_lease" "tback_alt" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "dc-a6-32-0e-24-66"
  ip_address       = "192.168.1.97"
  host_name        = "tback"
  comments         = "Raspi4-wired"
}

resource "technitium_dhcp_reserved_lease" "pikvm" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "b8-27-eb-82-73-ef"
  ip_address       = "192.168.1.76"
  host_name        = "pikvm"
  comments         = "pz2"
}

resource "technitium_dhcp_reserved_lease" "idrac_3wcrjl1" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "00-26-b9-4e-c1-6f"
  ip_address       = "192.168.1.55"
  host_name        = "idrac-3WCRJL1"
}

resource "technitium_dhcp_reserved_lease" "idrac_b9tl9q1" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "bc-30-5b-d0-f3-01"
  ip_address       = "192.168.1.56"
  host_name        = "idrac-B9TL9Q1"
}

resource "technitium_dhcp_reserved_lease" "idrac_bh7xbq1" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "78-2b-cb-05-fb-65"
  ip_address       = "192.168.1.57"
  host_name        = "idrac-BH7XBQ1"
}

# This was for the old wireless setup. It's now hardwired and static IP'd
# resource "technitium_dhcp_reserved_lease" "homebox" {
#   scope            = technitium_dhcp_scope.legacy_network.name
#   hardware_address = "70-1c-e7-e2-56-fd"
#   ip_address       = "192.168.1.43"
#   host_name        = "homebox"
# }


resource "technitium_dhcp_reserved_lease" "felixpi" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "74-da-38-0d-00-e8"
  ip_address       = "192.168.1.70"
  host_name        = "felixpi"
}

resource "technitium_dhcp_reserved_lease" "enderpi" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "b8-27-eb-36-5b-f1"
  ip_address       = "192.168.1.75"
  host_name        = "enderpi"
}

resource "technitium_dhcp_reserved_lease" "ogpi" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "74-da-38-42-04-6f"
  ip_address       = "192.168.1.72"
  host_name        = "ogpi"
  comments         = "Raspberry Pi Zero"
}

resource "technitium_dhcp_reserved_lease" "raspi1" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "b8-27-eb-e6-87-75"
  ip_address       = "192.168.1.86"
  host_name        = "raspi1"
  comments         = "Raspi1Wired"
}

resource "technitium_dhcp_reserved_lease" "brother_printer" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "54-13-79-13-53-6f"
  ip_address       = "192.168.1.31"
  host_name        = "BRW54137913536F"
  comments         = "BroDocScan"
}

resource "technitium_dhcp_reserved_lease" "wled_roofspider" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "18-fe-34-99-56-b4"
  ip_address       = "192.168.1.108"
  host_name        = "wled-RoofSpider"
}

# resource "technitium_dhcp_reserved_lease" "hs110_server_rack" {
#   scope            = technitium_dhcp_scope.legacy_network.name
#   hardware_address = "50-C7-BF-30-49-E4"
#   ip_address       = "192.168.1.203"
#   host_name        = "hs110-server-rack"
# }

resource "technitium_dhcp_reserved_lease" "doorbell_camera" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "9c-8e-cd-3c-34-f3"
  ip_address       = "192.168.1.129"
  host_name        = "doorbell-camera"
}

resource "technitium_dhcp_reserved_lease" "hs100_38_14" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "50-c7-bf-16-38-14"
  ip_address       = "192.168.1.201"
  host_name        = "hs100-38-14"
}

resource "technitium_dhcp_reserved_lease" "hs200_22_7f" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "50-c7-bf-28-22-7f"
  ip_address       = "192.168.1.202"
  host_name        = "hs200-22-7f"
}

resource "technitium_dhcp_reserved_lease" "hs100_20_f1" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "70-4f-57-78-20-f1"
  ip_address       = "192.168.1.204"
  host_name        = "hs100-20-f1"
}

resource "technitium_dhcp_reserved_lease" "hs100_server_rack" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "50-c7-bf-30-49-e4"
  ip_address       = "192.168.1.203"
}


# Primary Network Reservations (192.168.20.0)

resource "technitium_dhcp_reserved_lease" "eap653" {
  scope            = technitium_dhcp_scope.primary.name
  hardware_address = "34-60-f9-5e-a3-7e"
  ip_address       = "192.168.20.10"
  host_name        = "EAP653-34-60-F9-5E-A3-7E"
}

# "iscsi" (aa-aa-aa-aa-aa -> 192.168.20.21) dropped in the darkhonor migration:
# a 5-byte placeholder from the AD export, outside the scope's pool. The live
# entry is left in Technitium; delete it there.

resource "technitium_dhcp_reserved_lease" "pikvm_primary_1" {
  scope            = technitium_dhcp_scope.primary.name
  hardware_address = "d8-3a-dd-fe-49-94"
  ip_address       = "192.168.20.66"
  host_name        = "pikvm"
}

resource "technitium_dhcp_reserved_lease" "pikvm_primary_2" {
  scope            = technitium_dhcp_scope.primary.name
  hardware_address = "d8-3a-dd-fe-4b-b3"
  ip_address       = "192.168.20.67"
  host_name        = "pikvm"
}

resource "technitium_dhcp_reserved_lease" "pixel_8_pro" {
  scope            = technitium_dhcp_scope.primary.name
  hardware_address = "5c-33-7b-ef-b2-b7"
  ip_address       = "192.168.20.105"
  host_name        = "Pixel-8-Pro"
}

# IoT Network Reservations (192.168.50.0)

resource "technitium_dhcp_reserved_lease" "rainmachine" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "a8-80-38-24-f3-70"
  ip_address       = "192.168.50.20"
  host_name        = "RainMachine"
  comments         = "rainmachine"
}

resource "technitium_dhcp_reserved_lease" "water_heater" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "e8-6b-ea-0f-f1-78"
  ip_address       = "192.168.50.50"
  host_name        = "water-heater"
}

resource "technitium_dhcp_reserved_lease" "kp115_1" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "00-5f-67-b1-8e-70"
  ip_address       = "192.168.50.51"
  host_name        = "KP115"
}

resource "technitium_dhcp_reserved_lease" "receiver_fan" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "60-01-94-0d-ee-74"
  ip_address       = "192.168.50.52"
  host_name        = "receiver-fan"
}

resource "technitium_dhcp_reserved_lease" "kp115_2" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "90-9a-4a-2e-76-ae"
  ip_address       = "192.168.50.54"
  host_name        = "KP115"
}

resource "technitium_dhcp_reserved_lease" "basement" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "3c-61-05-0b-d8-8c"
  ip_address       = "192.168.50.55"
  host_name        = "basement"
}

resource "technitium_dhcp_reserved_lease" "attic_north" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "30-ae-a4-4c-c8-a0"
  ip_address       = "192.168.50.56"
  host_name        = "attic-north"
}

resource "technitium_dhcp_reserved_lease" "freezer" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "a0-20-a6-0b-4a-6e"
  ip_address       = "192.168.50.57"
  host_name        = "freezer"
}

resource "technitium_dhcp_reserved_lease" "radonpi" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "b8-27-eb-82-73-ef"
  ip_address       = "192.168.50.58"
  host_name        = "radonpi"
}

resource "technitium_dhcp_reserved_lease" "front_door" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "9c-8e-cd-3c-34-f3"
  ip_address       = "192.168.50.61"
  host_name        = "Front Door"
}

resource "technitium_dhcp_reserved_lease" "receiver_fan_2" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "30-ae-a4-4d-44-6c"
  ip_address       = "192.168.50.62"
  host_name        = "receiver-fan"
}

resource "technitium_dhcp_reserved_lease" "xcel_meter" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "B4-23-30-38-A1-04"
  ip_address       = "192.168.50.64"
  host_name        = "xcel meter"
}

resource "technitium_dhcp_reserved_lease" "ble_gateway" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "3c-61-05-0d-ee-90"
  ip_address       = "192.168.50.67"
  host_name        = "ble-gateway"
}

resource "technitium_dhcp_reserved_lease" "p1s_printer" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "30-ae-a4-4d-48-50"
  ip_address       = "192.168.50.69"
  host_name        = "p1s-printer"
}

resource "technitium_dhcp_reserved_lease" "garage" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "3c-61-05-0c-50-0c"
  ip_address       = "192.168.50.72"
  host_name        = "garage"
}

resource "technitium_dhcp_reserved_lease" "m720q_4_iot" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "0c-c4-7a-bd-ac-65"
  ip_address       = "192.168.50.90"
  host_name        = "m720q-4"
}

# "lutron" dropped in the darkhonor migration: AD exported the client
# identifier (ab-3b-58-36-00-01-00-01-1e-d6-27-38-f4-5e-ab-3b-58-36), not a
# MAC, so it never matched. The hub's real MAC is f4-5e-ab-3b-58-36 (seen
# dynamically at 192.168.50.59). Re-add with that MAC if it should be pinned.

resource "technitium_dhcp_reserved_lease" "m720q_1_iot" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "24-8a-07-f7-28-40"
  ip_address       = "192.168.50.99"
  host_name        = "m720q-1"
}

resource "technitium_dhcp_reserved_lease" "m720q_2_iot" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "24-8a-07-e1-6b-d0"
  ip_address       = "192.168.50.100"
  host_name        = "m720q-2"
}

resource "technitium_dhcp_reserved_lease" "m720q_3_iot" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "e4-1d-2d-df-4d-00"
  ip_address       = "192.168.50.101"
  host_name        = "m720q-3"
}

# K8s Network Reservations (192.168.80.0)

resource "technitium_dhcp_reserved_lease" "m720q_4_k8s" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "E8-6A-64-38-FD-43"
  ip_address       = "192.168.80.90"
  host_name        = "m720q-4"
  comments         = "m720q-4"
}

resource "technitium_dhcp_reserved_lease" "talos_cp_1" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-30"
  ip_address       = "192.168.80.91"
  host_name        = "talos-cp-1"
  comments         = "talos-cp-1"
}

resource "technitium_dhcp_reserved_lease" "talos_cp_2" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-31"
  ip_address       = "192.168.80.92"
  host_name        = "talos-cp-2"
  comments         = "talos-cp-2"
}

resource "technitium_dhcp_reserved_lease" "talos_cp_3" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-32"
  ip_address       = "192.168.80.93"
  host_name        = "talos-cp-3"
  comments         = "talos-cp-3"
}

resource "technitium_dhcp_reserved_lease" "talos_worker_1" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-40"
  ip_address       = "192.168.80.94"
  host_name        = "talos-worker-1"
  comments         = "talos-worker-1"
}

resource "technitium_dhcp_reserved_lease" "talos_worker_2" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-41"
  ip_address       = "192.168.80.95"
  host_name        = "talos-worker-2"
  comments         = "talos-worker-2"
}

resource "technitium_dhcp_reserved_lease" "talos_worker_3" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-42"
  ip_address       = "192.168.80.96"
  host_name        = "talos-worker-3"
  comments         = "talos-worker-3"
}

resource "technitium_dhcp_reserved_lease" "sff1" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "90-b1-1c-7b-e0-2e"
  ip_address       = "192.168.80.97"
  host_name        = "sff1"
  comments         = "sff1"
}

resource "technitium_dhcp_reserved_lease" "physical1" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-25-90-47-ae-94"
  ip_address       = "192.168.80.98"
  host_name        = "physical1"
  comments         = "physical1"
}

resource "technitium_dhcp_reserved_lease" "m720q_1_k8s" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "24-8a-07-f7-28-40"
  ip_address       = "192.168.80.99"
  host_name        = "m720q-1"
  comments         = "m720q-1"
}

resource "technitium_dhcp_reserved_lease" "m720q_2_k8s" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "24-8a-07-e1-6b-d0"
  ip_address       = "192.168.80.100"
  host_name        = "m720q-2"
}

resource "technitium_dhcp_reserved_lease" "m720q_3_k8s" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "e4-1d-2d-df-4d-00"
  ip_address       = "192.168.80.101"
  host_name        = "m720q-3"
  comments         = "m720q3"
}

resource "technitium_dhcp_reserved_lease" "talos_test_cp_1" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-50"
  ip_address       = "192.168.80.190"
  host_name        = "talos-test-cp-1"
}

resource "technitium_dhcp_reserved_lease" "talos_test_cp_2" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-51"
  ip_address       = "192.168.80.191"
  host_name        = "talos-test-cp-2"
}

resource "technitium_dhcp_reserved_lease" "talos_test_cp_3" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-52"
  ip_address       = "192.168.80.192"
  host_name        = "talos-test-cp-3"
}

resource "technitium_dhcp_reserved_lease" "talos_test_worker_1" {
  scope            = technitium_dhcp_scope.k8s.name
  hardware_address = "00-50-56-ab-f1-60"
  ip_address       = "192.168.80.200"
  host_name        = "talos-test-worker-1"
}

resource "technitium_dhcp_reserved_lease" "taylor_pixel_testing" {
  scope            = technitium_dhcp_scope.guest_wifi.name
  hardware_address = "BA-7F-81-C5-1C-89"
  ip_address       = "192.168.40.123"
  host_name        = "taylor-pixel-testing"
  comments         = "taylor-pixel-testing"
}

resource "technitium_dhcp_reserved_lease" "home_assistant_multus_1" {
  scope            = technitium_dhcp_scope.legacy_network.name
  hardware_address = "FF-FF-FF-FF-FF-FF"
  ip_address       = "192.168.1.10"
  host_name        = "home-assistant-multus-1"
  comments         = "home-assistant-multus-1"
}

resource "technitium_dhcp_reserved_lease" "home_assistant_multus_50" {
  scope            = technitium_dhcp_scope.iot.name
  hardware_address = "FF-FF-FF-FF-FF-FF"
  ip_address       = "192.168.50.10"
  host_name        = "home-assistant-multus-50"
  comments         = "home-assistant-multus-50"
}
