#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Auto Installer for Linux Environment
# Install Python, pip, wget, curl, sed, git, unzip, tar, gzip
# and other basic tools needed to download GitHub sources.
# =========================================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

log() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

ok() {
  echo -e "${GREEN}[OK]${NC} $1"
}

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  exit 1
}

check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    fail "Jalankan script ini sebagai root / sudo"
  fi
}

install_debian() {
  log "Menginstall paket dasar untuk Debian/Ubuntu..."
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip python3-venv \
    wget curl sed git ca-certificates \
    unzip tar gzip bzip2 xz-utils \
    build-essential procps
}

install_redhat() {
  log "Menginstall paket dasar untuk RHEL/CentOS/Fedora..."
  if command -v dnf >/dev/null 2>&1; then
    dnf install -y \
      python3 python3-pip \
      wget curl sed git ca-certificates \
      unzip tar gzip bzip2 xz-utils \
      gcc make procps
  elif command -v yum >/dev/null 2>&1; then
    yum install -y \
      python3 python3-pip \
      wget curl sed git ca-certificates \
      unzip tar gzip bzip2 xz-utils \
      gcc make procps
  else
    fail "Tidak ditemukan package manager yang didukung (dnf/yum)"
  fi
}

install_arch() {
  log "Menginstall paket dasar untuk Arch Linux..."
  pacman -Sy --noconfirm \
    python python-pip \
    wget curl sed git ca-certificates \
    unzip tar gzip bzip2 xz-utils \
    base-devel procps
}

install_alpine() {
  log "Menginstall paket dasar untuk Alpine Linux..."
  apk add --no-cache \
    python3 py3-pip \
    wget curl sed git ca-certificates \
    unzip tar gzip bzip2 xz-utils \
    build-base procps
}

main() {
  check_root

  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}  AUTO INSTALL TOOLING ENVIRONMENT      ${NC}"
  echo -e "${CYAN}========================================${NC}"

  if command -v apt-get >/dev/null 2>&1; then
    install_debian
  elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
    install_redhat
  elif command -v pacman >/dev/null 2>&1; then
    install_arch
  elif command -v apk >/dev/null 2>&1; then
    install_alpine
  else
    fail "Distribusi Linux tidak didukung oleh skrip ini"
  fi

  log "Memastikan python dan pip tersedia..."
  if command -v python3 >/dev/null 2>&1; then
    python3 --version
  fi

  if command -v pip3 >/dev/null 2>&1; then
    pip3 --version
  else
    warn "pip3 tidak ditemukan setelah install. Coba jalankan: python3 -m ensurepip --upgrade"
  fi

  for cmd in wget curl sed git unzip tar gzip; do
    if command -v "$cmd" >/dev/null 2>&1; then
      ok "$cmd sudah tersedia"
    else
      warn "$cmd belum tersedia"
    fi
  done

  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}  MENJALANKAN INSTALASI                  ${NC}"
  echo -e "${GREEN}========================================${NC}"
  #echo -e "${GREEN}Sekarang Anda bisa langsung memakai:${NC}"
  echo -e "  ${CYAN}wget https://github.com/....${NC}"
  echo -e "  ${CYAN}git clone https://github.com/....${NC}"
  echo -e "  ${CYAN}python3 --version${NC}"
  echo -e "  ${CYAN}pip3 --version${NC}"
  echo -e "  ${CYAN}zerotier${NC}"
  wget -O /usr/local/bin/a-reboot https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/a-reboot.sh && chmod +x /usr/local/bin/a-reboot
  wget -O /usr/local/bin/cek_service https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/cek_service.sh && chmod +x /usr/local/bin/cek_service
  wget -O /usr/local/bin/ddos https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/ddos.py && chmod +x /usr/local/bin/ddos
  wget -O /usr/local/bin/disk https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/disk.sh && chmod +x /usr/local/bin/disk
  wget -O /usr/local/bin/dns-records https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/dns-records.sh && chmod +x /usr/local/bin/dns-records
  wget -O /usr/local/bin/install-domain-finder https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/install-domain-finder.sh && chmod +x /usr/local/bin/install-domain-finder
  wget -O /usr/local/bin/kirim_email https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/kirim_email.py && chmod +x /usr/local/bin/kirim_email
  wget -O /usr/local/bin/loading https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/loading.sh && chmod +x /usr/local/bin/loading
  wget -O /usr/local/bin/lookup-dns https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/lookup-dns.sh && chmod +x /usr/local/bin/lookup-dns
  wget -O /usr/local/bin/m-ddos https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-ddos.sh && chmod +x /usr/local/bin/m-ddos
  wget -O /usr/local/bin/install-sherlock https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/install-sherlock.sh && chmod +x /usr/local/bin/install-sherlock
  wget -O /usr/local/bin/m-domain https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-domain.py && chmod +x /usr/local/bin/m-domain
  wget -O /usr/local/bin/m-monitor https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-monitor.sh && chmod +x /usr/local/bin/m-monitor
  wget -O /usr/local/bin/m-screen https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-screen.sh && chmod +x /usr/local/bin/m-screen
  wget -O /usr/local/bin/m-nginx https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-nginx.sh && chmod +x /usr/local/bin/m-nginx
  wget -O /usr/local/bin/m-tailscale https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-tailscale.sh && chmod +x /usr/local/bin/m-tailscale
  wget -O /usr/local/bin/m-tracker https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-tracker.py && chmod +x /usr/local/bin/m-tracker
  wget -O /usr/local/bin/m-zerotier https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-zerotier.sh && chmod +x /usr/local/bin/m-zerotier
  wget -O /usr/local/bin/m-setting https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-setting.sh && chmod +x /usr/local/bin/m-setting
  wget -O /usr/local/bin/m-user-finder https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/m-user-finder.sh && chmod +x /usr/local/bin/m-user-finder
  wget -O /usr/local/bin/menu https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/menu.sh && chmod +x /usr/local/bin/menu
  wget -O /usr/local/bin/mode-hack https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/mode-hack.sh && chmod +x /usr/local/bin/mode-hack 
  wget -O /usr/local/bin/nobody-spam https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/nobody-spam.py && chmod +x /usr/local/bin/nobody-spam
  wget -O /usr/local/bin/root https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/root.sh && chmod +x /usr/local/bin/root
  wget -O /usr/local/bin/service_manager https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/service_manager.sh && chmod +x /usr/local/bin/service_manager
  wget -O /usr/local/bin/sub-domain-finder https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/sub-domain-finder.sh && chmod +x /usr/local/bin/sub-domain-finder
  wget -O /usr/local/bin/ua.txt https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/ua.txt && chmod 777 /usr/local/bin/ua.txt
  cat >> /root/.bashrc << 'EOF'
  # Auto run menu saat login
if [ -f /usr/local/bin/menu ]; then
    /usr/local/bin/menu
fi
EOF
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}  INSTALASI SELESAI                      ${NC}"
  echo -e "${GREEN}========================================${NC}"
}

main "$@"
