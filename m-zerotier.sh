#!/usr/bin/env bash
# systemd-menu.sh
# Menu helper untuk menampilkan / mengelola systemd services
# Penulis: Generated for user
# Cara pakai: simpan, chmod +x, jalankan
clear
# ------------ utilitas -------------
# ===== WARNA =====

c='\e[36m'
y='\033[1;33m' #yellow
drakgry="\033[90m"
liggry="\033[37m"
pth="\033[97m"
BGX="\033[42m"
z="\033[96m"
NC='\033[0m'
gray="\e[1;30m"
blue='\e[34m'
green='\033[0;32m'
grenbo="\e[92;1m"
purple="\033[1;95m"
YELL='\033[0;33m'

# Colors & emoji
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAG='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD="\e[1m"
RESET="\e[0m"
EMO_SUCCESS="✅"
EMO_FAIL="❌"
EMO_WARN="⚠️"
PUTIH="\033[37m"
# Fungsi util
echo_warn()  { echo -e "${YELLOW}${BOLD}⚠️  $*${RESET}"; }
echo_ok()    { echo -e "${GREEN}${BOLD}✅ $*${RESET}"; }
echo_err()   { echo -e "${RED}${BOLD}❌ $*${RESET}"; }
echo_info()  { echo -e "${BLUE}${BOLD}ℹ️  $*${RESET}"; }

# Mapping display name -> systemd unit name
declare -A SERVICES=(
  ["zerotier-one"]="zerotier-one"
#  ["Zerotier"]="Zerotier"
#  ["AdGuardHome"]="AdGuardHome"
)

DIR="/opt/networkid"

print_header(){
  clear
  printf "%b" "$BOLD";
  echo "=========================================="
  echo "  Services Status Checker"
  echo "=========================================="
  printf "%b" "$RESET";
}
loading(){
sec=3
echo ""
spinner=(⣻ ⢿ ⡿ ⣟ ⣯ ⣷)
while [ $sec -gt 0 ]; do
  echo -ne "\e[33m ${spinner[sec]} Menuju Ke Menu ZeroTier dalam $sec seconds...\r"
  sleep 1
  sec=$(($sec - 1))
done
}

