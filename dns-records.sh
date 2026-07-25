#!/bin/bash

# =========================
# COLOR & STYLING
# =========================
R=$'\033[1;31m'
G=$'\033[1;32m'
Y=$'\033[1;33m'
B=$'\033[1;34m'
C=$'\033[1;36m'
M=$'\033[1;35m'
W=$'\033[1;37m'
N=$'\033[0m'
DIM=$'\033[2m'

echo() {
  local use_esc=0
  if [ "$1" = "-e" ]; then
    use_esc=1
    shift
  fi

  if [ "$use_esc" -eq 1 ]; then
    printf '%b\n' "$*"
  else
    printf '%s\n' "$*"
  fi
}

print_header() {
  echo -e "${C}╔══════════════════════════════════════════════════════════╗${N}"
  echo -e "${C}║${M}          🔍 ULTIMATE RECON MODE 2024${C}                     ║${N}"
  echo -e "${C}╚══════════════════════════════════════════════════════════╝${N}"
}

print_section() {
  echo
  echo -e "${C}───────────────────────────────────────────────────────────${N}"
  echo -e "${B}$1${N}"
  echo -e "${C}───────────────────────────────────────────────────────────${N}"
}

print_port_reference() {
  print_section "📚 Port Reference Guide"
  
  echo -e "${Y}╭─ Port Umum & Layanan${N}"
  echo -e "${Y}│${N} ⬢ ${W}20${N}     ${Y}FTP Data${N}           Transfer data FTP"
  echo -e "${Y}│${N} ⬢ ${W}21${N}     ${Y}FTP Control${N}         Kontrol FTP"
  echo -e "${Y}│${N} ⬢ ${W}22${N}     ${Y}SSH${N}                 Akses server aman"
  echo -e "${Y}│${N} ⬢ ${W}80${N}     ${Y}HTTP${N}                Website tanpa enkripsi"
  echo -e "${Y}│${N} ⬢ ${W}443${N}    ${Y}HTTPS${N}               Website dengan SSL/TLS"
  echo -e "${Y}│${N} ⬢ ${W}25${N}     ${Y}SMTP${N}                Mengirim email"
  echo -e "${Y}│${N} ⬢ ${W}53${N}     ${Y}DNS${N}                 Menerjemahkan domain"
  echo -e "${Y}│${N} ⬢ ${W}3389${N}   ${Y}RDP${N}                 Remote Desktop Windows"
  echo -e "${Y}╰${N}"
  
  echo
  echo -e "${M}╭─ Port Database${N}"
  echo -e "${M}│${N} ⬢ ${W}1433${N}   ${Y}MS SQL Server${N}       Database SQL Server"
  echo -e "${M}│${N} ⬢ ${W}3306${N}   ${Y}MySQL/MariaDB${N}       Database MySQL"
  echo -e "${M}│${N} ⬢ ${W}5432${N}   ${Y}PostgreSQL${N}          Database PostgreSQL"
  echo -e "${M}│${N} ⬢ ${W}27017${N}  ${Y}MongoDB${N}             Database NoSQL"
  echo -e "${M}│${N} ⬢ ${W}6379${N}   ${Y}Redis${N}               Database/cache Redis"
  echo -e "${M}╰${N}"
  
  echo
  echo -e "${B}╭─ Web Server & Aplikasi${N}"
  echo -e "${B}│${N} ⬢ ${W}3000${N}   ${Y}Node.js${N}             Development server"
  echo -e "${B}│${N} ⬢ ${W}5000${N}   ${Y}Flask${N}               Web server Python"
  echo -e "${B}│${N} ⬢ ${W}8080${N}   ${Y}HTTP Alt${N}            Web server alternatif"
  echo -e "${B}│${N} ⬢ ${W}9000${N}   ${Y}PHP-FPM${N}             FastCGI/SonarQube"
  echo -e "${B}╰${N}"
  
  echo
  echo -e "${G}╭─ Remote Access${N}"
  echo -e "${G}│${N} ⬢ ${W}22${N}     ${Y}SSH${N}                 Remote Linux/Unix"
  echo -e "${G}│${N} ⬢ ${W}3389${N}   ${Y}RDP${N}                 Remote Desktop"
  echo -e "${G}│${N} ⬢ ${W}5900${N}   ${Y}VNC${N}                 Remote lintas platform"
  echo -e "${G}╰${N}"
  
  echo
  echo -e "${C}╭─ VPN${N}"
  echo -e "${C}│${N} ⬢ ${W}500${N}    ${Y}IPsec IKE${N}           Negosiasi VPN"
  echo -e "${C}│${N} ⬢ ${W}1194${N}   ${Y}OpenVPN${N}             VPN OpenVPN"
  echo -e "${C}│${N} ⬢ ${W}51820${N}  ${Y}WireGuard${N}           VPN WireGuard"
  echo -e "${C}╰${N}"
}

