variable "iso_file" {
  type    = string
  default = "local:iso/debian-11.5.0-amd64-netinst.iso"
}

variable "cloudinit_storage_pool" {
  type    = string
  default = "local"
}

variable "cores" {
  type    = string
  default = "2"
}

variable "disk_format" {
  type    = string
  default = "raw"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "disk_storage_pool" {
  type    = string
  default = "local"
}

variable "disk_storage_pool_type" {
  type    = string
  default = "lvm"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "network_vlan" {
  type    = string
  default = "23"
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_node" {
  type = string
}

source "proxmox-iso" "debian-11" {
  proxmox_url              = "${var.proxmox_api_url}"
  insecure_skip_tls_verify = true
  username                 = "${var.proxmox_api_token_id}"
  token                    = "${var.proxmox_api_token_secret}"

  template_description = "Debian 11 cloud-init template. Built on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"
  node                 = "${var.proxmox_node}"
  network_adapters {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
    vlan_tag = var.network_vlan
  }
  disks {
    disk_size         = var.disk_size
    format            = var.disk_format
    io_thread         = true
    storage_pool      = var.disk_storage_pool
    storage_pool_type = var.disk_storage_pool_type
    type              = "scsi"
  }
  scsi_controller = "virtio-scsi-single"

  iso_file       = var.iso_file
  http_directory = "http"
  http_bind_address = "192.168.23.121"
  http_port_min = 8802
  http_port_max = 8802
  boot_wait = "5s"
  boot_command = [
    "<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
  ]
  unmount_iso    = true

  cloud_init = true
  cloud_init_storage_pool = var.cloudinit_storage_pool

  vm_name = "debian-bullseye"
  vm_id = "910"
  cpu_type = "host"
  os = "l26"
  memory = var.memory
  cores = var.cores
  sockets = "1"

  ssh_username = "root"

  # (Option 1) Add your Password here
  ssh_password = "packer"
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  # ssh_private_key_file = "~/.ssh/id_ed25519"

  # Raise the timeout, when installation takes longer
  ssh_timeout = "20m"
}

build {
  sources = ["source.proxmox-iso.debian-11"]

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "cloud.cfg"
  }

  provisioner "file" {
      source = "files/99-pve.cfg"
      destination = "/tmp/99-pve.cfg"
    }
}