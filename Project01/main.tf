terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.6" #or whatever the current version is
    }
  }
}

#this is where we can authenticate to the server
  provider "proxmox" {
    pm_api_url = "https://proxmox.local.kkovach.com/api2/json"
    pm_api_token_id = "terraform@pam!terraform_token"
    pm_api_token_secret = "ENTER SECRET HERE"
  }
  
# now we can start to build our VM
  resource "proxmox_vm_qemu" "test_VM" {
    count = 1
    name = "test-VM-${count.index + 1}" #this is going to index the VM created with a number based on a counter variable.
    
    # we're going to start pointing to our vars file for the following attributes
    target_node = var.proxmox_host
    clone = var.template_name
    
    #now i'll set the VM specs
    agent = 1
    os_type = "cloud-init"
    cores = 4
    sockets = 1
    cpu = "host"
    memory = "4096"
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    
    disk {
      slot = 0
      size = "32G"
      type = "scsi"
      storage = "SSD"
      iothread = 1
    }
    
    #we can set the IP here, and we can use the same counter variable to set an IP.
    ipconfig0 = "ip=10.0.0.11${count.index +1}/24,gw=10.0.0.1"
    
    #include your SSH keys so you can SSH into the new server right from the start. We'll use another variable there.
    sshkeys = <<EOF
    ${var.ssh_key}
    EOF
  }