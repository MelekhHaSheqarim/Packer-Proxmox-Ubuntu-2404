# Variables pour template Packer Ubuntu 24.04 - Version corrigée
# Fichier variables.pkr.hcl

# Connexion Proxmox
variable "proxmox_api_url" {
  type        = string
  description = "URL de l'API Proxmox"
  default     = "https://10.0.0.240:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "ID du token d'authentification Proxmox (format: user@realm!tokenname)"
  default     = "packer@pve!packer-token"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Secret du token d'authentification Proxmox"
  default     = ""  # À définir via variable d'environnement PKR_VAR_proxmox_api_token_secret
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Nom du nœud Proxmox"
  default     = "server240"
}

variable "skip_tls_verify" {
  type        = bool
  description = "Ignorer la vérification TLS (à utiliser uniquement en développement)"
  default     = true
}

# Configuration VM
variable "vm_id" {
  type        = number
  description = "ID de la VM template"
  default     = 9999
}

variable "template_name" {
  type        = string
  description = "Nom du template final"
  default     = "template-ubuntu-24.04"
}

# Configuration matérielle
variable "cpu_cores" {
  type        = number
  description = "Nombre de cœurs CPU"
  default     = 2
  validation {
    condition     = var.cpu_cores >= 1 && var.cpu_cores <= 32
    error_message = "Le nombre de cœurs doit être entre 1 et 32."
  }
}

variable "memory" {
  type        = number
  description = "Mémoire RAM en MB"
  default     = 2048
  validation {
    condition     = var.memory >= 1024 && var.memory <= 32768
    error_message = "La mémoire doit être entre 1024 MB et 32768 MB."
  }
}

variable "disk_size" {
  type        = string
  description = "Taille du disque"
  default     = "20G"
}

variable "storage_pool" {
  type        = string
  description = "Pool de stockage Proxmox"
  default     = "local-lvm"
}

# Configuration réseau
variable "network_bridge" {
  type        = string
  description = "Bridge réseau"
  default     = "vmbr0"
}

variable "network_vlan" {
  type        = string
  description = "VLAN tag (optionnel)"
  default     = ""
}

# Configuration ISO
variable "iso_file" {
  type        = string
  description = "Fichier ISO Ubuntu"
  default     = "local:iso/ubuntu-24.04-live-server-amd64.iso"
}

# Configuration HTTP
variable "http_directory" {
  type        = string
  description = "Répertoire contenant les fichiers de configuration HTTP"
  default     = "./http"
}

variable "http_port_min" {
  type        = number
  description = "Port HTTP minimum"
  default     = 8800
}

variable "http_port_max" {
  type        = number
  description = "Port HTTP maximum"
  default     = 8899
}

# Configuration SSH
variable "ssh_username" {
  type        = string
  description = "Nom d'utilisateur SSH"
  default     = "ubuntu"
}

variable "ssh_password" {
  type        = string
  description = "Mot de passe SSH temporaire"
  default     = "ubuntu"
  sensitive   = true
}

variable "ssh_timeout" {
  type        = string
  description = "Timeout SSH"
  default     = "20m"
}

# Configuration des fichiers
variable "files_directory" {
  type        = string
  description = "Répertoire contenant les fichiers de configuration"
  default     = "./files"
}
