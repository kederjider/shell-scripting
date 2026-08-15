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

# Unduh satu file dari repo dan pasang ke /usr/local/bin.
# mode default 755; pakai 777 untuk file data (ua.txt, .env).
install_file() {
  local name="$1"
  local src="$2"
  local mode="${3:-755}"
  local url="https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/$src"

  if wget -q -O "/usr/local/bin/$name" "$url"; then
    chmod "$mode" "/usr/local/bin/$name"
    ok "$name terinstall -> /usr/local/bin/$name"
  else
    warn "Gagal mengunduh '$src' — pastikan file sudah di-push ke repo"
  fi
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
      unzip tar gzip bzip2 xz \
      gcc make procps-ng
  elif command -v yum >/dev/null 2>&1; then
    yum install -y \
      python3 python3-pip \
      wget curl sed git ca-certificates \
      unzip tar gzip bzip2 xz \
      gcc make procps-ng
  else
    fail "Tidak ditemukan package manager yang didukung (dnf/yum)"
  fi
}

install_arch() {
  log "Menginstall paket dasar untuk Arch Linux..."
  pacman -Sy --noconfirm
  pacman -S --needed --noconfirm \
    python python-pip \
    wget curl sed git ca-certificates \
    unzip tar gzip bzip2 xz \
    base-devel procps-ng
}

install_alpine() {
  log "Menginstall paket dasar untuk Alpine Linux..."
  apk add --no-cache \
    python3 py3-pip \
    wget curl sed git ca-certificates \
    unzip tar gzip bzip2 xz \
    build-base
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
  echo -e "  ${CYAN}wget https://github.com/....${NC}"
  echo -e "  ${CYAN}git clone https://github.com/....${NC}"
  echo -e "  ${CYAN}python3 --version${NC}"
  echo -e "  ${CYAN}pip3 --version${NC}"
  echo -e "  ${CYAN}zerotier${NC}"

  log "Mengunduh dan memasang tools dari GitHub..."
  install_file a-reboot a-reboot.sh
  install_file cek_service cek_service.sh
  install_file ddos ddos.py
  install_file disk disk.sh
  install_file dns-records dns-records.sh
  install_file install-domain-finder install-domain-finder.sh
  install_file kirim_email kirim_email.py
  install_file loading loading.sh
  install_file lookup-dns lookup-dns.sh
  install_file m-ddos m-ddos.sh
  install_file install-sherlock install-sherlock.sh
  install_file m-domain m-domain.py
  install_file m-monitor m-monitor.sh
  install_file m-screen m-screen.sh
  install_file m-nginx m-nginx.sh
  install_file m-tailscale m-tailscale.sh
  install_file m-tracker m-tracker.py
  install_file m-zerotier m-zerotier.sh
  install_file m-setting m-setting.sh
  install_file m-user-finder m-user-finder.sh
  install_file newmenu newmenu.sh
  install_file mode-hack mode-hack.sh
  install_file nobody-spam nobody-spam.py
  install_file root root.sh
  install_file service_manager service_manager.sh
  install_file sub-domain-finder sub-domain-finder.sh
  install_file ua.txt ua.txt 777
  install_file spam_post spam_post.py
  install_file .env env.example 666
  install_file editfile editfile.sh
  install_file ip_to_host ip_to_host.py
  install_file host_to_ip host_to_ip.py
  install_file m-ip-to-host m-ip-to-host.sh
  install_file m-host-to-ip m-host-to-ip.sh
  install_file pinghost pinghost.sh
  install_file ddns ddns.sh
  install_file upgrader upgrader.sh
  install_file anti_spam anti_spam.py
  install_file spam_detector spam_detector.py
  install_file pentester_tools pentester_tools.py
  install_file m-spam-post m-spam-post.sh
  install_file openssl-encrypt openssl-encrypt.sh
  install_file ssh_manager ssh_manager.sh
  install_file setup_proxy_squid setup_proxy_squid.sh

  if ! grep -q "Auto run newmenu saat login" /root/.bashrc 2>/dev/null; then
    cat >> /root/.bashrc << 'EOF'
# Auto run newmenu saat login
if [ -f /usr/local/bin/newmenu ]; then
    /usr/local/bin/newmenu
fi
EOF
    ok "Autostart newmenu ditambahkan ke /root/.bashrc"
  else
    warn "Autostart newmenu sudah ada di /root/.bashrc, dilewati"
  fi
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}  INSTALASI SELESAI                      ${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo -e "${YELLOW} Untuk menjalankan newmenu, ketik: newmenu    ${NC}"
  echo -e "${YELLOW} jangan lupa edit .env sesuai kebutuhan    ${NC}"
  echo -e "${YELLOW} lokasi ada di /usr/local/bin/.env    ${NC}"
  echo -e "${GREEN}========================================${NC}"
}

main "$@"