# =========================
# INPUT
# =========================
print_header
read -p "$(echo -e ${Y}Enter target domain: ${N} )" domain

if [ -z "$domain" ]; then
  echo -e "${R}Domain tidak boleh kosong!${N}"
  exit 1
fi

echo -e "${Y}🎯 Target Domain:${N} ${W}$domain${N}"
echo

# =========================
# CHECK TOOLS
# =========================
echo -e "${B}⚙️  Checking dependencies...${N}"
for cmd in dig curl; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo -e "${R}✗ Error: $cmd belum terinstall${N}"
    exit 1
  else
    echo -e "${G}✓ $cmd ${DIM}(installed)${N}"
  fi
done
echo

# =========================
# DNS INFO
# =========================
print_section "🔗 DNS Records"

ipv4=$(dig +short A "$domain" 2>/dev/null)
ipv6=$(dig +short AAAA "$domain" 2>/dev/null)
ns=$(dig +short NS "$domain" 2>/dev/null)
mx=$(dig +short MX "$domain" 2>/dev/null)
txt=$(dig +short TXT "$domain" 2>/dev/null)

echo -e "  ${W}IPv4${N}"
[ -z "$ipv4" ] && echo -e "    ${DIM}(not found)${N}" || echo "$ipv4" | sed "s/^/    ${G}→${N} /"

echo -e "  ${W}IPv6${N}"
[ -z "$ipv6" ] && echo -e "    ${DIM}(not found)${N}" || echo "$ipv6" | sed "s/^/    ${G}→${N} /"

echo -e "  ${W}Nameservers${N}"
[ -z "$ns" ] && echo -e "    ${DIM}(not found)${N}" || echo "$ns" | sed "s/^/    ${G}→${N} /"

echo -e "  ${W}Mail Servers${N}"
[ -z "$mx" ] && echo -e "    ${DIM}(not found)${N}" || echo "$mx" | sed "s/^/    ${G}→${N} /"

echo -e "  ${W}TXT Records${N}"
[ -z "$txt" ] && echo -e "    ${DIM}(not found)${N}" || echo "$txt" | sed "s/^/    ${G}→${N} /"

# =========================
# HTTP HEADER
# =========================
print_section "🌐 HTTP/HTTPS Analysis"

headers=$(curl -sI --max-time 10 "https://$domain" 2>/dev/null)
[ -z "$headers" ] && headers=$(curl -sI --max-time 10 "http://$domain" 2>/dev/null)

if [ -z "$headers" ]; then
  echo -e "  ${R}✗ Could not reach website (HTTP/HTTPS)${N}"
