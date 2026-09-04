#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo '❌ Jalankan dengan sudo/root.'; exit 1; }
command -v apt-get >/dev/null || { echo '❌ Debian/Ubuntu berbasis apt diperlukan.'; exit 1; }
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok(){ echo -e "${GREEN}✅ $*${NC}"; }; info(){ echo -e "${CYAN}ℹ️  $*${NC}"; }
WG_DIR=/etc/wireguard; CONF=$WG_DIR/wg0.conf; CLIENT_DIR=$WG_DIR/clients
PORT=${SERVER_PORT:-51820}; NET=${WG_NET:-10.66.66};
IFACE=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')
PUBLIC_IP=$(curl -4fsS --max-time 5 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')
[[ -n $IFACE ]] || { echo '❌ Interface VPS tidak terdeteksi.'; exit 1; }
ok "Interface: $IFACE | Public IP: $PUBLIC_IP"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y wireguard qrencode iproute2 iptables curl ufw
cat >/etc/sysctl.d/99-wireguard-forward.conf <<'EOF'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF
sysctl --system >/dev/null
umask 077; mkdir -p "$WG_DIR" "$CLIENT_DIR"
[[ -f $WG_DIR/server_private.key ]] || wg genkey | tee "$WG_DIR/server_private.key" | wg pubkey > "$WG_DIR/server_public.key"
SERVER_PRIVATE=$(cat "$WG_DIR/server_private.key"); SERVER_PUBLIC=$(cat "$WG_DIR/server_public.key")
if [[ ! -f $CONF ]]; then
cat >"$CONF" <<EOF
[Interface]
Address = $NET.1/24
ListenPort = $PORT
PrivateKey = $SERVER_PRIVATE
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $IFACE -j MASQUERADE
EOF
fi
make_client(){
 local name=$1 ip=$2 private public
 private=$(wg genkey); public=$(printf '%s' "$private" | wg pubkey)
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
PublicKey = $SERVER_PUBLIC
Endpoint = $PUBLIC_IP:$PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
 qrencode -t ansiutf8 <"$CLIENT_DIR/$name.conf" >"$CLIENT_DIR/$name.qr.txt"
}
make_client HP "$NET.2"; make_client Laptop "$NET.3"; make_client PC "$NET.4"
install -m 755 "$(dirname "$0")/WireGuard_manager.sh" /usr/local/sbin/WireGuard_manager.sh
systemctl enable --now wg-quick@wg0
ufw allow "$PORT/udp" >/dev/null; ufw allow OpenSSH >/dev/null 2>&1 || true; ufw --force enable >/dev/null
ok 'WireGuard aktif melalui systemd dan UFW.'
wg show wg0
printf '\n📁 Client dan QR tersimpan di %s\n🛠️ Manager: /usr/local/sbin/WireGuard_manager.sh\n' "$CLIENT_DIR"
