#!/bin/bash

# ==================== WARNA ====================
Green="\e[92;1m"
CYAN='\033[0;36m'
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
DF='\e[39m'
Bold='\e[1m'
BOLD='\033[1m'
g="\033[1;92m"
y='\033[1;33m' #yellow
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHT='\033[0;37m'
grenbo="\e[92;1m"
dkblu="\033[34m"
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
# Getting

# ==================== FUNGSI UTAMA ====================
wget_github() {
    if [ $# -ne 2 ]; then
        echo -e "${RED}❌  Usage: wget_github <path/nama_script.sh> <url atau username/repo/branch/file.sh>${NC}"
        return 1
    fi

    local dest="$1"
    local source="$2"
    local url=""

    # Deteksi apakah input kedua sudah full URL atau hanya path GitHub
    if [[ "$source" =~ ^https?:// ]]; then
        # Jika URL GitHub biasa (github.com), konversi ke raw
        if [[ "$source" =~ github\.com ]]; then
            url=$(echo "$source" | sed -E 's|https?://github\.com/|https://raw.githubusercontent.com/|; s|/blob/|/|; s|/tree/|/|')
        else
            url="$source"
        fi
    else
        # Hapus /blob/ atau /tree/ jika ada dalam path GitHub
        source=$(echo "$source" | sed -E 's|/blob/|/|; s|/tree/|/|')
        url="https://raw.githubusercontent.com/${source}"
    fi

    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📥  Informasi Unduhan:${NC}"
    echo -e "   ${BLUE}• Sumber   :${NC} ${url}"
    echo -e "   ${BLUE}• Tujuan   :${NC} ${dest}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    # Buat folder tujuan jika belum ada
    mkdir -p "$(dirname "$dest")" 2>/dev/null

    echo -e "${PURPLE}⏳  Sedang mengunduh...${NC}"
    
    if wget -q --show-progress -O "$dest" "$url"; then
        chmod +x "$dest"
        echo -e "\n${GREEN}✅  Berhasil!${NC}"
        echo -e "   File disimpan di : ${BOLD}${dest}${NC}"
        echo -e "   Permission       : executable (+x)"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    else
        echo -e "\n${RED}❌  Gagal mengunduh file!${NC}"
        echo -e "   Silakan cek URL / koneksi internet Anda."
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        return 1
    fi
}

# ==================== FUNGSI INTERAKTIF ====================
download_script() {
    clear
    echo -e "${CYAN}"
    echo "  ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗      ██████╗  █████╗ ██████╗ "
    echo "  ██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██╔═══██╗██╔══██╗██╔══██╗"
    echo "  ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║███████║██║  ██║"
    echo "  ██║  ██║██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║██╔══██║██║  ██║"
    echo "  ██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝██║  ██║██████╔╝"
    echo "  ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ "
    echo -e "${NC}"
    echo -e "${YELLOW}          🚀  GitHub Script Downloader  🚀${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    # Input 1: Path / Nama Script
    echo -e "${GREEN}📁  Masukkan path + nama file tujuan${NC}"
    echo -e "   Contoh: /usr/local/bin/script  atau  ~/tools/setup.sh"
    echo -ne "${BOLD}➤  Path/Nama Script : ${NC}"
    read -r path_script

    # Validasi input kosong
    if [ -z "$path_script" ]; then
        echo -e "\n${RED}❌  Path tidak boleh kosong!${NC}\n"
        return 1
    fi

    echo ""

    # Input 2: URL
    echo -e "${GREEN}🌐  Masukkan URL file yang ingin diunduh${NC}"
    echo -e "   Bisa full URL atau format GitHub: username/repo/branch/path/file.sh"
    echo -e "   Contoh full URL:"
    echo -e "   ${CYAN}https://raw.githubusercontent.com/user/repo/main/script.sh${NC}"
    echo -ne "${BOLD}➤  URL / GitHub Path : ${NC}"
    read -r url_file

    if [ -z "$url_file" ]; then
        echo -e "\n${RED}❌  URL tidak boleh kosong!${NC}\n"
        return 1
    fi

    echo ""
    echo -e "${YELLOW}🔄  Memproses...${NC}"

    # Panggil fungsi wget_github
    wget_github "$path_script" "$url_file"
}

# =============================================
# Fungsi Install Official Ookla Speedtest CLI
# =============================================

install_speedtest_official() {
    echo "🔍 Memeriksa apakah Official Ookla Speedtest CLI sudah terinstall..."

    # Cek apakah command speedtest sudah ada dan berasal dari Ookla
    if command -v speedtest &> /dev/null; then
        # Cek versi untuk memastikan bukan versi python
        if speedtest --version 2>&1 | grep -q "Ookla"; then
            echo "✅ Official Ookla Speedtest CLI sudah terinstall."
            return 0
        else
            echo "⚠️  Terdeteksi speedtest-cli (Python), akan diganti dengan versi resmi Ookla."
        fi
    fi

    echo "📥 Official Ookla Speedtest CLI belum terinstall. Melakukan instalasi..."

    # Update sistem
    sudo apt update

    # Install curl jika belum ada
    if ! command -v curl &> /dev/null; then
        echo "📦 Menginstall curl..."
        sudo apt install curl -y
    fi

    # Tambahkan repository resmi Ookla
    echo "➕ Menambahkan repository Ookla..."
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

    # Workaround Ubuntu 24.04 (ganti noble ke jammy)
    if [ -f /etc/apt/sources.list.d/ookla_speedtest-cli.list ]; then
        echo "🔧 Menerapkan workaround Ubuntu 24.04..."
        sudo sed -i 's/noble/jammy/g' /etc/apt/sources.list.d/ookla_speedtest-cli.list
    fi

    # Update repository dan install
    echo "📦 Mengupdate repository dan menginstall speedtest..."
    sudo apt update
    sudo apt install speedtest -y

    # Verifikasi akhir
    if command -v speedtest &> /dev/null && speedtest --version 2>&1 | grep -q "Ookla"; then
        echo "🎉 Berhasil! Official Ookla Speedtest CLI telah terinstall."
        echo "   Versi: $(speedtest --version | head -n 1)"
    else
        echo "❌ Gagal menginstall speedtest. Silakan cek error di atas."
        return 1
    fi
}

function kirim_pesan() {
echo ""
echo -e "${cyan} jika terjadi error \n anda bisa sampaikan kepada kami \n jika ada masukan, kritik dan saran \n bisa sampaikan kepada kami disini atau hubungi telegram \n t.me/jaringan_vpn${NC}"
    echo -e "  \033[1;93m────────────────────────────────────────────\033[0m"

read -p "   Masukan Pesan: " pesannya
set -a
source .env
set +a
BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
CHAT_ID="6406806868"
MYIP=$(wget -qO- ipinfo.io/ip)
ISP=$(wget -qO- ipinfo.io/org)
CITY=$(curl -s ipinfo.io/city)
TIMES=$(date +'%Y-%m-%d %H:%M:%S')
RAMMS=$(free -m | awk 'NR==2 {print $2}')
OSL=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
MESSAGE="
────────────────────
⚠️PESAN DARI CLIENT⚠️
────────────────────
Ip vps  : $MYIP
Date    : $TIMES
Ram     : $RAMMS MB
System  : $OSL
Country : $CITY
Isp     : $ISP
────────────────────
$pesannya
────────────────────
Automatic Notification from Jaringan_vpn"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id=$CHAT_ID \
     -d text="$MESSAGE"

echo -e "$✅ {GREEN}pesan berhasil dikirim${NC}"
}


# =============================================
# Fungsi Info Port - Menampilkan Port Terbuka
# =============================================
info_port() {
    clear
    echo -e "${CYAN}"
    echo "  ██╗███╗   ██╗███████╗ ██████╗     ██████╗  ██████╗ ██████╗ ████████╗"
    echo "  ██║████╗  ██║██╔════╝██╔═══██╗    ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝"
    echo "  ██║██╔██╗ ██║█████╗  ██║   ██║    ██████╔╝██║   ██║██████╔╝   ██║"
    echo "  ██║██║╚██╗██║██╔══╝  ██║   ██║    ██╔═══╝ ██║   ██║██╔══██╗   ██║"
    echo "  ██║██║ ╚████║██║     ╚██████╔╝    ██║     ╚██████╔╝██║  ██║   ██║"
    echo "  ╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝     ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝"
    echo -e "${NC}"
    echo -e "${YELLOW}           🔍  PORT SCANNER & SERVICE DETECTOR  🔍${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # ============================
    # 1. Cek tools yang tersedia
    # ============================
    local USE_SS=false
    local USE_NETSTAT=false
    local USE_LSOF=false
    local USE_SOCKSTAT=false

    if command -v ss &>/dev/null; then
        USE_SS=true
    fi
    if command -v netstat &>/dev/null; then
        USE_NETSTAT=true
    fi
    if command -v lsof &>/dev/null; then
        USE_LSOF=true
    fi
    if command -v sockstat &>/dev/null; then
        USE_SOCKSTAT=true
    fi

    echo -e "${DIM}🛠️  Tools terdeteksi:${NC}"
    $USE_SS     && echo -ne " ${GREEN}✔ ss${NC} "
    $USE_NETSTAT && echo -ne " ${GREEN}✔ netstat${NC} "
    $USE_LSOF   && echo -ne " ${GREEN}✔ lsof${NC} "
    $USE_SOCKSTAT && echo -ne " ${GREEN}✔ sockstat${NC} "
    if ! $USE_SS && ! $USE_NETSTAT && ! $USE_LSOF && ! $USE_SOCKSTAT; then
        echo -e "${RED}❌ Tidak ada tool network yang tersedia!${NC}"
        echo -e "${YELLOW}💡 Install: sudo apt install net-tools lsof iproute2${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 1
    fi
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # ============================
    # 2. Kumpulkan data port
    # ============================
    declare -A PORT_MAP
    declare -A PORT_PID
    declare -A PORT_PROGRAM
    declare -A PORT_PROTO
    declare -A PORT_STATE

    echo -e "${YELLOW}⏳  Mengumpulkan data port yang terbuka...${NC}"

    # --- Metode 1: ss (preferred, modern) ---
    if $USE_SS; then
        while IFS= read -r line; do
            local proto=$(echo "$line" | awk '{print $1}')
            local state=$(echo "$line" | awk '{print $2}')
            local local_addr=$(echo "$line" | awk '{print $5}')
            local process=$(echo "$line" | awk -F'"' '{print $2}')
            local pid=$(echo "$line" | awk -F'pid=' '{print $2}' | awk -F',' '{print $1}')

            # Ambil port dari local address
            local port=$(echo "$local_addr" | rev | cut -d':' -f1 | rev)

            # Hanya proses port numerik (skip unix socket, dll)
            if [[ "$port" =~ ^[0-9]+$ ]] && [ -n "$port" ]; then
                # Skip jika state bukan LISTEN atau ESTAB
                if [[ "$state" =~ LISTEN ]] || [[ "$state" =~ ESTAB ]]; then
                    local key="${proto}_${port}"
                    if [ -z "${PORT_MAP[$key]}" ]; then
                        PORT_MAP[$key]="$state"
                        PORT_PID[$key]="${pid:-N/A}"
                        PORT_PROGRAM[$key]="${process:-unknown}"
                        PORT_PROTO[$key]="$proto"
                        PORT_STATE[$key]="$state"
                    fi
                fi
            fi
        done < <(ss -tulpn 2>/dev/null)
    fi

    # --- Metode 2: netstat (fallback) ---
    if ! $USE_SS && $USE_NETSTAT; then
        while IFS= read -r line; do
            local proto=$(echo "$line" | awk '{print $1}')
            local local_addr=$(echo "$line" | awk '{print $4}')
            local pid_info=$(echo "$line" | awk '{print $NF}')

            local port=$(echo "$local_addr" | rev | cut -d':' -f1 | rev)
            local pid=""
            local program=""

            if [[ "$pid_info" =~ ^[0-9]+/ ]]; then
                pid=$(echo "$pid_info" | cut -d'/' -f1)
                program=$(echo "$pid_info" | cut -d'/' -f2-)
            fi

            if [[ "$port" =~ ^[0-9]+$ ]] && [ -n "$port" ]; then
                local key="${proto}_${port}"
                if [ -z "${PORT_MAP[$key]}" ]; then
                    PORT_MAP[$key]="LISTEN"
                    PORT_PID[$key]="${pid:-N/A}"
                    PORT_PROGRAM[$key]="${program:-unknown}"
                    PORT_PROTO[$key]="$proto"
                    PORT_STATE[$key]="LISTEN"
                fi
            fi
        done < <(netstat -tulpn 2>/dev/null | grep -E 'LISTEN|ESTAB')
    fi

    # ============================
    # 3. Tampilkan hasil
    # ============================
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${CYAN}║${RST} ${BOLD}${BWHITE}📊 LAPORAN PORT TERBUKA${RST}                                                      ${CYAN}║${RST}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${RST}"

    if [ ${#PORT_MAP[@]} -eq 0 ]; then
        echo -e "${CYAN}║${RST} ${BYELLOW}⚠️  Tidak ada port TCP/UDP yang terdeteksi terbuka.${RST}                         ${CYAN}║${RST}"
        echo -e "${CYAN}║${RST} ${DIM}   Mungkin firewall memblokir semua port.${RST}                                  ${CYAN}║${RST}"
    else
        # Header tabel
        printf "${CYAN}║${RST} ${BOLD}%-6s %-7s %-8s %-8s %-22s %-10s${RST}           ${CYAN}║${RST}\n" "PORT" "PROTO" "STATE" "PID" "PROGRAM/SERVICE" "TYPE"
        echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${RST}"

        # Urutkan berdasarkan port
        local sorted_keys=$(for k in "${!PORT_MAP[@]}"; do echo "$k"; done | sort -t'_' -k2 -n)

        local count=0
        local web_ports=""
        local db_ports=""
        local mail_ports=""
        local dns_ports=""
        local ssh_ports=""
        local other_ports=""

        for key in $sorted_keys; do
            local port="${key#*_}"
            local proto="${PORT_PROTO[$key]}"
            local state="${PORT_STATE[$key]}"
            local pid="${PORT_PID[$key]}"
            local program="${PORT_PROGRAM[$key]}"

            # Tentukan icon & kategori berdasarkan port
            local icon="🔹"
            local category=""
            local program_display="$program"

            case "$port" in
                22)
                    icon="🔐"; category="SSH"
                    ssh_ports="$ssh_ports\n  ${GREEN}🔐 Port 22${NC} → ${BOLD}SSH${NC} ${DIM}(Secure Shell)${NC} — ${program:-sshd}"
                    ;;
                80|8080|8000|8888|3000|4000|5000|9000)
                    icon="🌐"; category="HTTP"
                    web_ports="$web_ports\n  ${GREEN}🌐 Port $port${NC} → ${BOLD}HTTP${NC} ${DIM}(Web Server)${NC} — ${program:-web server}"
                    ;;
                443|8443|9443)
                    icon="🔒"; category="HTTPS"
                    web_ports="$web_ports\n  ${GREEN}🔒 Port $port${NC} → ${BOLD}HTTPS${NC} ${DIM}(Secure Web)${NC} — ${program:-web server}"
                    ;;
                3306|5432|27017|6379|9042|9200|9300)
                    icon="🗄️ "; category="DB"
                    case "$port" in
                        3306)  db_label="MySQL/MariaDB" ;;
                        5432)  db_label="PostgreSQL" ;;
                        27017) db_label="MongoDB" ;;
                        6379)  db_label="Redis" ;;
                        9042)  db_label="Cassandra" ;;
                        9200|9300) db_label="Elasticsearch" ;;
                        *)     db_label="Database" ;;
                    esac
                    db_ports="$db_ports\n  ${YELLOW}🗄️  Port $port${NC} → ${BOLD}${db_label}${NC} — ${program:-database}"
                    ;;
                25|465|587|993|995|110|143)
                    icon="📧"; category="MAIL"
                    mail_ports="$mail_ports\n  ${BLUE}📧 Port $port${NC} → ${BOLD}SMTP/IMAP/POP3${NC} — ${program:-mail service}"
                    ;;
                53|853)
                    icon="📡"; category="DNS"
                    dns_ports="$dns_ports\n  ${PURPLE}📡 Port $port${NC} → ${BOLD}DNS${NC} — ${program:-dns resolver}"
                    ;;
                21|20)
                    icon="📁"; category="FTP"
                    other_ports="$other_ports\n  ${DIM}📁 Port $port${NC} → ${BOLD}FTP${NC} — ${program:-ftp server}"
                    ;;
                3128|8081|8118)
                    icon="🔄"; category="PROXY"
                    other_ports="$other_ports\n  ${DIM}🔄 Port $port${NC} → ${BOLD}PROXY${NC} — ${program:-proxy server}"
                    ;;
                3389)
                    icon="🖥️ "; category="RDP"
                    other_ports="$other_ports\n  ${DIM}🖥️  Port $port${NC} → ${BOLD}RDP${NC} — ${program:-remote desktop}"
                    ;;
                5900|5901|5902)
                    icon="🖥️ "; category="VNC"
                    other_ports="$other_ports\n  ${DIM}🖥️  Port $port${NC} → ${BOLD}VNC${NC} — ${program:-vnc server}"
                    ;;
                9090|9100|3001)
                    icon="📊"; category="MONITOR"
                    other_ports="$other_ports\n  ${DIM}📊 Port $port${NC} → ${BOLD}Monitoring${NC} — ${program:-monitoring tool}"
                    ;;
                51820|51821)
                    icon="🔗"; category="VPN"
                    other_ports="$other_ports\n  ${DIM}🔗 Port $port${NC} → ${BOLD}WireGuard VPN${NC} — ${program:-wireguard}"
                    ;;
                1194)
                    icon="🔗"; category="VPN"
                    other_ports="$other_ports\n  ${DIM}🔗 Port $port${NC} → ${BOLD}OpenVPN${NC} — ${program:-openvpn}"
                    ;;
                *)
                    icon="🔸"; category="OTHER"
                    other_ports="$other_ports\n  ${DIM}🔸 Port $port${NC} → ${BOLD}${program:-unknown}${NC} ${DIM}(PID: ${pid:-N/A})${NC}"
                    ;;
            esac

            # Baris tabel
            printf "${CYAN}║${RST} ${icon} ${BOLD}%-4s${RST} ${DIM}%-6s${RST} ${GREEN}%-8s${RST} ${YELLOW}%-8s${RST} ${CYAN}%-22s${RST} ${DIM}%-10s${RST}${CYAN}║${RST}\n" \
                "$port" "$proto" "$state" "${pid:-N/A}" "${program_display:0:22}" "${category:-OTHER}"
            ((count++))
        done

        echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${RST}"
        printf "${CYAN}║${RST} ${BOLD}Total: %d port terbuka${RST}                                                        ${CYAN}║${RST}\n" "$count"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${RST}"
    fi

    # ============================
    # 4. Ringkasan Kategori
    # ============================
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${CYAN}║${RST} ${BOLD}${BWHITE}📋 RINGKASAN BERDASARKAN KATEGORI${RST}                                            ${CYAN}║${RST}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${RST}"

    if [ -n "$web_ports" ]; then
        echo -e "${CYAN}║${RST} ${BOLD}${GREEN}🌐 LAYANAN WEB:${RST}"
        echo -e "$web_ports" | while IFS= read -r line; do [ -n "$line" ] && echo -e "${CYAN}║${RST}$line"; done
    fi

    if [ -n "$ssh_ports" ]; then
        echo -e "${CYAN}║${RST} ${BOLD}${CYAN}🔐 AKSES REMOTE:${RST}"
        echo -e "$ssh_ports" | while IFS= read -r line; do [ -n "$line" ] && echo -e "${CYAN}║${RST}$line"; done
    fi

    if [ -n "$db_ports" ]; then
        echo -e "${CYAN}║${RST} ${BOLD}${YELLOW}🗄️  DATABASE:${RST}"
        echo -e "$db_ports" | while IFS= read -r line; do [ -n "$line" ] && echo -e "${CYAN}║${RST}$line"; done
    fi

    if [ -n "$mail_ports" ]; then
        echo -e "${CYAN}║${RST} ${BOLD}${BLUE}📧 EMAIL:${RST}"
        echo -e "$mail_ports" | while IFS= read -r line; do [ -n "$line" ] && echo -e "${CYAN}║${RST}$line"; done
    fi

    if [ -n "$dns_ports" ]; then
        echo -e "${CYAN}║${RST} ${BOLD}${PURPLE}📡 DNS:${RST}"
        echo -e "$dns_ports" | while IFS= read -r line; do [ -n "$line" ] && echo -e "${CYAN}║${RST}$line"; done
    fi

    if [ -n "$other_ports" ]; then
        echo -e "${CYAN}║${RST} ${BOLD}${DIM}🔸 LAYANAN LAINNYA:${RST}"
        echo -e "$other_ports" | while IFS= read -r line; do [ -n "$line" ] && echo -e "${CYAN}║${RST}$line"; done
    fi

    if [ -z "$web_ports" ] && [ -z "$ssh_ports" ] && [ -z "$db_ports" ] && [ -z "$mail_ports" ] && [ -z "$dns_ports" ] && [ -z "$other_ports" ]; then
        echo -e "${CYAN}║${RST} ${DIM}Tidak ada port yang terdeteksi.${RST}"
    fi

    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${RST}"

    # ============================
    # 5. Info Tambahan: Firewall
    # ============================
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${CYAN}║${RST} ${BOLD}${BWHITE}🛡️  STATUS FIREWALL${RST}                                                           ${CYAN}║${RST}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${RST}"

    # UFW
    if command -v ufw &>/dev/null; then
        local ufw_status=$(ufw status 2>/dev/null | head -1)
        echo -e "${CYAN}║${RST} ${BOLD}UFW:${RST}  ${ufw_status:-tidak terinstall}"
        if ufw status 2>/dev/null | grep -q "Status: active"; then
            echo -ne "${CYAN}║${RST} ${DIM}Allowed:${RST}"
            ufw status 2>/dev/null | grep "ALLOW" | while IFS= read -r rule; do
                echo -ne " ${GREEN}${rule}${NC}"
            done
            echo ""
        fi
    else
        echo -e "${CYAN}║${RST} ${DIM}UFW: tidak terinstall${RST}"
    fi

    # iptables (rule count)
    if command -v iptables &>/dev/null; then
        local ipt_rules=$(iptables -L INPUT -n 2>/dev/null | grep -c 'ACCEPT\|DROP\|REJECT')
        echo -e "${CYAN}║${RST} ${BOLD}iptables:${RST} ${ipt_rules} rules di chain INPUT"
    fi

    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${RST}"

    echo ""
    echo -e "${DIM}💡 Tips: Gunakan 'ss -tulpn' untuk melihat port secara real-time.${NC}"
    echo -e "${DIM}   Gunakan 'ufw allow <port>' untuk membuka port di firewall.${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

