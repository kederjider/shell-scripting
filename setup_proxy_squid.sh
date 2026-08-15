#!/bin/bash
# =============================================================
#   ╔═╗╔═╗╔═╗╦ ╦╦═╗╦╔╦╗╔═╗╦═╗╔═╗
#   ║  ║ ║╠═╣║ ║╠╦╝║ ║ ║ ║╠╦╝║╣
#   ╚═╝╚═╝╩ ╩╚═╝╩╚═╩ ╩ ╚═╝╩╚═╚═╝
#
#   🦑 SQUID PROXY AUTO SETUP — VPS Ubuntu 24.04
#
#   ✨ Fitur : Auto Install • Konfigurasi Auth
#              Firewall UFW • Test Koneksi • Panduan Client
#              Android • Windows • Linux
#
#   ⚙ Jalankan dengan : sudo bash setup_proxy_squid.sh
# =============================================================

SQUID_CONF="/etc/squid/squid.conf"
SQUID_PASSWD="/etc/squid/passwd"
LOG_FILE="/tmp/squid_setup.log"

# =============================================
#  PALET WARNA
# =============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

if [ -n "$COLORTERM" ] && { [ "$COLORTERM" = "truecolor" ] || [ "$COLORTERM" = "24bit" ]; }; then
    G1='\033[38;5;39m'
    G2='\033[38;5;38m'
    G3='\033[38;5;44m'
    G4='\033[38;5;50m'
    G5='\033[38;5;51m'
else
    G1="$BLUE"; G2="$BLUE"; G3="$CYAN"; G4="$CYAN"; G5="$CYAN"
fi

# =============================================
#  UI KIT — konsisten dengan seri manager lain
# =============================================
hr() {
    local width=56 symbol="${1:-─}" out="" i
    for (( i=0; i<width; i++ )); do out+="$symbol"; done
    printf "${DIM}%s${NC}\n" "$out"
}

section() {
    printf "\n  ${G1}┌─${NC} ${BOLD}${G5}⚙ %b${NC} ${G1}─┐${NC}\n" "$1"
    hr
}

info_box() {
    printf "  ${G4}╭─${NC} ${BOLD}${G5}%b${NC}\n" "$1"
    shift
    for line in "$@"; do
        printf "  ${G4}│${NC}   %b\n" "$line"
    done
    printf "  ${G4}╰──────────────${NC}\n"
}

msg_ok()   { printf "  ${GREEN}✔${NC} %b\n" "$1"; }
msg_err()  { printf "  ${RED}✘${NC} %b\n" "$1"; }
msg_warn() { printf "  ${YELLOW}⚠${NC} %b\n" "$1"; }
msg_info() { printf "  ${G4}ℹ${NC} %b\n" "$1"; }
msg_step() { printf "  ${DIM}▸${NC} %b ${DIM}%b${NC}\n" "$1" "${2:-…}"; }

prompt() {
    printf "  ${MAGENTA}❯${NC} ${BOLD}%b${NC}" "$1"
}

