#\!/usr/bin/env bash
# =============================================================================
#  IDENTITAS VPS - v1.0
#  Pengecekan detail spesifikasi & identitas VPS
#  Usage: bash identitas_vps.sh
# =============================================================================

set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# --- HEADER ---
clear
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║             🖥️  IDENTITAS VPS - SPESIFIKASI LENGKAP  🖥️                    ║"
echo "║                                                                          ║"
echo "║                    $(date '+%A, %d %B %Y %H:%M:%S')                         ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# --- FUNCTIONS ---
section() {
    echo ""
    echo -e "${BLUE}${BOLD}┌──────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}${BOLD}│${NC}  ${BOLD}$1${NC}"
    echo -e "${BLUE}${BOLD}└──────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

label() {
    printf "  ${CYAN}│${NC} ${BOLD}%-20s${NC} %b%s%b${NC}\n" "$1" "$3" "$2" "$NC"
}

sep() {
    echo -e "  ${DIM}────────────────────────────────────────────────────────────────────────${NC}"
}

format_mem() {
    kb=$1
    if [[ $kb -ge 1048576 ]]; then
        echo "$(echo "scale=2; $kb / 1048576" | bc) GB"
    elif [[ $kb -ge 1024 ]]; then
        echo "$(echo "scale=2; $kb / 1024" | bc) MB"
    else
        echo "${kb} KB"
    fi
}

# --- 1. OS ---
section "1. 💿  SISTEM OPERASI"

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    label "OS/Distro" "$NAME $VERSION_ID" "${GREEN}"
    label "ID" "$ID" "${CYAN}"
fi
label "Kernel" "$(uname -r)" "${YELLOW}"
label "Arch" "$(uname -m)" "${CYAN}"
label "Hostname" "$(hostname 2>/dev/null)" "${WHITE}"
label "Tipe OS" "$(uname -o 2>/dev/null)" "${MAGENTA}"

# --- 2. WAKTU ---
section "2. ⏰  WAKTU & UPTIME"

label "Waktu" "$(date '+%Y-%m-%d %H:%M:%S %Z')" "${GREEN}"
label "Timezone" "$(timedatectl show --property=Timezone --value 2>/dev/null)" "${CYAN}"

uptime_s=$(awk '{print $1}' /proc/uptime 2>/dev/null | cut -d. -f1)
days=$((uptime_s / 86400))
hours=$(( (uptime_s % 86400) / 3600 ))
mins=$(( (uptime_s % 3600) / 60 ))
label "Uptime" "${days}h ${hours}j ${mins}m" "${YELLOW}"
label "Boot" "$(who -b 2>/dev/null | awk '{print $3, $4}')" "${CYAN}"

# --- 3. CPU ---
section "3. 🧠  CPU (PROSESOR)"

cpu_model=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//')
cpu_cores=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)
cpu_mhz=$(grep -m1 'cpu MHz' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//')
cpu_cache=$(grep -m1 'cache size' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//')
cpu_flags=$(grep -m1 'flags' /proc/cpuinfo 2>/dev/null)

label "Model CPU" "${cpu_model:-N/A}" "${GREEN}"
label "Cores" "${cpu_cores:-N/A} Core(s)" "${YELLOW}"
label "Clock" "${cpu_mhz:-N/A} MHz" "${MAGENTA}"
label "Cache" "${cpu_cache:-N/A}" "${WHITE}"

if echo "${cpu_flags:-}" | grep -qiE 'vmx|svm'; then
    label "Virtualisasi" "✅ Didukung (VT-x/AMD-V)" "${GREEN}"
else
    label "Virtualisasi" "❌ Tidak didukung" "${RED}"
fi

read load1 load5 load15 < /proc/loadavg 2>/dev/null
label "Load Avg" "$load1, $load5, $load15 (1m, 5m, 15m)" "${YELLOW}"

# --- 4. RAM ---
section "4. 💾  RAM (MEMORY)"

mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
mem_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
mem_used=$((mem_total - mem_avail))
mem_pct=$((mem_used * 100 / mem_total))

swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')

label "RAM Total" "$(format_mem $mem_total)" "${GREEN}"
label "RAM Terpakai" "$(format_mem $mem_used)" "${YELLOW}"
label "RAM Tersedia" "$(format_mem $mem_avail)" "${GREEN}"

# Bar
bar_len=30
filled=$((mem_pct * bar_len / 100))
empty=$((bar_len - filled))
bar=""
for ((i=0; i<filled; i++)); do bar="${bar}█"; done
for ((i=0; i<empty; i++)); do bar="${bar}░"; done
if [[ $mem_pct -ge 80 ]]; then
    echo -e "  ${CYAN}│${NC}  ${RED}${bar} ${mem_pct}%${NC}"
elif [[ $mem_pct -ge 50 ]]; then
    echo -e "  ${CYAN}│${NC}  ${YELLOW}${bar} ${mem_pct}%${NC}"
else
    echo -e "  ${CYAN}│${NC}  ${GREEN}${bar} ${mem_pct}%${NC}"
fi
sep

if [[ $swap_total -gt 0 ]]; then
    label "SWAP Total" "$(format_mem $swap_total)" "${CYAN}"
    label "SWAP Terpakai" "$(format_mem $((swap_total - swap_free)))" "${YELLOW}"
    label "SWAP Bebas" "$(format_mem $swap_free)" "${GREEN}"
else
    label "SWAP" "❌ Tidak ada" "${RED}"
fi

# --- 5. DISK ---
section "5. 💽  DISK (PENYIMPANAN)"

echo -e "  ${CYAN}│${NC}  ${BOLD}Filesystem${NC}           ${BOLD}Size${NC}    ${BOLD}Used${NC}    ${BOLD}Avail${NC}   ${BOLD}Use%${NC}  ${BOLD}Mount${NC}"
echo -e "  ${DIM}────────────────────────────────────────────────────────────────────────${NC}"

df -h 2>/dev/null | grep -vE '^Filesystem|tmpfs|devtmpfs|squashfs|overlay|udev' | while read -r fs size used avail use mount; do
    unum=$(echo "$use" | tr -d '%')
    if [[ $unum -ge 80 ]]; then
        echo -e "  ${CYAN}│${NC}  ${RED}${fs:0:20}${NC} ${WHITE}${size:0:6}${NC} ${RED}${used:0:6}${NC} ${GREEN}${avail:0:6}${NC} ${RED}${use}${NC}  ${mount} ⚠️"
    elif [[ $unum -ge 50 ]]; then
        echo -e "  ${CYAN}│${NC}  ${YELLOW}${fs:0:20}${NC} ${WHITE}${size:0:6}${NC} ${YELLOW}${used:0:6}${NC} ${GREEN}${avail:0:6}${NC} ${YELLOW}${use}${NC}  ${mount}"
    else
        echo -e "  ${CYAN}│${NC}  ${GREEN}${fs:0:20}${NC} ${WHITE}${size:0:6}${NC} ${WHITE}${used:0:6}${NC} ${GREEN}${avail:0:6}${NC} ${GREEN}${use}${NC}  ${mount}"
    fi
done

# --- 6. JARINGAN ---
section "6. 🌐  JARINGAN & IP PUBLIK"

label "Hostname" "$(hostname)" "${GREEN}"
label "IP Lokal" "$(ip -4 addr show 2>/dev/null | grep -oP 'inet \K[\d.]+' | grep -v 127.0.0.1 | head -1)" "${CYAN}"
label "IP Publik" "$(curl -s --max-time 10 https://api.ipify.org 2>/dev/null || echo 'Gagal')" "${YELLOW}"
label "MAC" "$(ip link show 2>/dev/null | grep -oP 'link/ether \K[\da-f:]+' | head -1)" "${MAGENTA}"
label "DNS" "$(grep nameserver /etc/resolv.conf 2>/dev/null | head -3 | awk '{print $2}' | tr '\n' ' ')" "${CYAN}"

echo ""
echo -e "  ${CYAN}│${NC}  ${BOLD}Interface Jaringan:${NC}"
ip -br addr show 2>/dev/null | grep -v lo | while read -r iface state ip; do
    echo -e "  ${CYAN}│${NC}    📡 ${BOLD}$iface${NC} ($state) ${WHITE}${ip:-N/A}${NC}"
done

# --- 7. GEO IP ---
section "7. 🌍  INFO GEOGRAFIS (IPWHOIS)"

geo=$(curl -s --max-time 10 https://ipwho.is/ 2>/dev/null || echo '{}')
if [[ -n "$geo" && "$geo" != "{}" ]]; then
    label "Negara" "$(echo "$geo" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('country','N/A'))" 2>/dev/null)" "${GREEN}"
    label "Kota" "$(echo "$geo" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('city','N/A'))" 2>/dev/null)" "${CYAN}"
    label "ISP" "$(echo "$geo" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('connection',{}).get('isp','N/A'))" 2>/dev/null)" "${YELLOW}"
    label "Org" "$(echo "$geo" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('connection',{}).get('org','N/A'))" 2>/dev/null)" "${MAGENTA}"
    label "ASN" "$(echo "$geo" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('connection',{}).get('asn','N/A'))" 2>/dev/null)" "${WHITE}"
    lat=$(echo "$geo" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('latitude',''))" 2>/dev/null)
    lon=$(echo "$geo" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('longitude',''))" 2>/dev/null)
    label "Lokasi" "${lat}, ${lon}" "${CYAN}"
    if [[ -n "$lat" && -n "$lon" ]]; then
        echo -e "  ${CYAN}│${NC}  ${BOLD}🗺️  Peta${NC}           ${CYAN}https://www.google.com/maps?q=${lat},${lon}${NC}"
    fi