echo -e " ${y} ┌─────────────────────────────────┐$NC"
echo -e " ${y} │${NC}${g}.::. ${NC}MENU PENGATURAN LAINNYA ${g}.::.${y}│$NC"
echo -e " ${y} └─────────────────────────────────┘$NC"
echo -e    "\033[1;33m  ┌─────────────────────────────────┐\033[0m"
echo -e "  ${y}│${NC}${dkblu}[${g}•1${dkblu}]${NC}\033[0;36m KIRIM PESAN KEDEVELOPER     ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•2${dkblu}]${NC}\033[0;36m SPEEDTEST                   ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•3${dkblu}]${NC}\033[0;36m MONITORING                  ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•4${dkblu}]${NC}\033[0;36m EDIT FILE SCRIPT            ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•5${dkblu}]${NC}\033[0;36m SETUP DDNS                  ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•6${dkblu}]${NC}\033[0;36m UPGRADER SCRIPT             ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•7${dkblu}]${NC}\033[0;36m ROOTING                     ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•8${dkblu}]${NC}\033[0;36m DOWNLOAD SCRIPT             ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}•9${dkblu}]${NC}\033[0;36m ENCRYPT & DECRYPT           ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}10${dkblu}]${NC}\033[0;36m SSH MANAGER                 ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}11${dkblu}]${NC}\033[0;36m AUTO REBOOT                 ${y}│${NC}"
echo -e "  ${y}│${NC}${dkblu}[${g}12${dkblu}]${NC}\033[0;36m INFO PORT                   ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}13${dkblu}]${NC}\033[0;36m AUTO REBOOT                 ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}14${dkblu}]${NC}\033[0;36m CLEAR CHACE                 ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}15${dkblu}]${NC}\033[0;36m CHECK BW                    ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}16${dkblu}]${NC}\033[0;36m CEK PENYIMPANAN             ${y}│${NC}"
#echo -e "  ${y}│${NC}${dkblu}[${g}17${dkblu}]${NC}\033[0;36m KIRIM PESAN KEDEVELOPER     ${y}│${NC}"
echo -e "  ${y}│                                 │${NC}"
echo -e "  ${y}│${NC}${dkblu}[${red}•0${dkblu}]${NC}${red} BACK TO MENU                ${y}│${NC}"
echo -e "\033[1;33m  └─────────────────────────────────┘\033[0m"
read -p "Silakan Masukkan Angka [ 1 - 12 ] : " plh
echo -e ""
case $plh in
1 | 01)
    clear
    kirim_pesan
    ;;
2 | 02)
    clear
    install_speedtest_official
    speedtest
    ;;
3 | 03)
    clear
    m-monitor
    ;;
4 | 04)
    clear
    editfile
    ;;
5 | 05)
    clear
    ddns
    ;;
6 | 06)
    upgrader
    ;;
7 | 07)
    clear
    root
    ;;
8 | 08)
    clear
    download_script
    ;;
9 | 09)
    clear
    openssl-encrypt
    ;;
10)
    clear
    ssh_manager
    ;;    
11)
    clear
    a-reboot
    ;;
12)
    clear
    info_port
    ;;
#13)
#    autoreboot
#    ;;
#14)
#    clear
#    clearcache
#    ;;
#15)
#    clear
#    cek_bw
#    read -n 1 -s -r -p "Press any key to back on menu"
#    loading ; menu ;;
#16)
#    cek-penyimpanan
#    ;;
#17)
#    clear
#    kirim_pesan
#    ;;
0)
    clear
    newmenu ;;
x | X)
    clear
    exit 0
    ;;
*) echo "Silakan Masukkan Angka [1 - 12]." ; loading ; exec "$0" ;;
esac
