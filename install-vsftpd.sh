#!/bin/bash
#
# install-vsftpd.sh
# Script otomatis untuk install & konfigurasi vsftpd di Ubuntu
#

# ========================= WARNA & GAYA =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

DIVIDER="${CYAN}════════════════════════════════════════════════════════════${RESET}"

print_info()    { echo -e "${BLUE}ℹ️  $1${RESET}"; }
print_success() { echo -e "${GREEN}✅ $1${RESET}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
print_error()   { echo -e "${RED}❌ $1${RESET}"; }
print_step()    { echo -e "\n${MAGENTA}${BOLD}➤ $1${RESET}"; }

banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "   ______ _______ _____    _____           _        _ _           "
    echo "  |  ____|__   __|  __ \  |_   _|         | |      | | |          "
    echo "  | |__     | |  | |__) |   | |  _ __  ___| |_ __ _| | | ___ _ __ "
    echo "  |  __|    | |  |  ___/    | | | '_ \/ __| __/ _\` | | |/ _ \ '__|"
    echo "  | |       | |  | |       _| |_| | | \__ \ || (_| | | |  __/ |   "
    echo "  |_|       |_|  |_|      |_____|_| |_|___/\__\__,_|_|_|\___|_|   "
    echo -e "${RESET}"
    echo -e "${CYAN}          🚀 vsftpd Auto Installer & Configurator 🚀${RESET}"
    echo -e "$DIVIDER"
}

# ========================= CEK ROOT =========================
if [[ $EUID -ne 0 ]]; then
    print_error "Script ini harus dijalankan sebagai root (gunakan sudo)."
    exit 1
fi

banner

# ========================= CEK INSTALASI VSFTPD =========================
check_vsftpd_installed() {
    if dpkg -s vsftpd &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_vsftpd() {
    print_step "Menginstall vsftpd..."
    apt update -y
    apt install vsftpd -y

    if ! check_vsftpd_installed; then
        print_error "Instalasi vsftpd gagal. Periksa koneksi internet atau repository."
        exit 1
    fi

    print_success "vsftpd berhasil diinstall."

    print_step "Mengaktifkan service vsftpd (auto enable)..."
    systemctl enable --now vsftpd
    print_success "Service vsftpd telah diaktifkan."
}

print_step "Mengecek status instalasi vsftpd..."
if check_vsftpd_installed; then
    print_success "vsftpd sudah terinstall di sistem ini."
else
    print_warning "vsftpd belum terinstall."
    read -p "$(echo -e ${YELLOW}"Apakah Anda ingin menginstallnya sekarang? (y/n): "${RESET})" INSTALL_CHOICE
    INSTALL_CHOICE=$(echo "$INSTALL_CHOICE" | tr '[:upper:]' '[:lower:]')

    case "$INSTALL_CHOICE" in
        y|yes|iya)
            install_vsftpd
            ;;
        n|no|tidak|t)
            print_info "Instalasi dibatalkan oleh pengguna. Script dihentikan."
            exit 0
            ;;
        *)
            print_error "Pilihan tidak valid. Script dihentikan."
            exit 1
            ;;
    esac
fi

# ========================= DIREKTORI SHARE =========================
print_step "Konfigurasi direktori FTP share"
read -p "$(echo -e ${CYAN}"Masukkan path direktori yang ingin di-share [default: /srv/ftp/share]: "${RESET})" SHARE_DIR
SHARE_DIR=${SHARE_DIR:-/srv/ftp/share}

if [ ! -d "$SHARE_DIR" ]; then
    print_info "Direktori belum ada, membuat direktori baru: $SHARE_DIR"
    mkdir -p "$SHARE_DIR"
else
    print_info "Direktori sudah ada: $SHARE_DIR"
fi

chmod 777 "$SHARE_DIR"
print_success "Permission direktori '$SHARE_DIR' diatur ke 777."

# ========================= BACKUP & KONFIGURASI =========================
print_step "Backup konfigurasi vsftpd"
if [ -f /etc/vsftpd.conf ]; then
    cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
    print_success "Backup konfigurasi disimpan di /etc/vsftpd.conf.backup"
else
    print_warning "/etc/vsftpd.conf tidak ditemukan, membuat file konfigurasi baru."
    touch /etc/vsftpd.conf
