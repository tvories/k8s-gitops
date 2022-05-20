local-hostname: ${ hostname }
instance-id: ${instance_id}
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: false #true to use dhcp
      addresses:
        - ${ip_address}/24 #Set you ip here
      gateway4: ${gateway} # Set gw here 
      nameservers:
        search: 
%{for search in search_domains ~}
          - ${search}
%{ endfor }
        addresses:
%{for ns in nameservers ~}
          - ${ns}
%{ endfor }