spinner() {
    local pid=$1 msg=$2 sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 "$pid" 2>/dev/null; do
        for (( j=0; j<${#sp}; j++ )); do
            printf "\r  ${G5}%s${NC} ${DIM}%b${NC}   " "${sp:$j:1}" "$msg"
            sleep 0.08
        done
    done
    printf "\r\033[K"
}

progress_bar() {
    local pct=$1 label="${2:-Memproses…}"
    local width=32 filled=$(( pct * width / 100 ))
    printf "\r  ${G5}┃${NC}"
    for (( k=0; k<filled; k++ )); do printf "${G4}█${NC}"; done
    for (( k=filled; k<width; k++ )); do printf "${DIM}░${NC}"; done
    printf "${G5}┃${NC} ${G5}%3d%%${NC} ${DIM}%b${NC}   " "$pct" "$label"
}

separator_alert() {
    printf "  ${RED}▓▒░ %b ░▒▓${NC}\n" "$1"
}

typewriter() {
    local text="$1" delay="${2:-0.015}"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    printf "\n"
}

print_banner() {
    echo -e ""
    echo -e "  ${G1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}    ${G1}S${G2}Q${G3}U${G4}I${G5}D${NC} ${G4}P${G5}R${G5}O${G5}X${G5}Y${NC} ${G5}A${G5}U${G5}T${G5}O${NC} ${G5}S${G5}E${G5}T${G5}U${G5}P${NC}                                ${G1}║${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}    ${DIM}🦑 U B U N T U   2 4 . 0 4   V P S   v 1 . 0${NC}          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# =============================================
#  UTILITAS SISTEM
# =============================================
check_root() {
    if [ "$EUID" -ne 0 ]; then
        separator_alert "BUTUH AKSES ROOT"
        msg_err "Script ini wajib dijalankan dengan ${BOLD}sudo${NC}."
        echo ""
        msg_info "Jalankan ulang dengan:"
        echo -e "      ${G5}sudo bash setup_proxy_squid.sh${NC}"
        echo ""
        exit 1
    fi
}

check_ubuntu() {
    if [ ! -f /etc/os-release ]; then
        msg_warn "Tidak bisa mendeteksi OS."
        return
    fi
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        msg_warn "OS terdeteksi: ${BOLD}$PRETTY_NAME${NC} ${DIM}(bukan Ubuntu)${NC}"
        msg_info "Script dioptimalkan untuk Ubuntu 24.04 — lanjut dengan risiko sendiri."
    elif [[ "$VERSION_ID" != 24* ]]; then
        msg_warn "Versi Ubuntu: ${BOLD}$VERSION_ID${NC} ${DIM}(target: 24.04)${NC}"
        msg_info "Biasanya tetap jalan di Ubuntu 20.04/22.04/24.10."
    else
        msg_ok "OS terdeteksi: ${G5}$PRETTY_NAME${NC} ✓"
    fi
}

squid_installed() {
    dpkg -l squid 2>/dev/null | grep -q "^ii"
}

get_public_ip() {
    # Coba dari internet dulu, fallback ke IP lokal
    PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    if [ -z "$PUBLIC_IP" ]; then
        PUBLIC_IP=$(hostname -I | awk '{print $1}')
        msg_info "Pakai IP lokal ${DIM}(gagal deteksi IP publik)${NC}"
    fi
}

# =============================================
#  MENU 1 : INSTALL & SETUP LENGKAP
# =============================================
full_install() {
    section "🦑 INSTALL & SETUP SQUID PROXY"
    echo ""

    # --- Cek OS ---
    check_ubuntu
    echo ""

    if squid_installed; then
        msg_warn "Squid ${BOLD}sudah terinstall${NC}. Setup ini akan:"
        msg_info "1. Backup config lama → ${DIM}${SQUID_CONF}.backup${NC}"
        msg_info "2. Menimpa config dengan setup auth baru"
        echo ""
        prompt "Lanjutkan? ${DIM}(y/n)${NC} : "
        read cont
        [ "$cont" != "y" ] && [ "$cont" != "Y" ] && { msg_info "Dibatalkan."; return; }
    fi

    # --- Input konfigurasi ---
    echo ""
    info_box "⚙ Konfigurasi Proxy" \
             "Pilih port bebas ${DIM}(hindari 22=SSH, 80/443=web)${NC}" \
             "Rekomendasi: ${G5}3128${NC}, 8080, atau 54321"
    echo ""

    while true; do
        prompt "Port proxy ${DIM}(default: 3128)${NC} : "
        read PROXY_PORT
        PROXY_PORT=${PROXY_PORT:-3128}
        if [[ "$PROXY_PORT" =~ ^[0-9]+$ ]] && [ "$PROXY_PORT" -ge 1 ] && [ "$PROXY_PORT" -le 65535 ]; then
            # Cek apakah port sudah dipakai proses lain
            if ss -tlnp 2>/dev/null | grep -q ":$PROXY_PORT "; then
                msg_warn "Port $PROXY_PORT sudah dipakai proses lain. Pilih yang lain."
                continue
            fi
            break
        fi
        msg_err "Port tidak valid ${DIM}(1–65535)${NC}."
    done

    while true; do
        prompt "Username proxy ${DIM}(default: proxy)${NC} : "
        read PROXY_USER
        PROXY_USER=${PROXY_USER:-proxy}
        if [[ "$PROXY_USER" =~ ^[a-zA-Z0-9_-]+$ ]]; then break; fi
        msg_err "Username hanya boleh huruf/angka/_/-"
    done

    while true; do
        prompt "Password proxy ${DIM}(min 6 karakter)${NC} : "
        read -s PROXY_PASS
        echo ""
        if [ ${#PROXY_PASS} -ge 6 ]; then break; fi
        msg_err "Password terlalu pendek — minimal 6 karakter."
    done

    echo ""
    hr "─"

    # --- Step 1: Update & Install ---
    echo ""
    msg_step "Step 1/6" "apt update"
    apt-get update > "$LOG_FILE" 2>&1 &
    spinner $! "Update daftar paket (apt)..."
    wait $!

    msg_step "Step 2/6" "apt install squid apache2-utils"
    DEBIAN_FRONTEND=noninteractive apt-get install -y squid apache2-utils >> "$LOG_FILE" 2>&1 &
    spinner $! "Install squid + apache2-utils (htpasswd)..."
    wait $!

    if ! squid_installed; then
        msg_err "Install gagal! Lihat log: ${BOLD}$LOG_FILE${NC}"
        tail -10 "$LOG_FILE" | sed 's/^/      /'
        return
    fi
    msg_ok "Squid terinstall: ${G5}$(squid -v 2>/dev/null | head -1 | awk '{print $3}')${NC}"

    # --- Step 2: Backup config asli ---
    msg_step "Step 3/6" "Backup config bawaan"
    if [ -f "$SQUID_CONF" ] && [ ! -f "${SQUID_CONF}.backup" ]; then
        cp "$SQUID_CONF" "${SQUID_CONF}.backup"
        msg_ok "Backup → ${DIM}${SQUID_CONF}.backup${NC}"
    fi

    # --- Step 3: Tulis config baru dengan auth ---
    msg_step "Step 4/6" "Menulis konfigurasi auth"
    cat > "$SQUID_CONF" <<EOF
# ═══════════════════════════════════════════════
#  🦑 SQUID PROXY — dibuat oleh setup_proxy_squid.sh
#  Tanggal : $(date '+%Y-%m-%d %H:%M')
#  Port    : $PROXY_PORT | Auth : $PROXY_USER
# ═══════════════════════════════════════════════

# --- Autentikasi (username/password) ---
auth_param basic program /usr/lib/squid/basic_ncsa_auth $SQUID_PASSWD
auth_param basic realm Proxy Autentikasi
auth_param basic credentialsttl 2 hours

# --- Port aman yang boleh diakses ---
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 1025-65535
acl CONNECT method CONNECT

# --- Aturan akses ---
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

# Hanya user terautentikasi yang boleh pakai
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

# Tolak semua selain itu
http_access deny all

# --- Port proxy ---
http_port $PROXY_PORT

# --- DNS cepat & stabil ---
dns_nameservers 1.1.1.1 8.8.8.8

# --- Log dengan username (untuk monitor bandwidth per user) ---
logformat bandwidth %ts.%03tu %>a %<st %rm %ru %un
access_log daemon:/var/log/squid/access.log bandwidth

# --- Lain-lain ---
visible_hostname $(hostname)
coredump_dir /var/spool/squid
EOF
    msg_ok "Config auth ditulis ${DIM}($SQUID_CONF)${NC}"

    # --- Step 4: Buat user/password ---
    htpasswd -bc "$SQUID_PASSWD" "$PROXY_USER" "$PROXY_PASS" >/dev/null 2>&1
    chmod 640 "$SQUID_PASSWD"
    chown root:proxy "$SQUID_PASSWD" 2>/dev/null || chown root:root "$SQUID_PASSWD"
    msg_ok "User ${G5}$PROXY_USER${NC} dibuat di ${DIM}$SQUID_PASSWD${NC}"

    # --- Step 5: Firewall ---
    msg_step "Step 5/6" "Firewall UFW"
    if command -v ufw &>/dev/null; then
        ufw allow "$PROXY_PORT/tcp" >/dev/null 2>&1
        if ufw status | grep -q "active"; then
            msg_ok "UFW aktif — port ${G5}$PROXY_PORT${NC} dibuka."
        else
            msg_warn "UFW ${BOLD}tidak aktif${NC} ${DIM}(port tetap terbuka, tidak masalah)${NC}"
        fi
    else
        msg_info "UFW tidak ada — dilewati."
    fi
    msg_warn "Jika VPS dari cloud ${BOLD}(AWS/GCP/Oracle/dll)${NC}, buka juga port ${G5}$PROXY_PORT${NC} di Security Group panel!"

    # --- Step 6: Start service ---
    msg_step "Step 6/6" "Start & enable squid"
    squid -k parse >/dev/null 2>&1   # validasi config
    systemctl enable squid >/dev/null 2>&1
    systemctl restart squid >/dev/null 2>&1
    sleep 2

    if systemctl is-active --quiet squid; then
        msg_ok "Service squid ${GREEN}AKTIF${NC} & auto-start saat reboot. 🚀"
    else
        msg_err "Squid gagal start! Cek: ${BOLD}journalctl -u squid -n 30${NC}"
        return
    fi

    echo ""
    separator_alert "SETUP SELESAI — PROXY SIAP DIPAKAI"
    show_connection_info
    echo ""
    prompt "Tampilkan panduan client ${DIM}(Android/Windows/Linux)? (y/n)${NC} : "
    read showguide
    if [ "$showguide" = "y" ] || [ "$showguide" = "Y" ]; then
        show_client_guide
    fi
}

# =============================================
#  MENU 2 : UBAH PASSWORD / TAMBAH USER
# =============================================
manage_users() {
    section "👤 MANAJEMEN USER PROXY"
    echo ""

    if ! squid_installed; then
        msg_err "Squid belum terinstall — jalankan menu ${G5}[1]${NC} dulu."
        return
    fi

    # Tampilkan user yang ada
    echo -e "  ${DIM}── User terdaftar ──${NC}"
    if [ -f "$SQUID_PASSWD" ]; then
        while IFS=: read -r uname _; do
            echo -e "  ${G5}◆${NC} $uname"
        done < "$SQUID_PASSWD"
    else
        msg_info "Belum ada user."
    fi
    echo ""

    echo -e "  ${G4}(1)${NC} Tambah user baru"
    echo -e "  ${G4}(2)${NC} Ganti password user"
    echo -e "  ${G4}(3)${NC} Hapus user"
    echo -e "  ${G4}(4)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-4]${NC} : "
    read opt

    case $opt in
        1)
            prompt "Username baru : "
            read nu
            [ -z "$nu" ] && { msg_err "Wajib diisi."; return; }
            prompt "Password      : "
            read -s np; echo ""
            htpasswd -b "$SQUID_PASSWD" "$nu" "$np" >/dev/null 2>&1
            msg_ok "User ${G5}$nu${NC} ditambahkan."
            systemctl restart squid
            ;;
        2)
            prompt "Username : "
            read eu
            prompt "Password baru : "
            read -s ep; echo ""
            if grep -q "^$eu:" "$SQUID_PASSWD" 2>/dev/null; then
                htpasswd -b "$SQUID_PASSWD" "$eu" "$ep" >/dev/null 2>&1
                msg_ok "Password ${G5}$eu${NC} diperbarui."
                systemctl restart squid
            else
                msg_err "User '$eu' tidak ditemukan."
            fi
            ;;
        3)
            prompt "Username yang dihapus : "
            read du
            if grep -q "^$du:" "$SQUID_PASSWD" 2>/dev/null; then
                htpasswd -D "$SQUID_PASSWD" "$du" >/dev/null 2>&1
                msg_ok "User ${G5}$du${NC} dihapus."
                systemctl restart squid
            else
                msg_err "User '$du' tidak ditemukan."
            fi
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU 3 : INFO KONEKSI
# =============================================
show_connection_info() {
    get_public_ip
    local port=$(grep -E "^http_port" "$SQUID_CONF" 2>/dev/null | awk '{print $2}')
    port=${port:-3128}

    info_box "📡 INFORMASI KONEKSI PROXY" \
             "IP Server → ${G5}${PUBLIC_IP}${NC}" \
             "Port      → ${G5}${port}${NC}" \
             "Username  → ${G5}$(head -1 "$SQUID_PASSWD" 2>/dev/null | cut -d: -f1 || echo "—")${NC}" \
             "Password  → ${DIM}(tidak disimpan di script — password milikmu)${NC}" \
             "Format    → http://${PUBLIC_IP}:${port}"
}

show_info_menu() {
    section "📡 INFO KONEKSI"
    if ! squid_installed; then
        msg_err "Squid belum terinstall."
        return
    fi
    show_connection_info
    echo ""
    prompt "Tampilkan panduan client juga? (y/n) : "
    read g
    [ "$g" = "y" ] || [ "$g" = "Y" ] && show_client_guide
}

# =============================================
#  MENU 4 : TEST KONEKSI
# =============================================
test_proxy() {
    section "🧪 TEST KONEKSI PROXY"
    if ! squid_installed; then
        msg_err "Squid belum terinstall."
        return
    fi
    echo ""

    prompt "Username : "
    read tu
    prompt "Password : "
    read -s tp; echo ""

    local port=$(grep -E "^http_port" "$SQUID_CONF" | awk '{print $2}')
    port=${port:-3128}

    echo ""
    msg_step "Test 1" "Proxy hidup? ${DIM}(localhost:$port)${NC}"
    if ss -tlnp | grep -q ":$port "; then
        msg_ok "Port ${G5}$port${NC} mendengarkan. ✅"
    else
        msg_err "Port tidak aktif — cek ${BOLD}systemctl status squid${NC}."
        return
    fi

    msg_step "Test 2" "Lewat proxy dengan auth..."
    local result
    result=$(curl -s --max-time 10 -x "http://${tu}:${tp}@127.0.0.1:${port}" https://ifconfig.me 2>&1)
    if [[ "$result" =~ ^[0-9.]+$ ]]; then
        msg_ok "🎉 Proxy BERJALAN! IP keluar: ${G5}$result${NC}"
    else
        msg_err "Gagal: ${DIM}$result${NC}"
        msg_info "Kemungkinan: password salah / config error."
    fi
}

# =============================================
#  MENU 5 : UNINSTALL
# =============================================
uninstall_squid() {
    section "🗑 UNINSTALL SQUID"
    if ! squid_installed; then
        msg_warn "Squid tidak terinstall."
        return
    fi
    echo ""
    separator_alert "PERINGATAN — PROXY AKAN DIHAPUS"
    prompt "Yakin uninstall squid? ${DIM}(y/n)${NC} : "
    read u
    if [ "$u" = "y" ] || [ "$u" = "Y" ]; then
        local port=$(grep -E "^http_port" "$SQUID_CONF" 2>/dev/null | awk '{print $2}')
        systemctl stop squid 2>/dev/null
        apt-get purge -y squid >/dev/null 2>&1
        apt-get autoremove -y >/dev/null 2>&1
        [ -n "$port" ] && ufw delete allow "$port/tcp" >/dev/null 2>&1
        msg_ok "Squid dihapus. Config backup tetap di ${DIM}${SQUID_CONF}.backup${NC}"
    else
        msg_info "Dibatalkan."
    fi
}

# =============================================
#  PANDUAN CLIENT — ANDROID, WINDOWS, LINUX
# =============================================
show_client_guide() {
    get_public_ip
    local port=$(grep -E "^http_port" "$SQUID_CONF" 2>/dev/null | awk '{print $2}')
    port=${port:-3128}
    local user=$(head -1 "$SQUID_PASSWD" 2>/dev/null | cut -d: -f1)
    user=${user:-proxy}

    section "📱 PANDUAN PENGGUNAAN CLIENT"
    echo ""
    info_box "🔑 Data Koneksi (pakai ini di semua perangkat)" \
             "Host/Server → ${G5}${PUBLIC_IP}${NC}" \
             "Port        → ${G5}${port}${NC}" \
             "Username    → ${G5}${user}${NC}" \
             "Password    → ${G5}(password yang kamu buat)${NC}"
    echo ""

    info_box "🤖 ANDROID" \
             "${BOLD}Cara 1 — Aplikasi Drony (termudah, support password):${NC}" \
             "  1. Install ${G5}Drony${NC} dari Play Store" \
             "  2. Buka Drony → tab ${BOLD}Settings${NC} → ${BOLD}WiFi${NC}" \
             "  3. Pilih jaringan WiFi-mu → ${BOLD}Edit${NC}" \
             "  4. Isi: Hostname = ${G5}${PUBLIC_IP}${NC}" \
             "           Port    = ${G5}${port}${NC}" \
             "           Username = ${G5}${user}${NC} | Password = (punya kamu)" \
             "  5. Kembali → tekan ${BOLD}ON${NC} di tab Log" \
             "  6. Semua koneksi HP kini lewat proxy ✓" \
             "" \
             "${BOLD}Cara 2 — WiFi Proxy bawaan Android:${NC}" \
             "  Settings → WiFi → tahan jaringan → ${BOLD}Modify${NC} → ${BOLD}Advanced${NC}" \
             "  → Proxy: ${BOLD}Manual${NC} → Host: ${G5}${PUBLIC_IP}${NC} → Port: ${G5}${port}${NC}" \
             "  ${YELLOW}⚠ Cara ini TIDAK support username/password${NC}" \
             "  ${YELLOW}  (hanya untuk browser yang menampilkan prompt login)${NC}" \
             "" \
             "${BOLD}Cara 3 — HTTP Injector / v2rayNG:${NC}" \
             "  Untuk kebutuhan tunneling lanjutan."
    echo ""

    info_box "💻 WINDOWS" \
             "${BOLD}Cara 1 — Firefox (paling mudah, support password):${NC}" \
             "  1. Settings → General → ${BOLD}Network Settings → Settings${NC}" \
             "  2. Pilih ${BOLD}Manual proxy configuration${NC}" \
             "  3. HTTP Proxy: ${G5}${PUBLIC_IP}${NC} | Port: ${G5}${port}${NC}" \
             "  4. Centang ${BOLD}Use this proxy server for all protocols${NC}" \
             "  5. Saat browsing pertama kali → muncul pop-up login" \
             "     → isi ${G5}${user}${NC} + password ✓" \
             "" \
             "${BOLD}Cara 2 — Proxifier (seluruh sistem, support password):${NC}" \
             "  1. Install ${G5}Proxifier${NC} → Proxy Servers → Add" \
             "  2. Server: ${G5}${PUBLIC_IP}${NC} | Port: ${G5}${port}${NC} | Type: HTTPS" \
             "  3. Isi username ${G5}${user}${NC} + password → OK" \
             "  4. Semua aplikasi Windows lewat proxy ✓" \
             "" \
             "${BOLD}Cara 3 — Terminal / CMD / PowerShell:${NC}" \
             "  ${CYAN}set HTTPS_PROXY=http://${user}:PASSWORD@${PUBLIC_IP}:${port}${NC}" \
             "  ${CYAN}set HTTP_PROXY=http://${user}:PASSWORD@${PUBLIC_IP}:${port}${NC}" \
             "  Lalu jalankan: ${CYAN}curl https://ifconfig.me${NC}"
    echo ""

    info_box "🐧 LINUX" \
             "${BOLD}Cara 1 — Environment variable (terminal):${NC}" \
             "  ${CYAN}export http_proxy=\"http://${user}:PASSWORD@${PUBLIC_IP}:${port}\"${NC}" \
             "  ${CYAN}export https_proxy=\"http://${user}:PASSWORD@${PUBLIC_IP}:${port}\"${NC}" \
             "  Permanen? Tambahkan ke ${DIM}~/.bashrc${NC} lalu ${CYAN}source ~/.bashrc${NC}" \
             "" \
             "${BOLD}Cara 2 — GNOME Desktop:${NC}" \
             "  Settings → ${BOLD}Network${NC} → ${BOLD}Network Proxy${NC} → Manual" \
             "  HTTP Proxy: ${G5}${PUBLIC_IP}${NC} | Port: ${G5}${port}${NC}" \
             "  (Username/password diminta saat koneksi pertama)" \
             "" \
             "${BOLD}Cara 3 — Test cepat via curl:${NC}" \
             "  ${CYAN}curl -x http://${user}:PASSWORD@${PUBLIC_IP}:${port} https://ifconfig.me${NC}" \
             "  Jika muncul IP-mu = proxy jalan ✓" \
             "" \
             "${BOLD}Cara 4 — apt lewat proxy:${NC}" \
             "  ${CYAN}sudo apt -o Acquire::http::Proxy=\"http://${user}:PASSWORD@${PUBLIC_IP}:${port}\" update${NC}"
    echo ""

    info_box "⚠️ CATATAN PENTING" \
             "• Jangan bagikan password proxy ke orang lain" \
             "• Ganti password berkala lewat menu ${G5}[2]${NC}" \
             "• Jika gagal connect: cek port terbuka di Security Group VPS" \
             "• Lihat log pemakaian: ${CYAN}tail -f /var/log/squid/access.log${NC}"
}

# =============================================
#  MENU 7 : MONITOR KONEKSI & BANDWIDTH
# =============================================

# Konversi bytes → format manusia (B/KB/MB/GB)
human_bytes() {
    awk -v b="${1:-0}" 'BEGIN {
        if      (b >= 1073741824) printf "%.2f GB", b/1073741824
        else if (b >= 1048576)    printf "%.2f MB", b/1048576
        else if (b >= 1024)       printf "%.2f KB", b/1024
        else                      printf "%d B", b
    }'
}

get_proxy_port() {
    local p=$(grep -E "^http_port" "$SQUID_CONF" 2>/dev/null | awk '{print $2}')
    echo "${p:-3128}"
}

# Satu snapshot lengkap: koneksi aktif + statistik bandwidth
monitor_snapshot() {
    local port=$(get_proxy_port)
    local log=/var/log/squid/access.log

    # ── 1. Klien yang SEDANG terhubung (koneksi TCP aktif ke port proxy) ──
    echo ""
    info_box "🔌 Klien yang Sedang Terhubung ${DIM}(real-time, port $port)${NC}"
    # ss: $1=state $2=recv $3=send $4=local(server:port) $5=peer(klien)
    local active_ips
    active_ips=$(ss -Htn 2>/dev/null \
                 | awk -v p=":$port" '$4 ~ p"$" {print $5}' \
                 | rev | cut -d: -f2- | rev | sort | uniq -c | sort -rn)

    if [ -z "$active_ips" ]; then
        msg_info "Tidak ada klien yang terhubung saat ini."
    else
        printf "  ${DIM}┌──────────────────────┬────────────┐${NC}\n"
        printf "  ${DIM}│ ${BOLD}${G5}IP Klien${NC}            │ ${BOLD}${G5}Koneksi${NC}  ${DIM}│${NC}\n"
        printf "  ${DIM}├──────────────────────┼────────────┤${NC}\n"
        local total_conn=0
        while read -r cnt ip; do
            printf "  ${DIM}│${NC} ${CYAN}%-20s${NC} ${DIM}│${NC} %s koneksi   ${DIM}│${NC}\n" "$ip" "$cnt"
            total_conn=$((total_conn + cnt))
        done <<< "$active_ips"
        printf "  ${DIM}└──────────────────────┴────────────┘${NC}\n"
        local unique=$(echo "$active_ips" | wc -l)
        msg_info "Total: ${G5}$total_conn${NC} koneksi dari ${G5}$unique${NC} klien berbeda"
    fi

    # ── 2. Statistik Bandwidth dari log squid ──
    echo ""
    if [ ! -f "$log" ]; then
        info_box "📦 Bandwidth Terpakai" "Belum ada log — proxy belum pernah dipakai."
        return
    fi

    local start_day=$(date -d "today 00:00" +%s)
    local start_month=$(date -d "$(date +%Y-%m-01) 00:00" +%s)

    # Deteksi otomatis 2 format log:
    #  • Bawaan squid : ts tr ip status bytes method url ...
    #  • Custom (menu 1 versi baru): ts ip bytes method url user
    local totals
    totals=$(awk -v d="$start_day" -v m="$start_month" '
        NF >= 3 {
            if ($4 ~ /^[A-Z_]+\/[0-9]+$/) { ip=$3; bytes=$5; user="-" }   # format bawaan
            else                            { ip=$2; bytes=$3; user=(NF>=6 ? $6 : "-") }
            total += bytes; req++
            if ($1 >= d) { tday += bytes; rday++ }
            if ($1 >= m)  tmon += bytes
            ip_b[ip] += bytes; ip_r[ip]++
            if (user != "-") user_b[user] += bytes
        }
        END {
            printf "TOTAL %d %d\n", total, req
            printf "DAY %d %d\n", tday, rday
            printf "MONTH %d\n", tmon
            for (i in ip_b)   printf "IP %s %d %d\n", i, ip_b[i], ip_r[i]
            for (u in user_b) printf "USER %s %d\n", u, user_b[u]
        }' "$log" 2>/dev/null)

    local total_bytes=$(echo "$totals" | awk '/^TOTAL/{print $2}')
    local total_req=$(echo "$totals"   | awk '/^TOTAL/{print $3}')
    local day_bytes=$(echo "$totals"   | awk '/^DAY/{print $2}')
    local day_req=$(echo "$totals"     | awk '/^DAY/{print $3}')
    local month_bytes=$(echo "$totals" | awk '/^MONTH/{print $2}')

    info_box "📦 Bandwidth Terpakai ${DIM}(sejak rotasi log terakhir)${NC}" \
             "Hari ini  → ${G5}$(human_bytes "$day_bytes")${NC} ${DIM}($day_req request)${NC}" \
             "Bulan ini → ${G5}$(human_bytes "$month_bytes")${NC}" \
             "Total     → ${BOLD}${G5}$(human_bytes "$total_bytes")${NC} ${DIM}($total_req request)${NC}"

    # ── 3. Top klien per bandwidth ──
    echo ""
    info_box "🏆 Top Klien per Bandwidth"
    printf "  ${DIM}┌──────────────────────┬─────────────┬───────────┐${NC}\n"
    printf "  ${DIM}│ ${BOLD}${G5}IP Klien${NC}            │ ${BOLD}${G5}Bandwidth${NC}   │ ${BOLD}${G5}Request${NC}  ${DIM}│${NC}\n"
    printf "  ${DIM}├──────────────────────┼─────────────┼───────────┤${NC}\n"
    echo "$totals" | grep "^IP " | sort -k3 -rn | head -10 | while read -r _ ip bytes req; do
        printf "  ${DIM}│${NC} ${CYAN}%-20s${NC} ${DIM}│${NC} %-11s ${DIM}│${NC} %-9s ${DIM}│${NC}\n" "$ip" "$(human_bytes "$bytes")" "$req"
    done
    printf "  ${DIM}└──────────────────────┴─────────────┴───────────┘${NC}\n"

    # ── 4. Pemakaian per username (auth) ──
    local user_lines
    user_lines=$(echo "$totals" | grep "^USER " | sort -k3 -rn)
    if [ -n "$user_lines" ]; then
        echo ""
        info_box "👤 Bandwidth per Username"
        while read -r _ uname bytes; do
            printf "  ${G5}◆${NC} ${BOLD}%-16s${NC} → %s\n" "$uname" "$(human_bytes "$bytes")"
        done <<< "$user_lines"
    fi

    # ── 5. Log file & rotasi ──
    echo ""
    local logsize=$(stat -c%s "$log" 2>/dev/null || echo 0)
    msg_info "Ukuran file log: ${G5}$(human_bytes "$logsize")${NC} ${DIM}($log)${NC}"
    msg_info "Rotasi log otomatis tiap minggu ${DIM}(/etc/logrotate.d/squid)${NC}"
}

monitor_menu() {
    section "📊 MONITOR KONEKSI & BANDWIDTH"
    if ! squid_installed; then
        msg_err "Squid belum terinstall — jalankan menu ${G5}[1]${NC} dulu."
        return
    fi
    if ! systemctl is-active --quiet squid; then
        msg_warn "Squid sedang tidak aktif: ${CYAN}systemctl start squid${NC}"
    fi

    echo ""
    echo -e "  ${G4}(1)${NC} Snapshot ${DIM}(sekali lihat, detail lengkap)${NC}"
    echo -e "  ${G4}(2)${NC} Live monitor ${DIM}(refresh tiap 5 detik — Ctrl+C berhenti)${NC}"
    echo -e "  ${G4}(3)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-3]${NC} : "
    read opt

    case $opt in
        1)
            monitor_snapshot
            ;;
        2)
            msg_info "Live monitor dimulai... tekan ${BOLD}Ctrl+C${NC} untuk berhenti."
            sleep 1
            while true; do
                clear
                print_banner
                printf "  ${DIM}LIVE MONITOR — refresh tiap 5 detik ${NC} ${G5}●${NC}  %s\n" "$(date '+%H:%M:%S')"
                monitor_snapshot
                sleep 5
            done
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU UTAMA
# =============================================
show_menu() {
    clear
    print_banner

    # Status ringkas
    if squid_installed; then
        if systemctl is-active --quiet squid; then
            printf "  ${DIM}Status:${NC} ${GREEN}●${NC} squid ${GREEN}AKTIF${NC}   ${DIM}│${NC}  🦑 port %s\n" "$(grep -E '^http_port' "$SQUID_CONF" 2>/dev/null | awk '{print $2}' || echo '?')"
        else
            printf "  ${DIM}Status:${NC} ${RED}●${NC} squid ${RED}MATI${NC} ${DIM}(terinstall tapi tidak jalan)${NC}\n"
        fi
    else
        printf "  ${DIM}Status:${NC} ${YELLOW}○${NC} squid belum terinstall\n"
    fi
    echo ""

    echo -e "  ${G1}╭───${NC} ${BOLD}${G5}MENU UTAMA${NC}"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}│${NC}   ${G5}01${NC} ${CYAN}🦑${NC}  Install & Setup Squid ${DIM}(auto lengkap)${NC}"
    echo -e "  ${G1}│${NC}   ${G5}02${NC} ${CYAN}👤${NC}  Manajemen User ${DIM}(tambah/ubah/hapus)${NC}"
    echo -e "  ${G1}│${NC}   ${G5}03${NC} ${CYAN}📡${NC}  Info Koneksi & Panduan Client"
    echo -e "  ${G1}│${NC}   ${G5}04${NC} ${CYAN}🧪${NC}  Test Koneksi Proxy"
    echo -e "  ${G1}│${NC}   ${G5}05${NC} ${CYAN}🗑${NC}  Uninstall Squid"
    echo -e "  ${G1}│${NC}   ${G5}06${NC} ${CYAN}❓${NC}  Panduan Client Saja"
    echo -e "  ${G1}│${NC}   ${G5}07${NC} ${CYAN}📊${NC}  Monitor Koneksi & Bandwidth"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}│${NC}   ${RED}00${NC} ${RED}🚪${NC}  Keluar"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}╰${NC}"
    echo ""

    prompt "Pilih menu ${DIM}[00–07]${NC} : "
    read choice

    case $choice in
        1|01)  full_install ;;
        2|02)  manage_users ;;
        3|03)  show_info_menu ;;
        4|04)  test_proxy ;;
        5|05)  uninstall_squid ;;
        6|06)  show_client_guide ;;
        7|07)  monitor_menu ;;
        0|00)  goodbye ;;
        *)     echo ""; msg_err "Pilihan tidak valid." ;;
    esac
}

goodbye() {
    echo ""
    typewriter "  🦑 Squid Setup selesai. Semoga proxy-nya lancar! 👋" 0.015
    echo ""
    exit 0
}

# =============================================
#  INIT — satu siklus eksekusi
# =============================================
trap 'echo ""; echo -e "  ${YELLOW}⚠ Dihentikan oleh user.${NC}"; exit 1' INT TERM

check_root
show_menu

# Setelah aksi: tanya sekali, lanjut atau keluar
echo ""
hr
prompt "Kembali ke menu? ${DIM}(Enter = ya / n = keluar)${NC} : "
read -r again
if [ "$again" != "n" ] && [ "$again" != "N" ]; then
    show_menu
fi
