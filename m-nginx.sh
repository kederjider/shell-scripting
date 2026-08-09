#!/bin/bash

# ==============================
# COLOR & STYLE
# ==============================
RST='\033[0m'
BOLD='\033[1m'
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
MAGENTA='\033[95m'
CYAN='\033[96m'
WHITE='\033[97m'

# ==============================
# PATH
# ==============================
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

# ==============================
# UTIL
# ==============================
log(){ echo -e "${CYAN}➜${RST} $1"; }
ok(){ echo -e "${GREEN}✅${RST} $1"; }
err(){ echo -e "${RED}❌${RST} $1"; }

pause(){ read -rp "$(echo -e "${CYAN}⏎ Tekan Enter untuk lanjut...${RST}")"; }

header(){
clear
echo -e "${MAGENTA}${BOLD}╔═════════════════════════════════════════════╗${RST}"
echo -e "${MAGENTA}${BOLD}║${RST}  ${CYAN}⚙️ NGINX HACKER TOOLKIT${RST}                     ${MAGENTA}${BOLD}║${RST}"
echo -e "${MAGENTA}${BOLD}║${RST}  ${YELLOW}🚀 Automation • 🔐 SSL • 🔀 Proxy • 🌐 DDNS${RST}${MAGENTA}${BOLD}║${RST}"
echo -e "${MAGENTA}${BOLD}╚═════════════════════════════════════════════╝${RST}"
echo ""
}

show_menu(){
    echo -e "${CYAN}┌─────┬────────────────────────────────┐${RST}"
    echo -e "${CYAN}│${RST} ${BOLD}No${RST}${CYAN}  │${RST} ${BOLD}Aksi${RST} ${CYAN}                          │${RST}"
    echo -e "${CYAN}├─────┼────────────────────────────────┤${RST}"
    echo -e "${CYAN}│${RST} 1   ${CYAN}│${RST} Install Nginx                  ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 2   ${CYAN}│${RST} Enable Site                    ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 3   ${CYAN}│${RST} Edit Config                    ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 4   ${CYAN}│${RST} Monitor Log                    ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 5   ${CYAN}│${RST} Check Port                     ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 6   ${CYAN}│${RST} Fix Permission                 ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 7   ${CYAN}│${RST} Create Config                  ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 8   ${CYAN}│${RST} Auto SSL                       ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 9   ${CYAN}│${RST} Reverse Proxy                  ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 10  ${CYAN}│${RST} Block Attack                   ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 11  ${CYAN}│${RST} Cloudflare DDNS                ${CYAN}│${RST}"
    echo -e "${CYAN}│${RST} 0   ${CYAN}│${RST} Exit                           ${CYAN}│${RST}"
    echo -e "${CYAN}└─────┴────────────────────────────────┘${RST}"
    echo ""
}

check_nginx(){
    if ! command -v nginx &>/dev/null; then
        err "Nginx belum terinstall!"
        return 1
    fi
}

# ==============================
# 1 INSTALL
# ==============================
install_nginx(){
    log "Installing Nginx..."
    sudo apt update && sudo apt install nginx -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
    ok "Nginx siap digunakan"
}

# ==============================
# 2 ENABLE SITE
# ==============================
enable_site(){
    check_nginx || return
    ls $NGINX_AVAILABLE
    read -p "Nama config: " file

    if [ -f "$NGINX_AVAILABLE/$file" ]; then
        sudo ln -sf $NGINX_AVAILABLE/$file $NGINX_ENABLED/
        sudo nginx -t && sudo systemctl reload nginx
        ok "Site aktif"
    else
        err "File tidak ditemukan"
    fi
}

# ==============================
# 3 EDIT CONFIG
# ==============================
edit_config(){
    check_nginx || return
    ls $NGINX_AVAILABLE
    read -p "Edit file: " file

    [ ! -f "$NGINX_AVAILABLE/$file" ] && err "File tidak ada" && return

    sudo nano $NGINX_AVAILABLE/$file

    if sudo nginx -t; then
        sudo systemctl reload nginx
        ok "Reload sukses"
    else
        err "Config error"
    fi
}

# ==============================
# 4 LOG
# ==============================
log_monitor(){
    sudo journalctl -u nginx -f
}

# ==============================
# 5 PORT
# ==============================
cek_port(){
    read -p "Port: " port
    sudo lsof -i :$port
}

# ==============================
# 6 PERMISSION
# ==============================
fix_permission(){
    read -p "Path: " path
    sudo chown -R www-data:www-data "$path"
    ok "Permission fixed"
}

# ==============================
# 7 CREATE CONFIG
# ==============================
create_config(){
    read -p "Domain: " domain
    read -p "Root path: " root

    sudo mkdir -p "$root"
    sudo chown -R www-data:www-data "$root"

    sudo tee $NGINX_AVAILABLE/$domain > /dev/null <<EOF
server {
    listen 80;
    server_name $domain www.$domain;

    root $root;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

    sudo ln -sf $NGINX_AVAILABLE/$domain $NGINX_ENABLED/
    sudo nginx -t && sudo systemctl reload nginx

    ok "Config dibuat"
}

# ==============================
# 8 SSL
# ==============================
auto_ssl(){
    read -p "Domain: " domain
    sudo apt install certbot python3-certbot-nginx -y
    sudo certbot --nginx -d $domain -d www.$domain
}

# ==============================
# 9 REVERSE PROXY
# ==============================
reverse_proxy(){
    read -p "Domain: " domain
    read -p "Backend port: " port

    sudo tee $NGINX_AVAILABLE/$domain > /dev/null <<EOF
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://127.0.0.1:$port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    sudo ln -sf $NGINX_AVAILABLE/$domain $NGINX_ENABLED/
    sudo nginx -t && sudo systemctl reload nginx

    ok "Reverse proxy aktif"
}

# ==============================
# 10 SECURITY
# ==============================
block_attack(){
    file="/etc/nginx/security.conf"

    sudo tee $file > /dev/null <<EOF
location ~* (wp-admin|xmlrpc|\.env|\.git) {
    deny all;
}
EOF

    ok "Security rule dibuat"
    echo "Tambahkan ke config:"
    echo "include $file;"
}

# ==============================
# 11 CLOUDFLARE DDNS
# ==============================
cloudflare_ddns(){
    read -p "Zone ID: " zone
    read -p "Record ID: " record
    read -p "Domain: " domain
    read -p "API Token: " token

    IP=$(curl -s ifconfig.me)

    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$record" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$domain\",\"content\":\"$IP\",\"ttl\":120,\"proxied\":false}"

    ok "DDNS updated → $IP"
}

# ==============================
# MAIN MENU
# ==============================
while true; do
header
show_menu
read -rp " ▶ Pilih menu: " opt

case $opt in
1) install_nginx ;;
2) enable_site ;;
3) edit_config ;;
4) log_monitor ;;
5) cek_port ;;
6) fix_permission ;;
7) create_config ;;
8) auto_ssl ;;
9) reverse_proxy ;;
10) block_attack ;;
11) cloudflare_ddns ;;
0) clear; newmenu ;;
*) err "Pilihan salah" ;;
esac

pause
done