fi

print_step "Menulis konfigurasi baru ke /etc/vsftpd.conf"
cat > /etc/vsftpd.conf << 'EOF'
listen=YES
listen_ipv6=NO

anonymous_enable=NO
local_enable=YES
write_enable=YES

local_umask=022

chroot_local_user=YES
allow_writeable_chroot=YES

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
EOF
print_success "Konfigurasi vsftpd berhasil diperbarui."

print_step "Merestart service vsftpd"
systemctl restart vsftpd
print_success "Service vsftpd berhasil direstart."

# ========================= BUAT USER FTP =========================
print_step "Konfigurasi user FTP"
read -p "$(echo -e ${CYAN}"Masukkan nama user FTP [default: ftpuser]: "${RESET})" FTP_USER
FTP_USER=${FTP_USER:-ftpuser}

if id "$FTP_USER" &> /dev/null; then
    print_info "User '$FTP_USER' sudah ada, melewati pembuatan user baru."
else
    useradd -m "$FTP_USER"
    print_success "User '$FTP_USER' berhasil dibuat."
fi

read -s -p "$(echo -e ${CYAN}"Masukkan password untuk user '$FTP_USER' (kosongkan untuk generate otomatis): "${RESET})" FTP_PASS
echo
if [ -z "$FTP_PASS" ]; then
    FTP_PASS=$(openssl rand -base64 12)
    print_info "Password otomatis digenerate."
fi
echo "$FTP_USER:$FTP_PASS" | chpasswd
print_success "Password untuk user '$FTP_USER' berhasil diatur."

print_step "Mengarahkan home directory user ke direktori share"
usermod -d "$SHARE_DIR" "$FTP_USER"
chown -R "$FTP_USER:$FTP_USER" "$SHARE_DIR"
print_success "User '$FTP_USER' sekarang diarahkan ke '$SHARE_DIR' dengan kepemilikan yang sesuai."

# ========================= KONFIGURASI FIREWALL =========================
print_step "Mengecek dan mengonfigurasi UFW (firewall)"

if ! command -v ufw &> /dev/null; then
    print_warning "UFW belum terinstall, menginstall sekarang..."
    apt install ufw -y
fi

systemctl enable --now ufw &> /dev/null
ufw --force enable

WIFI_IP=$(hostname -I | awk '{print $1}')

if [ -z "$WIFI_IP" ]; then
    print_warning "Tidak dapat mendeteksi IP secara otomatis, menggunakan aturan port default."
    ufw allow 21/tcp
    ufw allow 40000:40100/tcp
else
    print_info "IP terdeteksi: $WIFI_IP"
    SUBNET="${WIFI_IP%.*}.0/24"
    ufw allow from "$SUBNET" to any port 21 proto tcp
    ufw allow from "$SUBNET" to any port 40000:40100 proto tcp
    ufw allow 21/tcp
    print_success "Aturan firewall untuk subnet $SUBNET berhasil ditambahkan."
fi

ufw reload
print_success "Firewall (UFW) telah dikonfigurasi dan diaktifkan."

# ========================= RINGKASAN AKHIR =========================
echo -e "\n$DIVIDER"
echo -e "${GREEN}${BOLD}🎉 INSTALASI & KONFIGURASI VSFTPD BERHASIL DISELESAIKAN! 🎉${RESET}"
echo -e "$DIVIDER"
echo -e "${CYAN}📡 Port FTP           :${RESET} 21 (kontrol), 40000-40100 (passive)"
echo -e "${CYAN}📁 Direktori Share    :${RESET} $SHARE_DIR"
echo -e "${CYAN}👤 Username FTP       :${RESET} $FTP_USER"
echo -e "${CYAN}🔑 Password FTP       :${RESET} $FTP_PASS"
echo -e "${CYAN}🌐 IP Server (WiFi)   :${RESET} ${WIFI_IP:-tidak terdeteksi}"
echo -e "$DIVIDER"
echo -e "${YELLOW}💡 Simpan informasi login di atas dengan aman.${RESET}"
echo -e "${YELLOW}💡 Backup konfigurasi lama tersedia di /etc/vsftpd.conf.backup${RESET}"
echo -e "$DIVIDER\n"