else
    label "Geo IP" "❌ Gagal (offline/blocked)" "${RED}"
fi

# --- 8. PROSES ---
section "8. ⚙️  PROSES & SERVICE"

label "Total Proses" "$(ps aux 2>/dev/null | wc -l)" "${GREEN}"
label "Service Running" "$(systemctl list-units --type=service --state=running 2>/dev/null | grep -c running)" "${GREEN}"
failed_svc=$(systemctl list-units --type=service --state=failed 2>/dev/null | grep -c failed)
if [[ $failed_svc -gt 0 ]]; then
    label "Service Failed" "$failed_svc ❌" "${RED}"
    systemctl list-units --type=service --state=failed 2>/dev/null | grep failed | while read -r line; do
        echo -e "  ${CYAN}│${NC}     ${RED}⚠️ ${line}${NC}"
    done
else
    label "Service Failed" "0 ✅" "${GREEN}"
fi

# --- 9. USER ---
section "9. 👤  LOGIN & USER"

label "Total User" "$(awk -F: '($3>=1000)&&($3!=65534){print}' /etc/passwd 2>/dev/null | wc -l)" "${GREEN}"
label "Sedang Login" "$(who 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ' ')" "${YELLOW}"
label "Login Terakhir" "$(last -1 -w 2>/dev/null | head -1 | awk '{print $1, $3, $4, $5, $6}')" "${CYAN}"

