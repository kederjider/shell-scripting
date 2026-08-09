#!/usr/bin/env bash

# Tampilkan dokumentasi awal
echo "=================================================="
echo "          SETUP DUCKDNS DDNS CLIENT               "
echo "=================================================="
echo "Sebelum melanjutkan, pastikan Anda telah:"
echo "1. Mendaftar akun di https://www.duckdns.org"
echo "2. Membuat subdomain di DuckDNS, misalnya:"
echo "   serverrumah.duckdns.org"
echo ""
echo "Anda akan membutuhkan informasi berikut:"
echo "- Domain (hanya nama subdomainnya saja)"
echo "- Token"
echo ""
echo "Contoh:"
echo "  Domain : serverrumah"
echo "  Token  : xxxxxxxxxxxxxxxxxxxxx"
echo "=================================================="
echo ""

# Meminta input dari pengguna
read -p "Masukkan Subdomain DuckDNS Anda: " SUBDOMAIN
read -p "Masukkan Token DuckDNS Anda: " TOKEN

# Validasi input tidak boleh kosong
if [ -z "$SUBDOMAIN" ] || [ -z "$TOKEN" ]; then
    echo "Error: Subdomain dan Token tidak boleh kosong!"
    exit 1
fi

# Update package list dan install curl jika belum ada
sudo apt update && sudo apt install curl -y

# Buat direktori duckdns
mkdir -p ~/duckdns

# Buat file update.sh secara otomatis dengan variabel input
cat << EOF > ~/duckdns/update.sh
#!/bin/bash
echo url="https://www.duckdns.org/update?domains=${SUBDOMAIN}&token=${TOKEN}&ip=" | curl -k -o ~/duckdns/duck.log -K -
EOF

# Berikan izin eksekusi pada update.sh
chmod +x ~/duckdns/update.sh

# Jalankan sekali untuk memastikan berfungsi dan membuat log awal
~/duckdns/update.sh

# Tambahkan ke crontab secara non-interaktif jika belum ada
(crontab -l 2>/dev/null | grep -F "~/duckdns/update.sh" >/dev/null) || (crontab -l 2>/dev/null; echo "*/5 * * * * ~/duckdns/update.sh >/dev/null 2>&1") | crontab -

echo "Instalasi dan konfigurasi DuckDNS selesai!"
echo ""
echo "=================================================="
echo "      PANDUAN LANJUTAN: PORT FORWARDING ROUTER    "
echo "=================================================="
echo "Agar server Anda dapat diakses dari luar jaringan,"
echo "silakan lakukan konfigurasi Port Forwarding pada"
echo "router Anda dengan detail berikut:"
echo ""
echo "  - Internal IP   : 192.168.8.19"
echo "  - Internal Port : 22"
echo "  - External Port : 2222"
echo "  - Protocol      : TCP"
echo "=================================================="