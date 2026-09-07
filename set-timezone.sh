#!/usr/bin/env bash
#
# ╔══════════════════════════════════════════════════════╗
# ║  ⚡ SET-TIMEZONE.SH — Cyberpunk Edition ⚡             ║
# ║  Ganti timezone server dengan gaya neon punk!        ║
# ╚══════════════════════════════════════════════════════╝
#
# Usage:
#   sudo ./set-timezone.sh          -> menu interaktif
#   sudo ./set-timezone.sh wib      -> langsung WIB
#   sudo ./set-timezone.sh sg       -> langsung Singapura
#

set -e

# ─── NEON COLOR PALETTE ──────────────────────────────
RST='\033[0m'
BLK='\033[1m'
RED='\033[0;38;5;203m'
GRN='\033[0;38;5;82m'
YLW='\033[0;38;5;226m'
CYN='\033[0;38;5;51m'
MRG='\033[0;38;5;212m'
ORG='\033[0;38;5;208m'
BRU='\033[0;38;5;94m'
PUR='\033[0;38;5;141m'
DIM='\033[0;90m'
BLU='\033[0;38;5;75m'

# ─── CHECK ROOT ──────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo ""
    print_divider "$RED"
    echo -e "${RED}${BLK}  ${ICON_X}  ERROR: Root access required!${RST}"
    print_divider_bottom "$RED"
    echo -e "  ${DIM}Run: sudo $0${RST}"
    echo ""
    exit 1
fi

if ! command -v timedatectl &> /dev/null; then
    echo ""
    print_divider "$RED"
    echo -e "${RED}${BLK}  ${ICON_X}  Error: 'timedatectl' not found!${RST}"
    print_divider_bottom "$RED"
    echo -e "  ${DIM}Ensure systemd is installed.${RST}"
    echo ""
    exit 1
fi

# ─── HELPERS ─────────────────────────────────────────
# Pre-build divider strings (52 chars wide)
DIVIDER_LINE=$(printf '═%.0s' {1..52})
DIVIDER_TOP="╔${DIVIDER_LINE}╗"
DIVIDER_BOT="╚${DIVIDER_LINE}╝"

print_divider() {
    local color="${1:-$CYN}"
    echo -e "${color}${DIVIDER_TOP}"
}

print_divider_bottom() {
    local color="${1:-$CYN}"
    echo -e "${color}${DIVIDER_BOT}"
}

set_tz() {
    local tz="$1"
    local label="$2"
    local icon="$3"

    echo ""
    print_divider "$MRG"
    echo -e "${MRG}${BLK}  ${ICON_BOLT}  APPLYING TIMEZONE${RST}"
    print_divider_bottom "$MRG"
    echo ""
    echo -e "  ${ICON_TARGET} Zone:  ${CYN}${tz}${RST}"
    echo -e "  ${ICON_GLOBE} Label:  ${YLW}${label}${RST}"
    echo -e "  ${ICON_CLOCK} Icon:   ${icon}${RST}"
    echo ""
    echo -e "  ${DIM}▸ Setting timezone...${RST}"

    if timedatectl set-timezone "$tz" 2>/dev/null; then
        echo ""
        print_divider "$GRN"
        echo -e "${GRN}${BLK}  ${ICON_CHECK}  SUCCESS! Timezone Applied${RST}"
        print_divider_bottom "$GRN"
        echo ""
        local cur_date cur_time cur_utc
        cur_date=$(date '+%Y-%m-%d')
        cur_time=$(date '+%H:%M:%S')
        cur_utc=$(TZ=UTC date '+%H:%M:%S')
        echo -e "  ${ICON_CLOCK} Local:  ${GRN}${cur_time}${RST}  (${DIM}${cur_date}${RST})"
        echo -e "  ${ICON_GLOBE} UTC:    ${DIM}${cur_utc}${RST}"
        echo -e "  ${ICON_ARROW} Status: ${GRN}Active${RST}"
        echo ""
    else
        echo ""
        print_divider "$RED"
        echo -e "${RED}${BLK}  ${ICON_X}  FAILED! Check timezone name.${RST}"
        print_divider_bottom "$RED"
        echo ""
    fi
}

