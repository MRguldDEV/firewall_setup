# Linux Firewall Setup

A simple Bash script for automatically configuring a firewall on multiple Linux distributions.

## Supported Linux Distributions

- Debian
- Ubuntu
- Linux Mint
- Pop!_OS
- CentOS
- RHEL
- Rocky Linux
- AlmaLinux
- Fedora
- openSUSE
- SLES
- Arch Linux
- Manjaro

## Firewall

The script automatically selects the firewall based on the Linux distribution.

| Distribution | Firewall |
| --- | --- |
| Debian | UFW |
| Ubuntu | UFW |
| Linux Mint | UFW |
| Pop!_OS | UFW |
| CentOS | firewalld |
| RHEL | firewalld |
| Rocky Linux | firewalld |
| AlmaLinux | firewalld |
| Fedora | firewalld |
| openSUSE | firewalld |
| SLES | firewalld |
| Arch Linux | UFW / firewalld |
| Manjaro | UFW / firewalld |

## Ports

The following ports are allowed by default:

| Service | Port | Protocol |
| --- | ---: | --- |
| SSH | Detected automatically | TCP |
| HTTP | 80 | TCP |
| HTTPS | 443 | TCP |
| Minecraft | 25565 | TCP |
| Minecraft | 25565 | UDP |

The script checks `/etc/ssh/sshd_config` and automatically detects a custom SSH port.

## Installation

Clone the repository:

```bash
git clone https://github.com/MRguldDev/firewall_setup.git
cd /root/