pause(){
  read -n 1 -s -r -p "  Press any key to continue"
  source zerotier
}  
#-------------- status --------------
zerotier_status=$(systemctl status zerotier-one | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
# STATUS SERVICE  zerotier 
if [[ $zerotier_status == "running" ]]; then 
   status_zerotier="${green}Online${NC}"
else
   status_zerotier="${RED}Offline${NC} "
fi
if systemctl is-active --quiet zerotier-one 2>/dev/null && \
       zerotier-cli status 2>/dev/null | grep -q "200"; then
        info="DISABLE ZEROTIER"
        ON="Enable"
    else
        info="ENABLE ZEROTIER "
        ON="Disable"
fi


# -------------- info vps --------------
MYIP=$(curl -sS ipv4.icanhazip.com)
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
RAM=$(free -m | awk 'NR==2 {print $2}')
uptime="$(uptime -p | cut -d " " -f 2-10)"
# -------------- aksi menu --------------
install_zerotier() {
# Tidak exit otomatis jika ada error; kita tangani sendiri
	echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
	echo -e "${green} ┌────────• CHECKING •─────────┐ ${NC}"
  echo -e "${green} │ 🛠️  CEK ZEROTIER${NC}"
  echo -e "${green} └─────────────────────────────┘ ${NC}"
	echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
  sleep 1

  # Cek beberapa indikasi instalasi
  if command -v zerotier-cli >/dev/null 2>&1; then
    echo -e "${EMO_FAIL}${green}ZeroTier sudah terinstall (zerotier-cli ditemukan).${NC}"
    pause
  fi

  if systemctl list-unit-files --type=service | grep -q '^zerotier-one'; then
    if systemctl is-active --quiet zerotier-one; then
      echo -e "${EMO_SUCCESS}}${green}ZeroTier service (zerotier-one) aktif.${NC}"
      pause
    else
      echo -e "${EMO_WARN}${y}ZeroTier service terpasang tetapi tidak aktif. Mencoba mengaktifkan...${NC}"
      sudo systemctl enable --now zerotier-one || true
      if systemctl is-active --quiet zerotier-one; then
        echo -e "${EMO_SUCCESS}${green}ZeroTier berhasil diaktifkan${NC}."
        pause
      fi
    fi
  fi

  # Cek snap
  if command -v snap >/dev/null 2>&1 && snap list | awk '{print $1}' | grep -q '^zerotier$'; then
    echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
	  echo -e "${green} ┌────────• CHECKING •─────────┐ ${NC}"
    echo -e "${green} │ 🛠️  CEK ZEROTIER${NC}"
    echo -e "${green} └─────────────────────────────┘ ${NC}"
	  echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
    echo  ""
    echo -e "${green} Zerotier Sudah TerInstall Lewat Snap.${NC}"
    echo -e "${CYAN} service zerotier ${NC}$status_zerotier"
    pause
  fi

  echo -e "${EMO_FAIL}${RED}ZeroTier tidak ditemukan. Memulai proses instalasi...${NC}"

  # 1) Coba install lewat snap kalau snap tersedia
  if command -v snap >/dev/null 2>&1; then
    echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
	  echo -e "${green} ┌────────• MEMASANG •─────────┐ ${NC}"
    echo -e "${green} │ 🛠️  ZEROTIER${NC}"
    echo -e "${green} └─────────────────────────────┘ ${NC}"
	  echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
    echo  ""
    if sudo snap install zerotier; then
      echo -e "${green} Zerotier Berhasil Di Install Lewat Snap.${NC}"
      # beberapa konfigurasi service snap mungkin bernama snap.<snapname>.<service>
      sudo systemctl enable --now zerotier-one 2>/dev/null || \
        sudo systemctl enable --now snap.zerotier.zerotier.service 2>/dev/null || true

      echo -e "${CYAN}service zerotier ${NC}$status_zerotier"
      return 0
    else
      echo -e "${EMO_FAIL}${RED}Instalasi snap gagal — akan melanjutkan metode lain.${NC}"
    fi
  else
    echo -e "${EMO_WARN}${y}snap tidak ditemukan di sistem, lewati metode snap.${NC}"
  fi

  # 2) Coba apt (bisa gagal bila repo resmi belum terpasang)
  if command -v apt >/dev/null 2>&1; then
    echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
	  echo -e "${green} ┌────────• MEMASANG •─────────┐ ${NC}"
    echo -e "${green} │ 🛠️  ZEROTIER${NC}"
    echo -e "${green} └─────────────────────────────┘ ${NC}"
	  echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
    echo ""
    sudo apt update -y || echo "apt update gagal atau offline, lanjut..."
    if sudo apt install -y zerotier-one; then
      echo -e "${green} Zerotier Berhasil Di Install Lewat Apt.${NC}"
      sudo systemctl enable --now zerotier-one || true
      pause
    else
      echo -e "${EMO_FAIL}${RED}apt install gagal atau paket tidak tersedia di repo default Lanjut ke metode berikutnya.${NC}"
    fi
  fi

  # 3) Fallback: official installer (curl | bash)
  echo -e "${pth}-> Mencoba installer resmi ZeroTier (curl | sudo bash) sebagai fallback...${NC}"
  sleep 1
  echo ""
  echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
	echo -e "${green} ┌────────• MEMASANG •─────────┐ ${NC}"
  echo -e "${green} │ 🛠️  ZEROTIER${NC}"
  echo -e "${green} └─────────────────────────────┘ ${NC}"
  echo -e "${green} ◇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━◇ ${NC}"
  echo ""
  if command -v curl >/dev/null 2>&1; then
    apt install curl -y >/dev/null 2>&1 || true
    sleep 1
    if curl -fsSL https://install.zerotier.com | sudo bash; then
      echo -e "${pth}Installer resmi dijalankan. Mengecek/menjalankan service...${NC}"
      sudo systemctl enable --now zerotier-one 2>/dev/null || \
        sudo systemctl enable --now snap.zerotier.zerotier.service 2>/dev/null || true

      if command -v zerotier-cli >/dev/null 2>&1 || systemctl is-active --quiet zerotier-one; then
        echo -e "${EMO_SUCCESS}${green}ZeroTier berhasil terpasang lewat installer resmi.${NC}"
        pause
      else
        echo -e "${EMO_WARN{y}Installer resmi dijalankan tetapi service/command belum tersedia.${NC}"
      fi
    else
      echo -e "${EMO_FAIL}${RED}Installer resmi gagal dijalankan.${NC}"
    fi
  else
    echo -e "${EMO_WARN}${y}curl tidak tersedia — tidak bisa menjalankan installer resmi. Install curl atau gunakan apt/snap manual.${NC}"
  fi

  echo -e "${RED}=== GAGAL: ZeroTier tidak terinstall. ==="
  echo -e "${RED}Periksa log, koneksi internet, atau jalankan manual:${NC}"
  echo -e "${y}  - sudo snap install zerotier"
  echo -e "${y}  - sudo apt update && sudo apt install -y zerotier-one"
  echo -e "${y}  - curl -fsSL https://install.zerotier.com | sudo bash"
  echo -e "${y}  - curl -s https://install.zerotier.com | sudo bash${NC}"
  return 1
}

join_networkid() {
    if zerotier-cli status 2>/dev/null | grep -q "200"; then
        if [ -d "$DIR" ]; then
            echo_info "Directory '$DIR' sudah ada."
            FILE="$DIR/netid.txt"
            # Cek file ada atau tidak
            if [ ! -f "$FILE" ]; then
                echo "File $FILE tidak ditemukan!"
                exit 1
            fi
            clear  
            echo -e "${pth}  Silakan pilih mau join network via mana ?$NC"
            echo -e ""
            echo -e "     \e[1;32m1)\e[0m join networkid dari daftar file $FILE"
            echo -e "     \e[1;32m2)\e[0m join networkid manual"
            echo -e " "
            read -p "   Please select numbers 1-2 : " plh
            echo ""
            if [[ $plh == "1" ]]; then
                # ambil baris yang dipilih
                LINE_CONTENT=$(sed -n "${LINE}p" "$FILE")

                # ekstrak network id (ambil deretan 16 hex karakter)
                RESULT=$(echo "$LINE_CONTENT" | grep -oE '[0-9a-fA-F]{16}' | tr 'A-F' 'a-f' | head -n1)

                if [ -z "$RESULT" ]; then
                    echo "Tidak ada NetworkID valid di baris $LINE. Isi baris: $LINE_CONTENT"
                    exit 1
                fi

                # tampilkan untuk debug (tanda kutip membantu lihat spasi)
                printf 'Meng-join NetworkID: "%s"\n' "$RESULT"

                # jalankan join dan tangkap output serta exit code
                JOIN_OUT=$(zerotier-cli join "$RESULT" 2>&1)
                JOIN_EXIT=$?

                # tampilkan apa yang dikembalikan zerotier-cli
                echo "zerotier-cli output: $JOIN_OUT"

                if [ $JOIN_EXIT -eq 0 ] || echo "$JOIN_OUT" | grep -q '^200'; then
                    echo -e "✅ Berhasil join network $RESULT"
                else
                    echo -e "❌ Gagal join network $RESULT — pesan: $JOIN_OUT"
                fi
            elif [[ $plh == "2" ]]; then
                clear
                echo_info "ZeroTier aktif. Melanjutkan proses JOIN..."
                read -p "  MASUKAN NETWORKID : " networkid
                zerotier_join=$(zerotier-cli join $networkid)
                # STATUS SERVICE  zerotier 
                if [[ $zerotier_join == "200 join OK" ]]; then 
                  echo -e "${green} Berhasil Join NetworkID $networkid${EMO_SUCCESS} ${NC}"
                  echo_ok "Directory '$DIR' berhasil dibuat."
                  if grep -Fxq "$networkid" "$DIR/netid.txt" 2>/dev/null ; then
                      echo_warn "Baris '$networkid' sudah ada, skip..."
                  else
                      echo_info "$networkid" >> "$DIR/netid.txt"
                      echo_ok "Baris '$networkid' berhasil ditambahkan."
                  fi
                else
                    clear
                    echo -e "${RED} Gagal Join NetworkID $networkid ${EMO_FAIL} ${NC} "
                fi
            else
                echo -e "${RED}Error: harap pilih nomer [1]-[2] ${NC}"
            fi
        else
          echo_info "ZeroTier aktif. Melanjutkan proses JOIN..."
          read -p "  MASUKAN NETWORKID : " networkid
          zerotier_join=$(zerotier-cli join $networkid)
          # STATUS SERVICE  zerotier 
          if [[ $zerotier_join == "200 join OK" ]]; then 
            echo -e "${green} Berhasil Join NetworkID $networkid${EMO_SUCCESS} ${NC}"
            echo_info "Directory '$DIR' belum ada, membuat directory..."
            mkdir -p "$DIR"
            touch "$DIR/netid.txt"
            echo_ok "Directory '$DIR' berhasil dibuat."
            if grep -Fxq "$networkid" "$DIR/netid.txt" 2>/dev/null ; then
                echo_warn "Baris '$networkid' sudah ada, skip..."
            else
                echo_info "$networkid" >> "$DIR/netid.txt"
                echo_ok "Baris '$networkid' berhasil ditambahkan."
            fi
          else
              clear
              echo -e "${RED} Gagal Join NetworkID $networkid ${EMO_FAIL} ${NC} "
          fi
        fi
    else
        echo "ZeroTier tidak aktif → start & enable"
        systemctl start zerotier-one
        sleep 1
        zerotier-cli enable
        sleep 2
        if zerotier-cli status 2>/dev/null | grep -q "200"; then
            read -p "  MASUKAN NETWORKID : " networkid
            zerotier_join=$(zerotier-cli join $networkid)
            # STATUS SERVICE  zerotier 
            if [[ $zerotier_join == "200 join OK" ]]; then 
              echo -e "${green} Berhasil Join NetworkID $networkid${EMO_SUCCESS} ${NC}"
            else
              echo -e "${RED} Gagal Join NetworkID $networkid ${EMO_FAIL} ${NC} "
            fi
        fi
    fi
    pause
}

check_status(){
  print_header
  echo "Checking service status..."
  for name in "${!SERVICES[@]}"; do
    unit=${SERVICES[$name]}
    if systemctl list-unit-files | grep -qi "^${unit}.service" || systemctl status "$unit" &>/dev/null; then
      if systemctl is-active --quiet "$unit"; then
        printf "%b %b is %bRUNNING%b %s\n" "$EMO_SUCCESS" "$name" "$GREEN" "$RESET"
      else
        printf "%b %b is %bNOT RUNNING%b %s\n" "$EMO_FAIL" "$name" "$RED" "$RESET" 
      fi
    else
      printf "%b %b: %bUNIT NOT FOUND%b\n" "$EMO_WARN" "$name" "$YELLOW" "$RESET"
    fi
  done
  printf "%b" "$RESET"
  pause
}

toggle_zerotier() {

# Pastikan systemctl ada
if ! command -v systemctl >/dev/null 2>&1; then
  echo_err "systemctl tidak ditemukan. Skrip ini memerlukan systemd."
  exit 2
fi

# Prompt ke user
read -r -p "$(echo -e "${YELLOW}🔔 Apakah Anda ingin MEN-${info}? (y/yes/ya/iya) atau (t/n/no/tidak) ${RESET}") " answer

# Normalisasi jawaban: lowercase + trim
ans="$(echo -n "$answer" | tr '[:upper:]' '[:lower:]' | xargs)"

case "$ans" in
  y|yes|ya|iya)

    # Cek apakah already disabled
    if systemctl is-active --quiet zerotier-one 2>/dev/null && \
       zerotier-cli status 2>/dev/null | grep -q "200"; then
       echo_info "Zerotier saat ini ENABLED — mencoba menonaktifkan (disable)..."
      # Gunakan sudo kalau tidak root
       if [ "$(id -u)" -ne 0 ]; then
          echo_warn "Tidak menjalankan sebagai root — akan memakai sudo untuk systemctl."
          sudo zerotier-cli disable
          sudo systemctl stop zerotier-one
          rc=$?
       else
        zerotier-cli disable
        sleep 1
        systemctl stop zerotier-one
        rc=$?
       fi

       if [ $rc -eq 0 ]; then
        # Verifikasi
         if systemctl is-active --quiet zerotier-one 2>/dev/null && \
             zerotier-cli status 2>/dev/null | grep -q "200"; then
            echo_err "Gagal: Zerotier masih terlihat ENABLED setelah perintah disable."
            exit 4
         else
            clear
            echo_ok "Zerotier berhasil DI-DISABLE. 🎉 Zerotier tidak akan otomatis menyala saat boot."
            pause
         fi
       else
          echo_err "Perintah 'zerotier-cli disable' mengembalikan error (kode $rc)."
           exit $rc
       fi

    else
        rc=$?
        echo_warn "ZeroTier tidak aktif → start & enable"
        systemctl start zerotier-one
        sleep 1
        zerotier-cli enable
        sleep 1
        clear
        echo_ok "Zerotier berhasil DI-ENABLE. 🎉 Zerotier akan otomatis menyala saat boot."
        pause
    fi
    ;;
  n|no|tidak|t)
    echo_ok "Oke, Zerotier tetap ${ON}. 👍"
    pause
    ;;
  *)
    echo_err "Jawaban tidak dikenali: '$answer'. Mohon jawab dengan y/yes/ya/iya atau t/n/no/tidak."
    exit 1
    ;;
