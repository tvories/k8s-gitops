#cloud-config 
users:
  - default #Define a default user
  - name: ${connection_username}
    gecos: ${connection_username}
    passwd: ${connection_password_encrypted}
    lock_passwd: false
    groups: sudo, users, admin
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
ssh_pwauth: yes #Use pwd to access (otherwise follow official doc to use ssh-keys)
random_seed:
    file: /dev/urandom
    command: ["pollinate", "-r", "-s", "https://entropy.ubuntu.com"]
    command_required: true
package_upgrade: true
packages:
  - python3-pip #Dependency package for cloud-init vsphere component
runcmd:
  - curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh - #Install cloud-init
