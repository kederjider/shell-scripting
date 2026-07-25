#!/bin/bash

# =========================
# COLOR
# =========================
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
NC="\033[0m"
L_GREEN='\e[92m'
BOLD='\033[1m'

clear
echo -e "${L_GREEN}"
cat << "EOF"
     _             _             _                
  __| |_ __  ___  | | ___   ___ | | ___   _ _ __  
 / _` | '_ \/ __| | |/ _ \ / _ \| |/ / | | | '_ \ 
| (_| | | | \__ \ | | (_) | (_) |   <| |_| | |_) |
 \__,_|_| |_|___/ |_|\___/ \___/|_|\_\\__,_| .__/ 
                                           |_|    
                 [ DNS - LOOKUP v1.0 ]
EOF
echo -e "${NC}"
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║               DNS LOOKUP v1.0                ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
# =========================
# CHECK INPUT
# =========================

read -p "$(echo -e " ${YELLOW}Masukkan domain Target:${NC}") " domain

if [ -z "$domain" ]; then
  echo -e "${RED}Domain tidak boleh kosong${NC}"
  exit 1
fi
echo ""
# =========================
# CHECK COMMAND
# =========================
if ! command -v dig >/dev/null 2>&1; then
  echo -e "${RED}Error: install 'dig' (dnsutils) dulu${NC}"
  exit 1
fi

# =========================
# IP LOOKUP
# =========================
echo -e "${BLUE}[+] IP Address${NC}"

ipv4=$(dig +short A "$domain" | sort -u)
ipv6=$(dig +short AAAA "$domain" | sort -u)

echo -e "  ${GREEN}IPv4:${NC}"
[ -z "$ipv4" ] && echo "    - none" || echo "$ipv4" | sed 's/^/    - /'

echo -e "  ${GREEN}IPv6:${NC}"
[ -z "$ipv6" ] && echo "    - none" || echo "$ipv6" | sed 's/^/    - /'

echo

# =========================
# NS RECORD
# =========================
echo -e "${BLUE}[+] Name Server (NS)${NC}"
ns=$(dig +short NS "$domain")

[ -z "$ns" ] && echo "    - none" || echo "$ns" | sed 's/^/    - /'

echo

# =========================
# HTTP HEADER
# =========================
echo -e "${BLUE}[+] HTTP Info${NC}"

headers=$(curl -sI --max-time 10 "https://$domain")

if [ -z "$headers" ]; then
  headers=$(curl -sI --max-time 10 "http://$domain")
fi

server=$(echo "$headers" | grep -i ^server: | cut -d' ' -f2-)
cf_ray=$(echo "$headers" | grep -i cf-ray)
cf_cache=$(echo "$headers" | grep -i cf-cache-status)
x_cache=$(echo "$headers" | grep -i x-cache)
via=$(echo "$headers" | grep -i ^via:)

# =========================
# DETECT CDN
# =========================
cdn="Tidak terdeteksi"

if echo "$headers" | grep -qi cloudflare; then
  cdn="Cloudflare"
elif echo "$headers" | grep -qi cloudfront; then
  cdn="CloudFront"
elif echo "$headers" | grep -qi fastly; then
  cdn="Fastly"
elif echo "$via" | grep -qi varnish; then
  cdn="Varnish"
fi

# =========================
# CLOUDFLARE STATUS
# =========================
cf_status="tidak terdeteksi"

if echo "$ns" | grep -qi cloudflare; then
  if echo "$headers" | grep -qi cf-ray; then
    cf_status="aktif (proxied)"
  else
    cf_status="DNS only"
  fi
fi

# =========================
# OUTPUT HTTP
# =========================
echo -e "  ${GREEN}Web Server:${NC} ${server:-unknown}"
echo -e "  ${GREEN}CDN:${NC} $cdn"
echo -e "  ${GREEN}Cloudflare:${NC} $cf_status"

echo

echo -e "${BLUE}[+] Header penting${NC}"

[ -n "$server" ] && echo "    - Server: $server"
[ -n "$cf_ray" ] && echo "    - $cf_ray"
[ -n "$cf_cache" ] && echo "    - $cf_cache"
[ -n "$x_cache" ] && echo "    - $x_cache"
[ -n "$via" ] && echo "    - $via"

echo
echo -e "${CYAN}===============================${NC}"