show_current() {
    echo ""
    print_divider "$BLU"
    echo -e "${BLU}${BLK}  ${ICON_CLOCK}  CURRENT TIMEZONE STATUS${RST}"
    print_divider_bottom "$BLU"
    echo ""

    local cur_date cur_time cur_utc cur_tz cur_status
    cur_tz=$(timedatectl | grep "Time zone" | awk '{print $3}')
    cur_date=$(date '+%Y-%m-%d')
    cur_time=$(date '+%H:%M:%S')
    cur_utc=$(TZ=UTC date '+%H:%M:%S')

    echo -e "  ${ICON_GLOBE} Zone:   ${CYN}${cur_tz}${RST}"
    echo -e "  ${ICON_CLOCK} Local:  ${GRN}${cur_time}${RST}  (${DIM}${cur_date}${RST})"
    echo -e "  ${ICON_GLOBE} UTC:    ${DIM}${cur_utc}${RST}"

    local utc_offset
    utc_offset=$(timedatectl | grep "Universal time" | awk '{print $NF}')
    echo -e "  ${ICON_ARROW} UTC Off:${DIM} ${utc_offset}${RST}"

    local ntp_status
    ntp_status=$(timedatectl | grep "NTP" | awk '{print $NF}')
    if [ "$ntp_status" = "active" ]; then
        echo -e "  ${ICON_CHECK} NTP:    ${GRN}Synchronized${RST}"
    else
        echo -e "  ${ICON_WARN} NTP:    ${YLW}Disabled${RST}"
    fi
    echo ""
}

show_menu() {
    echo ""
    print_divider "$CYN"
    echo -e "${CYN}${BLK}  ${ICON_SKULL}  ⚡ CYBERPUNK TIMEZONE SWITCH ⚡${RST}"
    print_divider_bottom "$CYN"
    echo ""

    # Header row
    printf "  ${BLK}${DIM}%-2s${RST} ${BLK}${DIM}%-4s${RST} ${BLK}${DIM}%-18s${RST} ${BLK}${DIM}%-18s${RST}\n" "KEY" "OFFSET" "TIMEZONE" "REGION"
    SEPA="  ${DIM}├${RST}${DIM}$(printf '─%.0s' {1..4})${RST}  ${DIM}├${RST}${DIM}$(printf '─%.0s' {1..8})${RST}  ${DIM}├${RST}${DIM}$(printf '─%.0s' {1..24})${RST}  ${DIM}├${RST}${DIM}$(printf '─%.0s' {1..18})${RST}"
    echo -e "$SEPA"
    echo ""

    # Indonesia - WIB
    printf "  ${BLK}${GRN} 1${RST}  ${GRN}+07:00${RST}  ${GRN}🇮🇩 Asia/Jakarta${RST}         ${DIM}Indonesia (WIB)${RST}\n"
    # Indonesia - WITA
    printf "  ${BLK}${BRU} 2${RST}  ${BRU}+08:00${RST}  ${BRU}🇮🇩 Asia/Makassar${RST}       ${DIM}Indonesia (WITA)${RST}\n"
    # Indonesia - WIT
    printf "  ${BLK}${ORG} 3${RST}  ${ORG}+09:00${RST}  ${ORG}🇮🇩 Asia/Jayapura${RST}       ${DIM}Indonesia (WIT)${RST}\n"
    # Singapore
    printf "  ${BLK}${CYN} 4${RST}  ${CYN}+08:00${RST}  ${CYN}🇸🇬 Asia/Singapore${RST}       ${DIM}Singapore${RST}\n"
    # Malaysia
    printf "  ${BLK}${MRG} 5${RST}  ${MRG}+08:00${RST}  ${MRG}🇲🇾 Asia/Kuala_Lumpur${RST}   ${DIM}Malaysia${RST}\n"
    # Taiwan
    printf "  ${BLK}${PUR} 6${RST}  ${PUR}+08:00${RST}  ${PUR}🇹🇼 Asia/Taipei${RST}         ${DIM}Taiwan${RST}\n"
    # Japan
    printf "  ${BLK}${RED} 7${RST}  ${RED}+09:00${RST}  ${RED}🇯🇵 Asia/Tokyo${RST}          ${DIM}Japan${RST}\n"
    # Manual
    printf "  ${BLK}${YLW} 8${RST}  ${YLW}???${RST}     ${YLW}✏️  Custom TZ${RST}          ${DIM}Manual Input${RST}\n"
    # Current
    printf "  ${BLK}${BLU} 9${RST}  ${BLU}---${RST}     ${BLU}📊 View Current${RST}        ${DIM}Status Info${RST}\n"
    # Exit
    printf "  ${BLK}${DIM} 0${RST}  ${DIM}---${RST}     ${DIM}🚪 Exit${RST}               ${DIM}Leave Script${RST}\n"

    echo ""
    print_divider_bottom "$CYN"
    echo ""
    echo -e "  ${DIM}└─ ${ICON_FINGER} Pilih opsi [0-8]: ${RST}"
    echo -en "  ${BLK}${CYN} > ${RST}"
    read -r pilihan

    case "$pilihan" in
        1) set_tz "Asia/Jakarta" "WIB - Jakarta, Indonesia" "🇮🇩" ;;
        2) set_tz "Asia/Makassar" "WITA - Makassar, Indonesia" "🇮🇩" ;;
        3) set_tz "Asia/Jayapura" "WIT - Jayapura, Indonesia" "🇮🇩" ;;
        4) set_tz "Asia/Singapore" "Singapore" "🇸🇬" ;;
        5) set_tz "Asia/Kuala_Lumpur" "Malaysia" "🇲🇾" ;;
        6) set_tz "Asia/Taipei" "Taiwan" "🇹🇼" ;;
        7) set_tz "Asia/Tokyo" "Japan" "🇯🇵" ;;
        8)
            echo ""
            echo -en "  ${BLK}${YLW}▸ Enter timezone (e.g. Asia/Bangkok): ${RST}"
            read -r manual_tz
            if [ -n "$manual_tz" ]; then
                set_tz "$manual_tz" "Custom: $manual_tz" "✏️"
            else
                echo -e "  ${YLW}${ICON_WARN} Cancelled: empty input.${RST}"
            fi
            ;;
        9) show_current ;;
        0)
            echo ""
            print_divider "$GRN"
            echo -e "${GRN}${BLK}  ${ICON_ROCKET}  PEACE OUT! See ya! 🤘${RST}"
            print_divider_bottom "$GRN"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            print_divider "$RED"
            echo -e "${RED}${BLK}  ${ICON_X}  INVALID OPTION! Try again.${RST}"
            print_divider_bottom "$RED"
            echo ""
            ;;
    esac
}

