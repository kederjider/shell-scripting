#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo '❌ Jalankan dengan sudo/root.'; exit 1; }
WG_DIR=/etc/wireguard; CONF=$WG_DIR/wg0.conf; CLIENT_DIR=$WG_DIR/clients
CYAN='\033[38;5;51m'; GREEN='\033[38;5;46m'; RED='\033[38;5;196m'; MAGENTA='\033[38;5;201m'; PURPLE='\033[38;5;129m'; YELLOW='\033[38;5;226m'; DIM='\033[38;5;242m'; NC='\033[0m'; BOLD='\033[1m'
ok(){ echo -e "${GREEN}  ✔ $*${NC}"; }; pause(){ read -rp $'\n  Tekan Enter untuk kembali ke menu...' _; }
line(){ printf '%b\n' "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
check_wireguard(){
 if command -v wg >/dev/null 2>&1 && command -v wg-quick >/dev/null 2>&1; then
  ok 'WireGuard sudah terinstall. Pemeriksaan dilewati.'
  return
 fi

 echo -e "${YELLOW}  ⚠ WireGuard belum terinstall pada sistem ini.${NC}"
 read -rp '  Install WireGuard sekarang melalui install-wireguard.sh? [y/N]: ' answer
 if [[ $answer =~ ^[Yy]$ ]]; then
  local installer
  installer="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install-wireguard"
  if [[ ! -f $installer ]]; then
   echo -e "${RED}  ✖ File install-wireguard.sh tidak ditemukan: $installer${NC}"
   exit 1
  fi
  chmod +x "$installer"
  exec bash "$installer"
 else
  echo -e "${RED}  ✖ WireGuard diperlukan untuk menjalankan manager.${NC}"
  exit 1
 fi
}
header(){
 clear
 printf '%b\n' "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
 printf '%b\n' "${CYAN}║${NC}  ${MAGENTA}${BOLD}W I R E G U A R D   C Y B E R P U N K   M A N A G E R${NC}     ${CYAN}║${NC}"
 printf '%b\n' "${CYAN}║${NC}  ${DIM}SECURE TUNNEL CONTROL // SYSTEM ONLINE // v1.0${NC}            ${CYAN}║${NC}"
 printf '%b\n' "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
}
next_ip(){ awk -F'[ ./]+' '/AllowedIPs = 10\.66\.66\./{print $4}' "$CONF" 2>/dev/null | sort -n | awk 'BEGIN{x=5} {if($1>=x)x=$1+1} END{print x}'; }
add_client(){
 read -rp 'Nama client: ' name
 [[ $name =~ ^[A-Za-z0-9_-]+$ && ! -e "$CLIENT_DIR/$name.conf" ]] || { echo 'Nama tidak valid atau sudah ada.'; return; }
 local octet ip private public server_pub endpoint
 octet=$(next_ip); ((octet <= 254)) || { echo 'Pool IP penuh.'; return; }; ip="10.66.66.$octet"
 private=$(wg genkey); public=$(printf '%s' "$private" | wg pubkey); server_pub=$(cat "$WG_DIR/server_public.key")
 endpoint=$(awk -F' = ' '/Endpoint =/{print $2; exit}' "$CLIENT_DIR"/*.conf 2>/dev/null || true)
 [[ -n $endpoint ]] || read -rp 'Endpoint publik IP:PORT: ' endpoint
 cat >>"$CONF" <<EOF

# Client: $name
[Peer]
PublicKey = $public
AllowedIPs = $ip/32
EOF
 cat >"$CLIENT_DIR/$name.conf" <<EOF
[Interface]
PrivateKey = $private
Address = $ip/32
DNS = 1.1.1.1
[Peer]
PublicKey = $server_pub
Endpoint = $endpoint
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
 qrencode -t ansiutf8 <"$CLIENT_DIR/$name.conf" >"$CLIENT_DIR/$name.qr.txt"
 wg syncconf wg0 <(wg-quick strip wg0); ok "Client $name dibuat."; cat "$CLIENT_DIR/$name.qr.txt"
}
delete_client(){
 read -rp 'Nama client yang dihapus: ' name
 [[ -f "$CLIENT_DIR/$name.conf" ]] || { echo 'Client tidak ditemukan.'; return; }
 local pub; pub=$(awk -F' = ' '/PrivateKey/{print $2; exit}' "$CLIENT_DIR/$name.conf" | wg pubkey)
 wg set wg0 peer "$pub" remove 2>/dev/null || true
 sed -i "/^# Client: $name$/,/^AllowedIPs = .*\/32$/d" "$CONF"
 rm -f "$CLIENT_DIR/$name.conf" "$CLIENT_DIR/$name.qr.txt"; systemctl restart wg-quick@wg0; ok "Client $name dihapus."
}
status_clients(){
 echo -e "${CYAN}${BOLD}  ◈ WIREGUARD LIVE TELEMETRY${NC}"; line
 wg show wg0 || true; echo; echo -e "${YELLOW}  ⇅ BANDWIDTH PER PEER${NC}"; wg show wg0 transfer || true
}
list_clients(){
 echo -e "${CYAN}${BOLD}  ◈ REGISTERED CLIENTS${NC}"; line
 local files=(); mapfile -t files < <(find "$CLIENT_DIR" -maxdepth 1 -name '*.conf' -printf '%f\n' | sort)
 if ((${#files[@]} == 0)); then echo -e "${DIM}  Belum ada client.${NC}"; else printf '  ${GREEN}%-4s %-30s${NC}\n' 'ID' 'CONFIG'; local i=1 f; for f in "${files[@]}"; do printf '  %-4s %-30s\n' "$i" "$f"; ((i++)); done; fi
}
check_wireguard
while true; do
 header; echo -e " ${DIM}Node:${NC} ${GREEN}$(hostname)${NC}   ${DIM}Interface:${NC} ${GREEN}wg0${NC}   ${DIM}Time:${NC} ${GREEN}$(date '+%H:%M:%S')${NC}"; line
 echo -e "  ${MAGENTA}${BOLD}[ OPERATIONS ]${NC}"
 echo -e "  ${CYAN}[1]${NC} 🆕  ${BOLD}Deploy New Client${NC}       ${CYAN}[4]${NC} 🗑️  ${BOLD}Client Registry${NC}"
 echo -e "  ${CYAN}[2]${NC} 📡  ${BOLD}Remove Client${NC} ${CYAN}[5]${NC} 📁  ${BOLD}Restart WireGuard${NC}"
 echo -e "  ${CYAN}[3]${NC} 🔄  ${BOLD}Live Status & Bandwidth${NC}       ${CYAN}[0]${NC} 🚪  ${BOLD}Exit${NC}"; line
 read -rp $'  [38;5;226m⟫ SELECT COMMAND: [0m' choice
 case $choice in
  1) add_client; pause;; 2) delete_client; pause;; 3) status_clients; pause;; 4) list_clients; pause;; 5) systemctl restart wg-quick@wg0; ok 'WireGuard direstart.'; pause;; 0) echo -e "\n${MAGENTA}  Bye, cyber operator. Stay secure. ⚡${NC}"; exit 0;; *) echo -e "${RED}  ✖ Command tidak dikenal.${NC}"; sleep 1;;
 esac
done
