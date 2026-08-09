#!/bin/bash

# ==============================
# COLOR & TEXT STYLE
# ==============================
RST='\e[0m'
BOLD='\e[1m'
RED='\e[91m'
GREEN='\e[92m'
YELLOW='\e[93m'
BLUE='\e[94m'
MAGENTA='\e[95m'
CYAN='\e[96m'
WHITE='\e[97m'

# ==============================
# HELPER FUNCTIONS
# ==============================
log() { echo -e "${GREEN}[✓]${RST} $1"; }
warn() { echo -e "${YELLOW}[!]${RST} $1"; }
err() { echo -e "${RED}[✗]${RST} $1"; }
step() { echo -e "${CYAN}[*]${RST} $1"; }

# ==============================
# HEADER FUNCTION
# ==============================
header() {
    clear
    echo -e "${MAGENTA}${BOLD}╔═══════════════════════════════════════════╗${RST}"
    echo -e "${MAGENTA}${BOLD}║${RST}    ${CYAN}🔥 TAILSCALE MANAGER PRO${RST}               ${MAGENTA}${BOLD}║${RST}"
    echo -e "${MAGENTA}${BOLD}║${RST}  ${YELLOW}VPN Network & Subnet Tunnel${RST}              ${MAGENTA}${BOLD}║${RST}"
    echo -e "${MAGENTA}${BOLD}╚═══════════════════════════════════════════╝${RST}"
    echo ""
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        warn "Disarankan jalankan sebagai root (${BOLD}sudo${RST})"
    fi
}

install_tailscale() {
    # Check if Tailscale is already installed
    if command -v tailscale &> /dev/null; then
        log "Tailscale sudah terinstall"
        echo ""
        return
    fi

    echo -e "${YELLOW}[*]${RST} Installing Tailscale..."
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    curl -fsSL https://tailscale.com/install.sh | sh 2>&1 | while IFS= read -r line; do
        echo -e "${CYAN}│${RST} $line"
    done
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
    echo ""

    step "Mengaktifkan layanan Tailscale..."
    sudo systemctl enable tailscaled
    sudo systemctl start tailscaled
    log "Service Tailscale diaktifkan"

    echo ""
    warn "Login akan dibuka di browser..."
    echo ""

    sudo tailscale up

    echo ""
    log "Jika sudah login, cek IP di menu status"
}

show_ip() {
    IP=$(tailscale ip -4 2>/dev/null)
    if [ -n "$IP" ]; then
        echo -e "${GREEN}[✓]${RST} Tailscale IP: ${BOLD}${YELLOW}${IP}${RST}"
    else
        warn "Belum login / belum aktif"
    fi
}

check_status() {
    echo -e "${GREEN}[✓]${RST} ${BOLD}Status Tailscale:${RST}"
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    tailscale status | while IFS= read -r line; do
        echo -e "${CYAN}│${RST} $line"
    done
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
    echo ""
    show_ip
}

toggle_service() {
    STATUS=$(systemctl is-active tailscaled)

    if [ "$STATUS" = "active" ]; then
        echo -e "${RED}[!]${RST} Tailscale sedang ${BOLD}${GREEN}RUNNING${RST}"
        echo ""
        echo -e "${YELLOW}[?]${RST} Apakah yakin ingin ${BOLD}mematikan${RST} Tailscale?"
        read -p "    Ketik (y/n): " confirm
        
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo -e "${CYAN}[i]${RST} Dibatalkan"
            return
        fi
        
        warn "Tailscale sedang ${BOLD}RUNNING${RST} → stopping..."
        echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
        sudo systemctl disable tailscaled 2>&1 | while IFS= read -r line; do
            echo -e "${CYAN}│${RST} $line"
        done
        sudo systemctl stop tailscaled 2>&1 | while IFS= read -r line; do
            echo -e "${CYAN}│${RST} $line"
        done
        echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
        log "Tailscale dimatikan"
    else
        echo -e "${YELLOW}[!]${RST} Tailscale sedang ${BOLD}${RED}OFF${RST}"
        echo ""
        echo -e "${YELLOW}[?]${RST} Apakah yakin ingin ${BOLD}menjalankan${RST} Tailscale?"
        read -p "    Ketik (y/n): " confirm
        
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo -e "${CYAN}[i]${RST} Dibatalkan"
            return
        fi
        
        warn "Tailscale sedang ${BOLD}OFF${RST} → starting..."
        echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
        sudo systemctl enable tailscaled 2>&1 | while IFS= read -r line; do
            echo -e "${CYAN}│${RST} $line"
        done
        sudo systemctl start tailscaled 2>&1 | while IFS= read -r line; do
            echo -e "${CYAN}│${RST} $line"
        done
        echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
        log "Tailscale dijalankan"
    fi
}