# ─── QUICK MODE (CLI ARGS) ───────────────────────────
case "$1" in
    wib)   set_tz "Asia/Jakarta" "WIB - Jakarta, Indonesia" "🇮🇩" ;;
    wita)  set_tz "Asia/Makassar" "WITA - Makassar, Indonesia" "🇮🇩" ;;
    wit)   set_tz "Asia/Jayapura" "WIT - Jayapura, Indonesia" "🇮🇩" ;;
    sg)    set_tz "Asia/Singapore" "Singapore" "🇸🇬" ;;
    my)    set_tz "Asia/Kuala_Lumpur" "Malaysia" "🇲🇾" ;;
    tw)    set_tz "Asia/Taipei" "Taiwan" "🇹🇼" ;;
    jp)    set_tz "Asia/Tokyo" "Japan" "🇯🇵" ;;
    "")    show_menu ;;
    --help|-h)
        echo ""
        print_divider "$YLW"
        echo -e "${YLW}${BLK}  ${ICON_BOLT}  USAGE GUIDE${RST}"
        print_divider_bottom "$YLW"
        echo ""
        echo -e "  ${BLK}Interactive Mode:${RST}"
        echo -e "    sudo ./set-timezone.sh"
        echo ""
        echo -e "  ${BLK}Quick Mode:${RST}"
        echo -e "    sudo ./set-timezone.sh <code>"
        echo ""
        echo -e "  ${BLK}Codes:${RST}"
        printf "    ${GRN}wib${RST}  ${DIM}→ WIB (Jakarta, +07:00)${RST}\n"
        printf "    ${GRN}wita${RST} ${DIM}→ WITA (Makassar, +08:00)${RST}\n"
        printf "    ${GRN}wit${RST}  ${DIM}→ WIT (Jayapura, +09:00)${RST}\n"
        printf "    ${CYN}sg${RST}   ${DIM}→ Singapore (+08:00)${RST}\n"
        printf "    ${MRG}my${RST}   ${DIM}→ Malaysia (+08:00)${RST}\n"
        printf "    ${PUR}tw${RST}   ${DIM}→ Taiwan (+08:00)${RST}\n"
        printf "    ${RED}jp${RST}   ${DIM}→ Japan (+09:00)${RST}\n"
        echo ""
        print_divider_bottom "$YLW"
        echo ""
        exit 0
        ;;
    *)
        echo ""
        print_divider "$RED"
        echo -e "${RED}${BLK}  ${ICON_X}  UNKNOWN COMMAND: $1${RST}"
        print_divider_bottom "$RED"
        echo ""
        echo -e "  ${DIM}Valid codes: ${GRN}wib${RST} ${GRN}wita${RST} ${GRN}wit${RST} ${CYN}sg${RST} ${MRG}my${RST} ${PUR}tw${RST} ${RED}jp${RST}"
        echo -e "  ${DIM}Or run without args for interactive menu.${RST}"
        echo ""
        exit 1
        ;;
esac