esac
}

zt_info() {
  echo -e "${MAG}🚀 Mengambil info jaringan ZeroTier...${RESET}\n"

  output=$(sudo zerotier-cli listnetworks 2>/dev/null)

  if [ -z "$output" ]; then
    echo -e "${RED}❌ Gagal mengambil data ZeroTier (cek sudo / service).${RESET}"
    return 1
  fi

  echo "$output" | tail -n +2 | while read -r line; do
    RESPONSE=$(echo "$line" | awk '{print $1}')
    NET_ID=$(echo "$line" | awk '{print $3}')
    STATUS=$(echo "$line" | awk '{print $6}')
    NAME=$(echo "$line" | awk '{print $4}')
    IPZT=$(echo "$line" | awk '{print $9}')
    IPS=$(echo "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{1,4}')

    echo -e "${CYAN}📶 Response   : ${GREEN}$RESPONSE${RESET}"
    echo -e "${CYAN}🔗 Network ID : ${YELLOW}$NET_ID${RESET}"
    echo -e "${CYAN}📛 Nama       : ${WHITE}$NAME${RESET}"
    echo -e "${CYAN}☁️  IpZt       : ${RED}$IPZT${RESET}"

    if [[ "$STATUS" == "OK" ]]; then
      echo -e "${CYAN}📡 Status     : ${GREEN}AKTIF ✅${RESET}"
    else
      echo -e "${CYAN}📡 Status     : ${RED}$STATUS ❌${RESET}"
    fi

    if [ -n "$IPS" ]; then
      echo -e "${CYAN}🌐 IP Aktif (ZeroTier):${RESET}"
      for ip in $IPS; do
        echo -e "   ${GREEN}• $ip${RESET}"
      done
    else
      echo -e "${YELLOW}⚠️  Tidak ada IP yang terdeteksi${RESET}"
    fi

    echo -e "${MAG}----------------------------------------${RESET}"
  done

  echo -e "${BLUE}ℹ️  Info:${RESET}"
  echo -e "   Alamat IP di atas adalah IP ${GREEN}aktif${RESET} yang diberikan oleh ${GREEN}ZeroTier${RESET}"
  echo -e "   dan digunakan untuk komunikasi antar device dalam network ZeroTier ✨"
  pause
}

leave_network() {
  #read -p "  MASUKAN NETWORKID YANG INGIN DI LEAVE : " networkid
    if ! command -v fzf >/dev/null 2>&1; then
        echo_err "fzf tidak ditemukan. Silakan install fzf terlebih dahulu untuk memilih NetworkID."
        #return 1
        PLATFORM=""
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                "debian"|"ubuntu"|"kali") PLATFORM="ubuntu" ;;
                "centos"|"fedora"|"rhel"|"redhat") PLATFORM="centos" ;;
                "arch"|"manjaro") PLATFORM="arch" ;;
                *) PLATFORM="unknown" ;;
            esac
        else
            echo_err "Tidak dapat menentukan platform OS. Silakan install fzf secara manual."
            return 1
        fi
        case "$PLATFORM" in "debian"|"ubuntu"|"kali")
            sudo apt update && sudo apt install -y fzf
            ;;
          "centos"|"fedora"|"redhat")
            sudo dnf install -y fzf
            ;;
          "arch"|"manjaro")
            sudo pacman -Syu fzf --noconfirm
            ;;
          *)
            echo_err "Platform tidak dikenali. Silakan install fzf secara manual."
            return 1
            ;;
        esac
    else
        echo_info "fzf ditemukan. Melanjutkan..."
    fi
    if systemctl is-active --quiet zerotier-one 2>/dev/null && \
       zerotier-cli status 2>/dev/null | grep -q "200"; then
        echo_info "ZeroTier aktif. Melanjutkan proses LEAVE..."
        echo_info "Menampilkan daftar NetworkID yang terhubung..."
        echo_info "Silakan pilih NetworkID yang ingin di LEAVE:"
        echo_info "(Gunakan panah atas/bawah untuk navigasi, Enter untuk memilih)"
        sleep 3
        loading
        networkid=$(zerotier-cli listnetworks | awk 'NR>1 {print $3}' | fzf --prompt=" Pilih NetworkID yang ingin di LEAVE: ")
        zerotier_leave=$(zerotier-cli leave $networkid)
        # STATUS SERVICE  zerotier 
        if [[ $zerotier_leave == "200 leave OK" ]]; then 
          echo -e "${green} Berhasil Leave NetworkID $networkid${EMO_SUCCESS} ${NC}"
        else
            echo -e "${RED} Gagal Leave NetworkID $networkid ${EMO_FAIL} ${NC} "
        fi
    else
        echo_warn "ZeroTier tidak aktif → mulai start & enable"
        systemctl start zerotier-one
        sleep 1
        zerotier-cli enable
        sleep 3
        echo_ok "ZeroTier aktif. Melanjutkan proses LEAVE..."
        networkid=$(zerotier-cli listnetworks | awk 'NR>1 {print $3}' | fzf --prompt=" Pilih NetworkID yang ingin di LEAVE: ")
        zerotier_leave=$(zerotier-cli leave $networkid)
        # STATUS SERVICE  zerotier 
        if [[ $zerotier_leave == "200 leave OK" ]]; then 
          echo -e "${green} Berhasil Leave NetworkID $networkid${EMO_SUCCESS} ${NC}"
        else
            clear
            echo -e "${RED} Gagal Leave NetworkID $networkid ${EMO_FAIL} ${NC} "
        fi
    fi
    pause
  
}