advanced_mode() {
    echo ""
    echo -e "${MAGENTA}${BOLD}╔═══════════════════════════════════════════╗${RST}"
    echo -e "${MAGENTA}${BOLD}║${RST}      ${CYAN}ADVANCED MODE CONFIGURATION${RST}     ${MAGENTA}${BOLD}║${RST}"
    echo -e "${MAGENTA}${BOLD}╚═══════════════════════════════════════════╝${RST}"
    echo ""

    echo -e "${MAGENTA}[?]${RST} Masukkan subnet LAN (contoh: 192.168.1.0/24):"
    read -p "    Input: " SUBNET

    if [[ ! "$SUBNET" =~ /24$ ]]; then
        err "Format harus /24 (contoh: ${BOLD}192.168.1.0/24${RST})"
        return
    fi

    echo ""
    step "Menjalankan konfigurasi lanjutan..."
    echo ""

    CMD="sudo tailscale up --advertise-routes=$SUBNET --advertise-exit-node --ssh"

    echo -e "${YELLOW}[*]${RST} Perintah yang akan dijalankan:"
    echo -e "${BLUE}${BOLD}→${RST} ${CYAN}${CMD}${RST}"
    echo ""

    eval $CMD

    echo ""
    echo -e "${GREEN}[✓]${RST} ${BOLD}Advanced mode aktif:${RST}"
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    echo -e "${CYAN}│${RST} 📡 Subnet LAN: ${BOLD}${YELLOW}${SUBNET}${RST}"
    echo -e "${CYAN}│${RST} 🚪 Exit Node: ${BOLD}${GREEN}aktif${RST}"
    echo -e "${CYAN}│${RST} 🔐 SSH Tailscale: ${BOLD}${GREEN}aktif${RST}"
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
}

auto_detect_login() {
    step "Mendeteksi login Tailscale..."
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"

    for i in {1..10}; do
        IP=$(tailscale ip -4 2>/dev/null)
        if [ -n "$IP" ]; then
            echo -e "${CYAN}│${RST} ${GREEN}Deteksi berhasil pada percobaan $i${RST}"
            echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
            log "Login berhasil! IP: ${BOLD}${YELLOW}${IP}${RST}"
            return
        fi
        echo -e "${CYAN}│${RST} Percobaan $i/10..."
        sleep 3
    done

    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
    warn "Belum terdeteksi login (cek manual)"
}

troubleshoot() {
    echo ""
    echo -e "${MAGENTA}${BOLD}╔═══════════════════════════════════════════╗${RST}"
    echo -e "${MAGENTA}${BOLD}║${RST}       ${CYAN}TROUBLESHOOTING MODE${RST}          ${MAGENTA}${BOLD}║${RST}"
    echo -e "${MAGENTA}${BOLD}╚═══════════════════════════════════════════╝${RST}"
    echo ""

    step "Step 1: Menutup Tailscale..."
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    sudo tailscale down 2>&1 | while IFS= read -r line; do
        echo -e "${CYAN}│${RST} $line"
    done
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
    echo ""

    step "Step 2: Membuka Tailscale kembali..."
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    sudo tailscale up 2>&1 | while IFS= read -r line; do
        echo -e "${CYAN}│${RST} $line"
    done
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
    echo ""

    log "Troubleshooting selesai. Jika ada link login, buka di browser."
}

# ==============================
# MAIN LOOP
# ==============================

check_root

header

    echo -e "${CYAN}${BOLD}PILIH MENU:${RST}"
    echo -e "${CYAN}┌─────────────────────────────────────────┐${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[1]${RST} Install + Login Tailscale           ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[2]${RST} Lihat Status & IP Address           ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[3]${RST} Toggle Service (On/Off)             ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[4]${RST} Advanced Mode (Subnet+Exit+SSH)     ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${BLUE}${BOLD}[5]${RST} Troubleshooting (Reset Koneksi)     ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} ${RED}${BOLD}[0]${RST} Kembali ke Menu Utama               ${CYAN}│${RST}"
    echo -e "${CYAN}└─────────────────────────────────────────┘${RST}"
    echo ""

    read -p "$(echo -e ${MAGENTA}[?]${RST} Pilih menu: ) " pilih
    echo ""

    case $pilih in
        1)
            install_tailscale
            auto_detect_login
            ;;
        2)
            check_status
            ;;
        3)
            toggle_service
            ;;
        4)
            advanced_mode
            ;;
        5)
            troubleshoot
            ;;
        0)
            clear
            newmenu
            ;;
        *)
            err "Pilihan tidak valid"
            sleep 2
            exec "$0"
            ;;
    esac

    echo ""
    echo -e "${CYAN}[i]${RST} Tekan Enter untuk melanjutkan..."
    read