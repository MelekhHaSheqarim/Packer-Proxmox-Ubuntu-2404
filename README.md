# Packer Proxmox Ubuntu 24.04 Cloud-Init Template

> Génère automatiquement un template Ubuntu 24.04 LTS prêt pour Cloud-Init sur Proxmox VE.

## Prérequis

- Packer ≥ 1.9
- Proxmox VE (API activée)
- Un token Proxmox avec droits sur le pool cible (voir doc Proxmox)
- L’ISO Ubuntu 24.04 (nommé `ubuntu-24.04-live-server-amd64.iso` dans le storage `local:iso`)
- Accès réseau au port 8800 depuis la VM de build

## Structure

- `ubuntu-24.04.pkr.hcl` : template principal Packer (HCL2)
- `variables.pkr.hcl` : variables du build, à personnaliser
- `http/user-data` & `http/meta-data` : fichiers cloud-init utilisés lors de l'installation
- `files/99-pve.cfg` : configuration Cloud-Init additionnelle

## Utilisation rapide

```sh
packer init .
packer build \
  -var "proxmox_token_id=monuser@pve!montoken" \
  -var "proxmox_token_secret=MON_TOKEN_SECRET" \
  -var "ssh_password=MotDePasseTemporaire" \
  ubuntu-24.04.pkr.hcl
```

Voir le fichier `variables.pkr.hcl` pour tous les paramètres personnalisables.

## License

MIT — see [LICENSE](./LICENSE).


Packer Template for Proxmox Ubuntu 24.04 LTS

<img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg">

