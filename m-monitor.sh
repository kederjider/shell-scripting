#!/usr/bin/env bash
set -euo pipefail

RESET='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
MAGENTA='\033[35m'
BOLD='\033[1m'

info() { echo -e "${CYAN}➜${RESET} $*"; }
ok() { echo -e "${GREEN}✅${RESET} $*"; }
err() { echo -e "${RED}❌${RESET} $*"; }
clear
show_header() {
    echo
    echo -e "${MAGENTA}${BOLD}╔══════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}${BOLD}║${RESET}  ${CYAN}📊 MONITOR TOOLS${RESET}            ${MAGENTA}${BOLD}║${RESET}"
    echo -e "${MAGENTA}${BOLD}║${RESET}  ${YELLOW}⚡ htop • gotop • btop${RESET}      ${MAGENTA}${BOLD}║${RESET}"
    echo -e "${MAGENTA}${BOLD}╚══════════════════════════════╝${RESET}"
    echo
}

check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

install_package() {
    local pkg="$1"
    if check_cmd "$pkg"; then
        ok "$pkg sudah terinstal"
    else
        info "Menginstall $pkg..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y "$pkg"
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Syu --noconfirm "$pkg"
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y "$pkg"
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y "$pkg"
        else
            err "Package manager tidak dikenali. Instal manual diperlukan."
            exit 1
        fi
        ok "$pkg berhasil diinstal"
    fi
}

ensure_tools() {
    info "Memeriksa alat monitoring..."
    install_package htop
    install_package gotop
    install_package btop
}

run_tool() {
    case "$1" in
        1)
            if check_cmd htop; then
                clear
                echo -e "${RED}tekan q untuk keluar${RESET}"
                sleep 2
                htop
            else
                err "htop belum terinstal"
            fi
            ;;
        2)
            if check_cmd gotop; then
                clear
                echo -e "${RED}tekan q untuk keluar${RESET}"
                sleep 2
                gotop
            else
                err "gotop belum terinstal"
            fi
            ;;
        3)
            if check_cmd btop; then
                clear
                echo -e "${RED}tekan q untuk keluar${RESET}"
                sleep 2
                btop
            else
                err "btop belum terinstal"
            fi
            ;;
        *)
            err "Pilihan tidak valid"
            ;;
    esac
}

show_menu() {
    echo -e "${CYAN}┌─────┬────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET} ${BOLD}No${RESET}  ${CYAN}│${RESET} ${BOLD}Tool${RESET}                   ${CYAN}│${RESET}"
    echo -e "${CYAN}├─────┼────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET} 1   ${CYAN}│${RESET} htop                   ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET} 2   ${CYAN}│${RESET} gotop                  ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET} 3   ${CYAN}│${RESET} btop                   ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET} 0   ${CYAN}│${RESET} Keluar                 ${CYAN}│${RESET}"
    echo -e "${CYAN}└─────┴────────────────────────┘${RESET}"
    echo
}

main() {
    show_header
    ensure_tools
    while true; do
        show_menu
        #read -rp "$(echo -e "${CYAN}▶ Pilih alat monitoring:${RESET}" )" choice
        echo -e "${CYAN}┌───(${YELLOW}Pilih alat monitoring${RESET}${CYAN})───${RESET}"
        read -rp "$(echo -e "${CYAN}└──▶️ ${RESET}") " choice
        case "$choice" in
            1|2|3)
                run_tool "$choice"
                ;;
            0)
                ok "Keluar"
                exit 0
                ;;
            *)
                err "Pilihan salah"
                ;;
        esac
        echo
    done
}

main "$@"
