#!/bin/bash
# ========== SUPER ANTI-HANG VERSION ==========
# Made by: Nobody (si peduli walau mulut kayak parit)

CACHE_FILE="/tmp/vps_cache"
CACHE_TTL=600

# Colors
NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[1;95m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
GB='\033[42;37m'; c='\e[1;36m'; g='\e[1;32m'; y='\e[1;33m'; w='\e[1;37m'
u='\e[1;35m'; r='\e[1;31m'

# Fungsi sakti: timeout otomatis, kalo gagal return "N/A"
runto() {
    local t=$1; shift
    timeout $t "$@" 2>/dev/null || echo "N/A"
}

gather_all_data() {
    echo -n "Loading data..." >&2

    # --- Cek cache network ---
    local need_refresh=0
    if [[ -f "$CACHE_FILE" ]]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
        [[ $age -gt $CACHE_TTL ]] && need_refresh=1
    else
        need_refresh=1
    fi

    if [[ $need_refresh -eq 1 ]]; then
        IPVPS=$(runto 2 curl -s ipv4.icanhazip.com)
        ISP=$(runto 2 sh -c "curl -s ipinfo.io/org | cut -d ' ' -f 2-")
        CITY=$(runto 2 curl -s ipinfo.io/city)
        WKT=$(runto 2 curl -s ipinfo.io/timezone)
        MODEL=$(grep PRETTY_NAME /etc/os-release | head -1 | cut -d '"' -f2)
        # Simpan cache
        {
            echo "IPVPS=\"$IPVPS\""
            echo "ISP=\"$ISP\""
            echo "CITY=\"$CITY\""
            echo "WKT=\"$WKT\""
            echo "MODEL=\"$MODEL\""
        } > "$CACHE_FILE"
    else
        source "$CACHE_FILE" 2>/dev/null || {
            IPVPS="N/A"; ISP="N/A"; CITY="N/A"; WKT="N/A"; MODEL="N/A"
        }
        IPVPS=${IPVPS:-N/A}; ISP=${ISP:-N/A}; CITY=${CITY:-N/A}
        WKT=${WKT:-N/A}; MODEL=${MODEL:-N/A}
    fi

    # --- Data sistem (dengan timeout brutal) ---
    if [[ -r /proc/meminfo ]]; then
        TOTAL_KB=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
        AVAILABLE_KB=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
        USED_KB=$(( TOTAL_KB - AVAILABLE_KB ))
        TRAM=$(( TOTAL_KB / 1024 ))
        URAM=$(( USED_KB / 1024 ))
        FRAM=$(( AVAILABLE_KB / 1024 ))
    else
        read RAM USAGERAM FRAM <<< $(runto 2 free -m | awk 'NR==2{print $2,$3,$4}')
        TRAM=${RAM:-0}; URAM=${USAGERAM:-0}; FRAM=${FRAM:-0}
    fi
    if [[ ${TRAM:-0} -gt 0 ]]; then
        MEMOFREE=$(awk "BEGIN { printf \"%.1f\", ($URAM/$TRAM)*100 }" 2>/dev/null || echo "0")
    else
        MEMOFREE="0"
    fi

    uptime=$(runto 2 uptime -p | sed 's/^up //')
    CORE=$(runto 1 nproc --all)
    DATE=$(date +%Y-%m-%d)
    DAY=$(date +%A)
    TIMEZONE=$(printf '%(%H:%M:%S)T')
    LOADCPU=$(runto 2 top -bn1 | awk '/^%Cpu/{print 100 - $8"%"}')

    # --- vnstat (deteksi interface otomatis) ---
    local iface=$(runto 1 ip route | awk '/default/ {print $5; exit}')
    if command -v vnstat &>/dev/null && [[ -n "$iface" && "$iface" != "N/A" ]]; then
        read total giga tahun <<< $(vnstat -i "$iface" -m 2>/dev/null | tail -n1 | awk '{print $8,$9,$1}')
    else
        total="0"; giga="GiB"; tahun="N/A"
    fi
    total=${total:-0}; giga=${giga:-GiB}; tahun=${tahun:-N/A}

    echo -e "\r\033[K" >&2  # hapus pesan loading
}

display_menu() {
    clear
    echo -e "${g}${NC}"
    echo -e "       ╭──────────────────────────────────────────╮"
    echo -e "       │${GB}            MAMAT HACKING TEAM            ${NC}│"
    echo -e "       ╰──────────────────────────────────────────╯"
    echo -e "          ┌──────────────────────────────────┐"
    echo -e "          │ ${c} SYSTEM OS : ${MODEL} ${NC}"
    echo -e "          │ ${c} ISP VPS   : ${ISP} ${NC}"
    echo -e "          │ ${c} CPU       : ${CORE} CORE${NC}"
    echo -e "          │ ${c} RAM       : ${TRAM} MB (Used: ${URAM} MB, Free: ${FRAM} MB)${NC}"
    echo -e "          │ ${c} UPTIME    : ${uptime} ${NC}"
    echo -e "          │ ${c} IP VPS    : ${IPVPS} ${NC}"
    echo -e "          │ ${c} DATE      : ${DATE}${NC}"
    echo -e "          └──────────────────────────────────┘"
    echo -e "        ${r}┌──────────────────────────────────────┐${NC}"
    echo -e "        ${r}│${y}[${u}•1${y}]${NC} CHECK SERVICE  ""${y}[${u}•7${y}]${NC} MONITORING   ${r}│"
    echo -e "        ${r}│${y}[${u}•2${y}]${NC} SERVICE MANAGER""${y}[${u}•8${y}]${NC} SCREEN       ${r}│"
    echo -e "        ${r}│${y}[${u}•3${y}]${NC} CONFIG NGINX   ""${y}[${u}•9${y}]${NC} AUTO ROOT    ${r}│"
    echo -e "        ${r}│${y}[${u}•4${y}]${NC} CHECK DISK     ""${y}[${u}10${y}]${NC} AUTO REBOOT  ${r}│"
    echo -e "        ${r}│${y}[${u}•5${y}]${NC} TAILSCALE      ""${y}[${u}11${y}]${NC} TOOLS HACK   ${r}│"
    echo -e "        ${r}│${y}[${u}•6${y}]${NC} ZEROTIER       ""${y}[${u}12${y}]${NC} SETTING      ${r}│"
    echo -e "        ${r}└──────────────────────────────────────┘${NC}"
    echo -e "      ${w}           BW ${tahun} : ${total} ${giga} ${NC}"
    echo -e "      ${w}           Sc Version : 3.0.1 ${NC}"
    echo "                 _____________________"
    echo ""
    echo -e "${CYAN}        ┌───(${YELLOW}Masukkan${CYAN}─${YELLOW}Angka${RST}${CYAN})──[${YELLOW}1${CYAN}-${YELLOW}12${CYAN}]───▶️${RST}"
    read -p "        $(echo -e ${CYAN}└──▶️ ${NC}) " opt
    echo ""
    case $opt in
        1)  clear; cek_service ;;
        2)  clear; service_manager ;;
        3)  clear; m-nginx ;;
        4)  clear; disk ;;
        5)  clear; m-tailscale ;;
        6)  clear; m-zerotier ;;
        7)  clear; m-monitor ;;
        8)  clear; m-screen ;;
        9)  clear; root ;;
        10) clear; a-reboot ;;
        11) clear; mode-hack ;;
        12) clear; m-setting ;; 
        x|X) exit 0 ;;
        *)  echo -e "${RED}Pilihan salah. Ulangi.${NC}"; sleep 1; display_menu ;;
    esac
}

# ========== START ==========
gather_all_data
display_menu