# -------------- menu --------------
echo -e " ${c}╭════════════════════════════════════════════╮$NC"
echo -e " ${c}│$NC$NC\033[41m             System Information             $NC${c}│$NC"
echo -e " ${c}╰════════════════════════════════════════════╯$NC"
echo -e " ${c}╭════════════════════════════════════════════╮$NC"
echo -e " ${c}│$NC$y Operating System$NC $blue=$NC $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')$NC"
echo -e " ${c}│$NC$y Uptime$NC           $blue=$NC ${uptime}$NC"
echo -e " ${c}│$NC$y IP Local$NC         $blue=$NC $(hostname -I | awk '{print $1}')$NC"
echo -e " ${c}│$NC$y IP Publik$NC        $blue=$NC $MYIP$NC"
#echo -e " ${c}│$NC$y IP ZEROTIER$NC      $blue=$NC $(zerotier-cli listnetworks | awk 'NR>1 {print $9}')$NC"
echo -e " ${c}│$NC$y Total Cpu$NC        $blue=$NC $cores CORE$NC"
echo -e " ${c}│$NC$y Sisa Ram$NC         $blue=$NC ${RAM}GB$NC"
echo -e " ${c}│$NC$y Service Zerotier$NC $blue=$NC $status_zerotier $NC"
echo -e " ${c}╰════════════════════════════════════════════╯$NC"
echo -e " ${c}╭════════════════════════════════════════════╮$NC"
echo -e " ${c}│$NC$NC\033[41m               Menu Zerotier                $NC${c}│$NC"
echo -e " ${c}╰════════════════════════════════════════════╯$NC"
echo -e " ${c}╭════════════════════════════════════════════╮$NC"
echo -e " ${c}│${drakgry}[${liggry}•1${drakgry}]${pth}INSTALL ZEROTIER                        ${c}│$NC"
echo -e " ${c}│${drakgry}[${liggry}•2${drakgry}]${pth}ZEROTIER JOIN NETWORKID                 ${c}│$NC"
echo -e " ${c}│${drakgry}[${liggry}•3${drakgry}]${pth}ZEROTIER STATUS                         ${c}│$NC"
echo -e " ${c}│${drakgry}[${liggry}•4${drakgry}]${pth}${info}                        ${c}│$NC"
echo -e " ${c}│${drakgry}[${liggry}•5${drakgry}]${pth}ZEROTIER LIST NETWORK                   ${c}│$NC"
echo -e " ${c}│${drakgry}[${liggry}•6${drakgry}]${pth}ZEROTIER LEAVE NETWORKID                ${c}│$NC"
#echo -e " ${c}│${drakgry}[${liggry}•7${drakgry}]${pth}REMOVE USER                             ${c}│$NC"
#echo -e " ${c}│${drakgry}[${liggry}•8${drakgry}]${pth}RESET USER                              ${c}│$NC"
#echo -e " ${c}│${drakgry}[${liggry}•9${drakgry}]${pth}RESTART NOOBZVPN                        ${c}│$NC"
echo -e " ${c}│$NC                                            ${c}│$NC"
echo -e " ${c}│${drakgry}[${RED}•0${drakgry}]${RED}Kembali Ke Menu                         $NC${c}│$NC"
echo -e " ${c}╰════════════════════════════════════════════╯$NC"
read -p " Silakan Masukkan Angka [1 - 6]: " plh
echo -e ""

case $plh in
1 | 01) install_zerotier ;;
2 | 02) join_networkid ;;
3 | 03) check_status ;;
4 | 04) toggle_zerotier ;;
5 | 05) zt_info ;;
6 | 06) leave_network ;;
#7 | 07) noobz_revome_user ;;
#8 | 08) fn_noobzvpn_reset_user ;;
#9 | 09) clear ; bar_noobz "Restart NoobzVpn Usr Account." ; systemctl restart noobzvpns.service ; loadingrestart ; sleep 3 ; menu ;;
0)  clear ; loading ; menu ;;
x | X) clear ; exit 0 ;;
*) echo_warn "Pilihan tidak valid. Silakan masukkan angka dari 1 sampai 6." ; loading ; source zerotier ;;
esac