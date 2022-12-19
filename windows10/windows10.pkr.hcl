# Windows 10
# ---
# Packer Template to create an Windows 10 on Proxmox

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

# Resource Definition for the VM Template
source "proxmox" "windows10" {
 
  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_api_url}"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true
  
  # VM General Settings
  node = "pve"
  vm_id = "930"
  vm_name = "windows10"
  template_description = "Windows10 Image"

  # VM OS Settings
  # (Option 1) Local ISO File
  iso_file = "local:iso/Win10_22H2_English_x64.iso"
  # - or -
  # (Option 2) Download ISO
  # iso_url = "https://releases.ubuntu.com/jammy/ubuntu-22.04.1-live-server-amd64.iso"
  # iso_checksum = "10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
  # iso_storage_pool = "local"
  unmount_iso = true

  # VM System Settings
  qemu_agent = true
  os = "win10"

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
      disk_size = "60G"
      format = "qcow2"
      storage_pool = "local"
      storage_pool_type = "lvm"
      type = "virtio"
  }

  # VM CPU Settings
  cores = "2"
  
  # VM Memory Settings
  memory = "8192" 

  # VM Network Settings
  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    vlan_tag = "23"
    firewall = "false"
  } 

  # (Optional) Bind IP Address and Port
  http_bind_address = "192.168.23.31"
  http_port_min = 8802
  http_port_max = 8802

  # winrm settings
  communicator = "winrm"
  winrm_username = "vagrant"
  winrm_password = "vagrant"
  winrm_timeout = "10m"
  winrm_insecure = true
  winrm_use_ssl = true

  # Additonal iso files for install
  additional_iso_files {
      device = "sata3"
      iso_file = "local:iso/Autounattend.iso"
      unmount = true
  }
  
  additional_iso_files {
      device = "sata4"
      iso_file = "local:iso/virtio-win.iso"
      unmount = true
  }
}

# Build Definition to create the VM Template
build {

  name = "windows10"
  sources = ["source.proxmox.windows10"]

  # Prevent windows updates
  provisioner "windows-shell" {
    script = "scripts/disablewinupdate.bat"
  }

  # disable hibernate
  provisioner "powershell" {
    script = "scripts/disable-hibernate.ps1"
  }

}