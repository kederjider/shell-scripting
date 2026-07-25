#!/bin/bash

# =============================================
# AUTO REBOOT MANAGER - Versi Premium
# Untuk Ubuntu/Debian
# =============================================

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
w="\e[1;37m" # PUTIH
NC='\033[0m' # No Color

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}❌ Script ini harus dijalankan sebagai root / sudo!${NC}"
    exit 1
fi

# Fungsi untuk menampilkan header
header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🚀 AUTO REBOOT MANAGER                 ║${NC}"
    echo -e "${CYAN}║        ${PURPLE}Sistem Otomatis Ubuntu${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fungsi tampilkan status
show_status() {
    echo -e "${BLUE}📊 STATUS AUTO REBOOT${NC}"
    echo -e "${CYAN}────────────────────────────────────────────${NC}"
    
    if crontab -l 2>/dev/null | grep -q "auto-reboot-script"; then
        local line=$(crontab -l | grep "auto-reboot-script")
        local days=$(echo "$line" | grep -o 'every [0-9]* days' | awk '{print $2}')
        local hour=$(echo "$line" | awk '{print $2}')
        
        echo -e " ${GREEN}✅ AKTIF${NC}"
        echo -e " 📅 Interval     : ${YELLOW}$days hari${NC}"
        echo -e " ⏰ Jadwal Reboot: ${YELLOW}Pukul $hour:00${NC}"
    else
        echo -e " ${RED}❌ TIDAK AKTIF${NC}"
    fi
    echo ""
}

# Menu Utama
while true; do
    header
    show_status
    
    echo -e "${CYAN}┌────┐───────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${w} NO${YELLOW}•${CYAN}│${GREEN} DESKRIPSI                             ${CYAN}│${NC}"
    echo -e "${CYAN}└────┘───────────────────────────────────────┘${NC}"
    echo -e "${CYAN}┌────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│ ${w}1${NC} ${YELLOW}•${NC} Aktifkan Auto Reboot 3 Hari            ${CYAN}│${NC}"
    echo -e "${CYAN}│ ${w}2${NC} ${YELLOW}•${NC} Aktifkan Auto Reboot 7 Hari            ${CYAN}│${NC}"
    echo -e "${CYAN}│ ${w}3${NC} ${YELLOW}•${NC} Aktifkan Auto Reboot 14 Hari           ${CYAN}│${NC}"
    echo -e "${CYAN}│ ${w}4${NC} ${YELLOW}•${NC} Aktifkan Auto Reboot 30 Hari           ${CYAN}│${NC}"
    echo -e "${CYAN}│ ${w}5${NC} ${YELLOW}•${NC} Aktifkan Auto Reboot 90 Hari           ${CYAN}│${NC}"
    echo -e "${CYAN}│ ${w}6${NC} ${YELLOW}•${NC} ${CYAN}Lihat Status                           ${CYAN}│${NC}"
    echo -e "${CYAN}│ ${w}7${NC} ${YELLOW}•${NC} ${RED}Matikan Auto Reboot                    ${CYAN}│${NC}"
    echo -e "${CYAN}│ ${w}8${NC} ${YELLOW}• Ubah Waktu Reboot                      ${CYAN}│${NC}"
    echo -e "${CYAN}│                                            │${NC}"
    echo -e "${CYAN}│ ${RED}0${NC} ${YELLOW}•${NC}${RED} Keluar                                 ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────┘${NC}"
    
    echo -e "${CYAN}┌───(${YELLOW}Pilih${CYAN}─${YELLOW}menu${CYAN})──[${YELLOW}0${CYAN}-${YELLOW}8${CYAN}]───▶️${NC}"
    echo -e "${CYAN}│"
    read -p "$(echo -e ${CYAN}└──▶️ ${RST}) " pilihan

    case $pilihan in
        1) DAYS=3 ;;
        2) DAYS=7 ;;
        3) DAYS=14 ;;
        4) DAYS=30 ;;
        5) DAYS=90 ;;
        6) 
            header
            show_status
            read -p "Tekan Enter untuk kembali..."
            continue
            ;;
        7)
            header
            if crontab -l 2>/dev/null | grep -q "auto-reboot-script"; then
                crontab -l | grep -v "auto-reboot-script" | crontab -
                echo -e "${GREEN}✅ Auto Reboot berhasil dimatikan.${NC}"
            else
                echo -e "${YELLOW}ℹ️ Auto Reboot sudah dalam keadaan mati.${NC}"
            fi
            read -p "Tekan Enter untuk kembali..."
            continue
            ;;
        8)
            header
            echo -e "${YELLOW}Ubah Waktu Reboot${NC}"
            read -p "Masukkan jam reboot (0-23): " jam
            if [[ "$jam" =~ ^[0-9]$|^[1-2][0-3]$ ]]; then
                # Ambil interval saat ini
                if crontab -l 2>/dev/null | grep -q "auto-reboot-script"; then
                    local current_days=$(crontab -l | grep "auto-reboot-script" | grep -o 'every [0-9]* days' | awk '{print $2}')
                    crontab -l | grep -v "auto-reboot-script" > /tmp/crontab_new
                    echo "0 $jam */$current_days * * root /sbin/reboot  # auto-reboot-script every $current_days days" >> /tmp/crontab_new
                    crontab /tmp/crontab_new
                    rm -f /tmp/crontab_new
                    echo -e "${GREEN}✅ Waktu reboot diubah menjadi pukul $jam:00${NC}"
                else
                    echo -e "${RED}❌ Aktifkan dulu auto reboot!${NC}"
                fi
            else
                echo -e "${RED}❌ Jam tidak valid!${NC}"
            fi
            read -p "Tekan Enter untuk kembali..."
            continue
            ;;
        0)
            echo -e "${GREEN}👋 Terima kasih telah menggunakan Auto Reboot Manager!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Pilihan tidak valid!${NC}"
            sleep 1
            continue
            ;;
    esac

    # Proses pengaturan reboot
    if [[ $pilihan =~ ^[1-5]$ ]]; then
        header
        # Hapus cron lama
        crontab -l 2>/dev/null | grep -v "auto-reboot-script" > /tmp/crontab_new 2>/dev/null || true
        
        # Tambah cron baru
        echo "0 3 */$DAYS * * root /sbin/reboot  # auto-reboot-script every $DAYS days" >> /tmp/crontab_new
        crontab /tmp/crontab_new
        rm -f /tmp/crontab_new

        echo -e "${GREEN}✅ BERHASIL!${NC}"
        echo -e "Auto reboot diatur setiap ${YELLOW}$DAYS hari${NC} pukul ${YELLOW}03:00${NC}"
        echo ""
        show_status
        read -p "Tekan Enter untuk kembali ke menu..."
    fi
done