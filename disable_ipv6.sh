#!/bin/bash
#
# disable_ipv6.sh
# Cek status IPv6 di VPS. Jika masih enable -> disable & buat permanen.
# Jika sudah disable -> biarkan dan tampilkan info.
#
# Jalankan sebagai root: sudo bash disable_ipv6.sh

set -e

SYSCTL_CONF="/etc/sysctl.d/99-disable-ipv6.conf"

# ──────────────────────────────────────────────
#  PALET WARNA
# ──────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'

# ──────────────────────────────────────────────
#  FUNGSI BANTUAN: PESAN BERWARNA + EMOJI
# ──────────────────────────────────────────────
msg_info()  { echo -e "  ${CYAN}ℹ️  ${1}${RESET}"; }
msg_ok()    { echo -e "  ${GREEN}✅  ${1}${RESET}"; }
msg_err()   { echo -e "  ${RED}❌  ${1}${RESET}"; }
msg_warn()  { echo -e "  ${YELLOW}⚠️  ${1}${RESET}"; }
msg_step()  { echo -e "  ${BBLUE}⚙️  ${1}${RESET}"; }
msg_save()  { echo -e "  ${MAGENTA}💾  ${1}${RESET}"; }
msg_net()   { echo -e "  ${BMAGENTA}🌐  ${1}${RESET}"; }
msg_done()  { echo -e "  ${BGREEN}🏁  ${1}${RESET}"; }

garis() { echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

# ──────────────────────────────────────────────
#  HEADER
# ──────────────────────────────────────────────
tampil_header() {
    echo ""
    garis
    echo -e "${BCYAN}     🌐🔒  DISABLE IPV6 VPS  🔓🌐${RESET}"
    garis
}

# Pastikan dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    echo ""
    msg_err "Script ini harus dijalankan sebagai root (gunakan sudo)."
    echo ""
    exit 1
fi

# Fungsi untuk cek status disable_ipv6 pada semua interface
check_ipv6_status() {
    local all_status
    all_status=$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo "0")
    echo "$all_status"
}

tampil_header
msg_info "Cek status IPv6 saat ini ..."
echo ""

CURRENT_STATUS=$(check_ipv6_status)

if [ "$CURRENT_STATUS" = "1" ]; then
    msg_net "Status IPv6 : ${BGREEN}DISABLED${RESET}"
    msg_ok "IPv6 sudah dalam kondisi DISABLED. Tidak ada perubahan yang dilakukan."
    garis
    if ip -6 addr show 2>/dev/null | grep -q "inet6"; then
        msg_warn "Masih ada alamat IPv6 residual pada interface (biasanya hilang setelah reboot)."
    else
        msg_ok "Tidak ada alamat IPv6 aktif ditemukan."
    fi
    msg_done "Selesai. Tidak ada yang perlu dilakukan."
    echo ""
    exit 0
fi

msg_net "Status IPv6 : ${BRED}AKTIF (ENABLED)${RESET}"
msg_warn "IPv6 masih AKTIF. Melakukan proses disable ..."
echo ""

# 1. Disable secara langsung (runtime) melalui sysctl
msg_step "Mematikan IPv6 secara langsung (runtime) via sysctl ..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1     > /dev/null
sysctl -w net.ipv6.conf.default.disable_ipv6=1 > /dev/null
sysctl -w net.ipv6.conf.lo.disable_ipv6=1      > /dev/null
msg_ok "IPv6 dimatikan untuk sesi berjalan saat ini."

# 2. Buat perubahan permanen agar bertahan setelah reboot
msg_step "Membuat konfigurasi permanen di ${BOLD}$SYSCTL_CONF${RESET} ..."
cat > "$SYSCTL_CONF" << 'EOF'
# Disable IPv6 (dibuat otomatis oleh disable_ipv6.sh)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
msg_save "File konfigurasi berhasil dibuat."

# 3. Terapkan konfigurasi sysctl
msg_step "Menerapkan konfigurasi sysctl ..."
sysctl -p "$SYSCTL_CONF" > /dev/null

# 4. Verifikasi ulang
msg_info "Verifikasi ulang status IPv6 ..."
NEW_STATUS=$(check_ipv6_status)

echo ""
if [ "$NEW_STATUS" = "1" ]; then
    msg_ok "BERHASIL: IPv6 telah didisable."
    msg_save "Pengaturan disimpan permanen di: ${BOLD}$SYSCTL_CONF${RESET}"
else
    msg_err "IPv6 belum sepenuhnya nonaktif."
    msg_warn "Silakan cek konfigurasi jaringan/GRUB secara manual."
fi
garis
msg_done "Selesai. IPv6 sudah dinonaktifkan."
echo ""