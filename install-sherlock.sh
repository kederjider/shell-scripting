#!/bin/bash
# =============================================
#   SHERLOCK INSTALLER - Dengan Pengecekan
# =============================================

clear
echo -e "\033[1;32m========================================\033[0m"
echo -e "\033[1;36m     SHERLOCK INSTALLER v1.1\033[0m"
echo -e "\033[1;32m========================================\033[0m"
echo -e "\033[1;33mOSINT Username Finder - 400+ Platform\033[0m\n"

# Fungsi cek apakah Sherlock sudah terinstall
cek_sherlock() {
    if command -v sherlock &> /dev/null; then
        echo -e "\033[1;32m[✔] Sherlock sudah terpasang di sistem anda!\033[0m"
        echo -e "\033[1;33mVersi: $(sherlock --version 2>/dev/null || echo 'Unknown')\033[0m"
        echo -e "\nAnda bisa langsung menggunakan perintah: \033[1;36msherlock <username>\033[0m"
        exit 0
    fi
}

# Jalankan pengecekan
cek_sherlock

# Jika sampai sini berarti belum terinstall
echo -e "\033[1;33m[!] Sherlock belum terdeteksi. Melanjutkan instalasi...\033[0m\n"

# Update sistem
echo -e "\033[1;34m[+] Updating package list...\033[0m"
sudo apt update -qq

# Install dependencies
echo -e "\033[1;34m[+] Installing dependencies (python3, pipx, git)...\033[0m"
sudo apt install -y python3 python3-pip python3-venv git curl pipx

# Setup pipx
echo -e "\033[1;34m[+] Configuring pipx...\033[0m"
pipx ensurepath

# Install Sherlock
echo -e "\033[1;34m[+] Installing Sherlock via pipx (Recommended)...\033[0m"
sleep 1
wget https://raw.githubusercontent.com/sherlock-project/sherlock/master/sherlock/sherlock.py -O /tmp/test || true
sleep 1
pipx install sherlock-project

# Final check
if command -v sherlock &> /dev/null; then
    echo -e "\033[1;32m[✔] Instalasi Sherlock BERHASIL!\033[0m"
    echo -e "\033[1;33mVersi: $(sherlock --version)\033[0m"
    echo -e "\n\033[1;36mContoh Penggunaan:\033[0m"
    echo -e "   sherlock elonmusk"
    echo -e "   sherlock elonmusk --timeout 15 -o hasil.txt"
else
    echo -e "\033[1;31m[✘] Instalasi gagal. Coba jalankan ulang script.\033[0m"
fi

echo -e "\n\033[1;32mSelesai! Selamat menggunakan Sherlock 🔥\033[0m"