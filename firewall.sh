#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run this script as root."
    exit 1
fi

if [ ! -f /etc/os-release ]; then
    echo "Unable to detect operating system."
    exit 1
fi

. /etc/os-release

SSH_PORT=22

if [ -f /etc/ssh/sshd_config ]; then
    DETECTED_PORT=$(grep -E '^[[:space:]]*Port[[:space:]]+[0-9]+' /etc/ssh/sshd_config \
        | head -n 1 \
        | awk '{print $2}' || true)

    if [[ "$DETECTED_PORT" =~ ^[0-9]+$ ]]; then
        SSH_PORT="$DETECTED_PORT"
    fi
fi

install_ufw() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y ufw
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y ufw
    elif command -v yum >/dev/null 2>&1; then
        yum install -y ufw
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm ufw
    else
        echo "Could not install UFW."
        exit 1
    fi
}

install_firewalld() {
    if command -v dnf >/dev/null 2>&1; then
        dnf install -y firewalld
    elif command -v yum >/dev/null 2>&1; then
        yum install -y firewalld
    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive install firewalld
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm firewalld
    else
        echo "Could not install firewalld."
        exit 1
    fi
}

configure_ufw() {
    if ! command -v ufw >/dev/null 2>&1; then
        install_ufw
    fi

    ufw --force disable

    ufw default deny incoming
    ufw default allow outgoing

    ufw allow "${SSH_PORT}/tcp"
    ufw allow 80/tcp
    ufw allow 443/tcp

    ufw allow 25565/tcp
    ufw allow 25565/udp

    ufw --force enable

    systemctl enable ufw >/dev/null 2>&1 || true

    echo
    echo "UFW status:"
    ufw status verbose
}

configure_firewalld() {
    if ! command -v firewall-cmd >/dev/null 2>&1; then
        install_firewalld
    fi

    systemctl enable --now firewalld

    ZONE=$(firewall-cmd --get-default-zone)

    firewall-cmd \
        --zone="$ZONE" \
        --add-port="${SSH_PORT}/tcp" \
        --permanent

    firewall-cmd \
        --zone="$ZONE" \
        --add-service=http \
        --permanent

    firewall-cmd \
        --zone="$ZONE" \
        --add-service=https \
        --permanent

    firewall-cmd \
        --zone="$ZONE" \
        --add-port=25565/tcp \
        --permanent

    firewall-cmd \
        --zone="$ZONE" \
        --add-port=25565/udp \
        --permanent

    firewall-cmd --reload

    echo
    echo "firewalld status:"
    firewall-cmd --zone="$ZONE" --list-all
}

case "$ID" in
    debian|ubuntu|linuxmint|pop)
        configure_ufw
        ;;

    centos|rhel|rocky|almalinux|fedora)
        configure_firewalld
        ;;

    opensuse*|sles)
        configure_firewalld
        ;;

    arch|manjaro)
        if command -v ufw >/dev/null 2>&1; then
            configure_ufw
        else
            configure_firewalld
        fi
        ;;

    *)
        echo "Unsupported operating system: $PRETTY_NAME"
        exit 1
        ;;
esac

echo
echo "Firewall configuration completed."
echo
echo "SSH port: $SSH_PORT"
echo "HTTP: 80/tcp"
echo "HTTPS: 443/tcp"
