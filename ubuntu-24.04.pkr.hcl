# Ubuntu Server 24.04 LTS Noble Numbat
# Packer Template corrigé pour Proxmox VE - Version fonctionnelle

packer {
  required_version = ">= 1.9.0"
  required_plugins {
    proxmox = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  build_date    = formatdate("YYYYMMDD", timestamp())
  build_time    = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  vm_name       = "ubuntu-24.04-${local.build_date}"
  template_desc = "Ubuntu 24.04 LTS Template - Build ${local.build_date} - Created ${local.build_time}"
}

source "proxmox-iso" "ubuntu-server-noble" {
  # Connexion Proxmox - syntaxe corrigée
  proxmox_url  = var.proxmox_api_url
  username     = var.proxmox_api_token_id
  token        = var.proxmox_api_token_secret
  node         = var.proxmox_node

  # Sécurité TLS
  insecure_skip_tls_verify = var.skip_tls_verify

  # Configuration VM
  vm_id                = var.vm_id
  vm_name              = local.vm_name
  template_name        = "${var.template_name}-${local.build_date}"
  template_description = local.template_desc
  tags                 = "template;packer;ubuntu"

  boot_iso {
    type     = "scsi"
    iso_file = var.iso_file
    unmount  = true
  }

  # Système
  qemu_agent = true
  os         = "l26"  # Linux 2.6+ kernel

  # Stockage - syntaxe blocks corrigée
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = var.disk_size
    format       = "raw"
    storage_pool = var.storage_pool
    type         = "scsi"
    cache_mode   = "writethrough"
    io_thread    = true
  }

  # CPU
  cores    = var.cpu_cores
  sockets  = 1
  cpu_type = "host"

  # Mémoire
  memory = var.memory

  # Réseau - syntaxe blocks corrigée
  network_adapters {
    model    = "virtio"
    bridge   = var.network_bridge
    firewall = false
    vlan_tag = var.network_vlan != "" ? var.network_vlan : null
  }

  # Cloud-Init
  cloud_init              = true
  cloud_init_storage_pool = var.storage_pool

  # Configuration EFI
  efi_config {
    efi_storage_pool  = var.storage_pool
    pre_enrolled_keys = true
  }

  # Boot configuration
  boot_command = [
    "<esc><wait2s>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot      = "order=scsi0;ide2"
  boot_wait = "10s"

  # Configuration HTTP
  http_directory = var.http_directory
  http_port_min  = var.http_port_min
  http_port_max  = var.http_port_max

  # SSH
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout

  # Machine type optimisé
  machine = "q35"
  bios    = "ovmf"
}

build {
  name    = "ubuntu-24.04-template"
  sources = ["source.proxmox-iso.ubuntu-server-noble"]

  # Attendre que Cloud-Init termine
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done",
      "echo 'Cloud-init completed'"
    ]
    timeout = "10m"
  }

  # Configuration Cloud-Init pour Proxmox
  provisioner "file" {
    source      = "${var.files_directory}/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Finalisation du template
  provisioner "shell" {
    inline = [
      "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",

      # Nettoyage des clés SSH host
      "sudo rm -f /etc/ssh/ssh_host_*",

      # Reset machine-id
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",

      # Nettoyage Cloud-Init
      "sudo cloud-init clean --logs",
      "sudo rm -rf /var/lib/cloud/instances/*",

      # Suppression des fichiers de configuration réseau
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",

      # Nettoyage APT
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean",
      "sudo apt-get clean",

      # Synchronisation finale
      "sudo sync"
    ]
  }
}