# --- 10. KEAMANAN ---
section "10. 🔒  KEAMANAN DASAR"

if command -v ufw &>/dev/null; then
    label "UFW" "$(ufw status 2>/dev/null | head -1)" "${GREEN}"
elif command -v iptables &>/dev/null; then
    label "Firewall" "iptables terinstall" "${CYAN}"
else
    label "Firewall" "❌ Tidak ada" "${RED}"
fi

if command -v fail2ban-client &>/dev/null; then
    label "Fail2ban" "✅ Aktif" "${GREEN}"
else
    label "Fail2ban" "❌ Tidak terinstall" "${RED}"
fi

sp=$(grep -i '^Port' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo 22)
if [[ "$sp" == "22" ]]; then
    label "SSH Port" "$sp (default)" "${YELLOW}"
else
    label "SSH Port" "$sp (non-standar ✅)" "${GREEN}"
fi

rl=$(grep -i '^PermitRootLogin' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
if [[ "$rl" == "yes" ]]; then
    label "Root Login" "Diizinkan ⚠️" "${RED}"
else
    label "Root Login" "Dilarang ✅" "${GREEN}"
fi

# --- 11. APPS ---
section "11. 📦  APLIKASI TERINSTALL"

for app in nginx apache2 mysql mariadb postgresql docker node npm python3 php redis-server mongod; do
    if command -v "$app" &>/dev/null; then
        ver=$("$app" --version 2>/dev/null | head -1)
        label "$app" "✅ ${ver:-terinstall}" "${GREEN}"
    fi
done

# --- RINGKASAN ---
section "📊  RINGKASAN VPS"

echo -e "  ${CYAN}│${NC}  ${BOLD}Ringkasan:${NC}"
echo ""
echo -e "  ${CYAN}│${NC}  🖥️  ${BOLD}OS${NC}        : ${WHITE}$(grep -m1 PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')${NC}"
echo -e "  ${CYAN}│${NC}  🧠 ${BOLD}CPU${NC}        : ${WHITE}${cpu_model:-N/A} (${cpu_cores:-?} Core)${NC}"
echo -e "  ${CYAN}│${NC}  💾 ${BOLD}RAM${NC}        : ${WHITE}$(format_mem $mem_total) (${mem_pct}% terpakai)${NC}"
echo -e "  ${CYAN}│${NC}  💽 ${BOLD}Disk${NC}       : ${WHITE}$(df -h / 2>/dev/null | awk 'NR==2{print $2}') total, $(df -h / 2>/dev/null | awk 'NR==2{print $3}') terpakai${NC}"
echo -e "  ${CYAN}│${NC}  🌐 ${BOLD}IP${NC}         : ${WHITE}$(curl -s --max-time 10 https://api.ipify.org 2>/dev/null || echo 'Gagal')${NC}"
echo -e "  ${CYAN}│${NC}  ⏰ ${BOLD}Uptime${NC}     : ${WHITE}${days}h ${hours}j ${mins}m${NC}"

# --- FOOTER ---
echo ""
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║              ✅  PENGECEKAN SELESAI  ✅                                  ║"
echo "║                                                                          ║"
echo "║          $(date '+%d %B %Y %H:%M:%S')                                         ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