else
  server=$(echo "$headers" | grep -i ^server: | cut -d' ' -f2-)
  cf=$(echo "$headers" | grep -i cf-ray)
  cf_cache=$(echo "$headers" | grep -i cf-cache-status)
  x_cache=$(echo "$headers" | grep -i x-cache)
  via=$(echo "$headers" | grep -i ^via:)

  # =========================
  # DETECT CDN/WAF
  # =========================
  cdn="Not detected"

  if echo "$headers" | grep -qi cloudflare; then
    cdn="Cloudflare"
  elif echo "$headers" | grep -qi cloudfront; then
    cdn="CloudFront"
  elif echo "$headers" | grep -qi fastly; then
    cdn="Fastly"
  elif echo "$headers" | grep -qi akamai; then
    cdn="Akamai"
  elif echo "$via" | grep -qi varnish; then
    cdn="Varnish"
  fi

  # =========================
  # CLOUDFLARE STATUS
  # =========================
  cf_status="Not detected"

  if echo "$ns" | grep -qi cloudflare; then
    if echo "$headers" | grep -qi cf-ray; then
      cf_status="Active (proxied)"
    else
      cf_status="DNS only"
    fi
  fi

  echo -e "  ${W}Web Server${N}  : ${Y}${server:-unknown}${N}"
  echo -e "  ${W}CDN/WAF${N}     : ${Y}$cdn${N}"
  echo -e "  ${W}Cloudflare${N}  : ${Y}$cf_status${N}"

  echo
  echo -e "  ${W}Important Headers${N}:"
  if [ -n "$server" ] || [ -n "$cf" ] || [ -n "$cf_cache" ] || [ -n "$x_cache" ] || [ -n "$via" ]; then
    [ -n "$server" ] && echo -e "    ${G}→${N} $server"
    [ -n "$cf" ] && echo -e "    ${G}→${N} $cf"
    [ -n "$cf_cache" ] && echo -e "    ${G}→${N} $cf_cache"
    [ -n "$x_cache" ] && echo -e "    ${G}→${N} $x_cache"
    [ -n "$via" ] && echo -e "    ${G}→${N} $via"
  else
    echo -e "    ${DIM}(none found)${N}"
  fi
fi

# =========================
# GEO IP
# =========================
print_section "🌍 GeoIP Information"

ip=$(echo "$ipv4" | head -n1)

if [ -z "$ip" ]; then
  echo -e "  ${DIM}(No IPv4 address found)${N}"
else
  geo=$(curl -s "http://ip-api.com/json/$ip" 2>/dev/null)

  if [ -z "$geo" ]; then
    echo -e "  ${W}IP Address${N}: ${Y}$ip${N}"
    echo -e "  ${R}✗ Could not fetch GeoIP data${N}"
  else
    country=$(echo "$geo" | grep -o '"country":"[^"]*' | cut -d':' -f2 | tr -d '"')
    isp=$(echo "$geo" | grep -o '"isp":"[^"]*' | cut -d':' -f2 | tr -d '"')

    echo -e "  ${W}IP Address${N}: ${Y}$ip${N}"
    echo -e "  ${W}Country${N}    : ${Y}${country:-unknown}${N}"
    echo -e "  ${W}ISP${N}        : ${Y}${isp:-unknown}${N}"
  fi
fi

# =========================
# SIMPLE PORT CHECK
# =========================
print_section "⚡ Quick Port Check"

ports=(20 21 22 23 25 53 67 68 69 80 110 119 123 135 137 138 139 143 161 162 179 389 443 445 465 514 587 636 873 989 990 993 995 1433 1521 27017 3306 5432 6379 9042 3000 5000 5601 8000 8080 8081 8443 9000 3389 5900 500 1701 1723 4500 1194 51820)

for port in "${ports[@]}"; do
  if timeout 1 bash -c "echo >/dev/tcp/$domain/$port" 2>/dev/null; then
    echo -e "  ${G}✓ [OPEN]${N}   Port ${W}$port${N}"
  else
    echo -e "  ${R}✗ [CLOSED]${N} Port ${DIM}$port${N}"
  fi
done

echo
print_port_reference

echo
echo -e "${C}╔══════════════════════════════════════════════════════════╗${N}"
echo -e "${C}║${G}                   ✓ SCAN COMPLETED${C}                       ║${N}"
echo -e "${C}╚══════════════════════════════════════════════════════════╝${N}"