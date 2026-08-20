#!/usr/bin/env bash
# =============================================================================
#  VPS Security Auditor - v1.1
#  Pengecekan akun SSH tersembunyi, backdoor, dan celah keamanan VPS
#  Usage: sudo bash check_ssh_login.sh
# =============================================================================

set -uo pipefail

# -- WARNA --
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# -- COUNTER & SECTION TRACKING --
ISSUES_FOUND=0
WARNINGS=0
OK_COUNT=0
SECTIONS_RUN=0
SECTIONS_TOTAL=16
CURRENT_SECTION=0

declare -a S_NAME
declare -a S_STATUS
declare -a S_REASON
declare -a S_SOLUTION

# -- FUNGSI DASAR --
banner() {
    echo -e "${CYAN}${BOLD}"
    echo "=============================================="
    echo "      VPS SECURITY AUDITOR v1.1"
    echo "      $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=============================================="
    echo -e "${NC}"
}

section() {
    SECTIONS_RUN=$((SECTIONS_RUN + 1))
    CURRENT_SECTION=$SECTIONS_RUN
    S_NAME[$CURRENT_SECTION]="$1"
    S_STATUS[$CURRENT_SECTION]=""
    S_REASON[$CURRENT_SECTION]=""
    S_SOLUTION[$CURRENT_SECTION]=""
    echo ""
    echo -e "${BLUE}${BOLD}--- $1 ---${NC}"
    echo ""
}

ok() {
    echo -e "  ${GREEN}[OK]${NC} $1"
    OK_COUNT=$((OK_COUNT + 1))
    [[ -z "${S_STATUS[$CURRENT_SECTION]:-}" ]] && S_STATUS[$CURRENT_SECTION]="ok"
}

warn() {
    echo -e "  ${YELLOW}[!]${NC} $1"
    WARNINGS=$((WARNINGS + 1))
    S_STATUS[$CURRENT_SECTION]="warn"
}

fail() {
    echo -e "  ${RED}[X]${NC} $1"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    S_STATUS[$CURRENT_SECTION]="fail"
}

info() { echo -e "  ${CYAN}[i]${NC} $1"; }
detail() { echo -e "       ${MAGENTA}->${NC} $1"; }
reason() { [[ -n "${1:-}" ]] && S_REASON[$CURRENT_SECTION]="${S_REASON[$CURRENT_SECTION]:-}$1\n"; }
solution() { [[ -n "${1:-}" ]] && S_SOLUTION[$CURRENT_SECTION]="${S_SOLUTION[$CURRENT_SECTION]:-}$1\n"; }

# -- 1. ROOT ACCESS CHECK --
check_root() {
    section "1. ROOT ACCESS CHECK"
    if [[ $EUID -eq 0 ]]; then
        ok "Script berjalan sebagai root"
        reason "Script dijalankan dengan sudo/root, semua file dapat dibaca."
    else
        warn "Tidak root -- beberapa pengecekan terbatas"
        reason "Tanpa root tidak bisa baca /etc/shadow."
        solution "Jalankan ulang: sudo bash $0"
    fi
}

# -- 2. DAFTAR SEMUA USER --
check_all_users() {
    section "2. DAFTAR SEMUA USER TERDAFTAR"

    echo -e "  ${BOLD}User UID 0 (root privilege):${NC}"
    local root_users
    root_users=$(awk -F: '($3 == 0) {print $1}' /etc/passwd)
    for u in $root_users; do
        if [[ "$u" != "root" ]]; then
            fail "User '$u' UID=0 -- backdoor!"
            reason "User '$u' punya akses root penuh. Backdoor klasik."
            solution "Hapus: sudo userdel -r $u"
        else
            ok "root (UID 0) -- normal"
        fi
    done

    echo ""
    echo -e "  ${BOLD}User dengan shell login:${NC}"
    local login_users
    login_users=$(awk -F: '($7 ~ /bash|sh|zsh|dash|fish|tcsh|csh/ && $7 !~ /nologin|false/) {print $1}' /etc/passwd)
    for u in $login_users; do
        local uid home shell
        uid=$(awk -F: -v user="$u" '$1==user {print $3}' /etc/passwd)
        home=$(awk -F: -v user="$u" '$1==user {print $6}' /etc/passwd)
        shell=$(awk -F: -v user="$u" '$1==user {print $7}' /etc/passwd)
        if [[ -d "$home" ]]; then
            info "$u | UID: $uid | Home: $home | Shell: $shell"
        else
            warn "$u | Home $home TIDAK ADA | Shell: $shell"
            reason "User '$u' punya login shell tapi home dir tidak ada."
            solution "Jika tidak dikenal: sudo userdel -r $u"
        fi
    done

    echo ""
    local sys_count
    sys_count=$(awk -F: '($7 ~ /nologin|false/) {print $1}' /etc/passwd | wc -l)
    ok "$sys_count user system (nologin/false) -- normal"

    local mtime
    mtime=$(stat -c %Y /etc/passwd 2>/dev/null || echo 0)
    local diff=$(( ($(date +%s) - mtime) / 86400 ))
    echo ""
    if [[ $diff -le 30 ]]; then
        info "/etc/passwd berubah ${diff}h lalu -- periksa"
        reason "File user berubah baru -- mungkin akun baru ditambah."
        solution "Cek: awk -F: '\$3>=1000{print \$1}' /etc/passwd"
    else
        ok "Modifikasi /etc/passwd ${diff}h lalu -- normal"
    fi
}

# -- 3. CEK /etc/shadow --
check_shadow() {
    section "3. CEK /etc/shadow (PASSWORD HASH)"
    if [[ ! -r /etc/shadow ]]; then
        warn "Tidak bisa baca /etc/shadow"
        reason "Akses root diperlukan."
        solution "Jalankan: sudo bash $0"
        return
    fi

    echo -e "  ${BOLD}User tanpa password:${NC}"
    local no_pass=0
    while IFS=: read -r user pass _; do
        if [[ -z "$pass" ]]; then
            fail "'$user' -- TANPA PASSWORD!"
            no_pass=1
            reason "User '$user' bisa login tanpa password -- KRITIS!"
            solution "Set password: sudo passwd $user"
        elif [[ "$pass" == "flatpak run org.ppsspp.PPSSPP" ]]; then
            info "$user -- belum pernah set password"
        fi
    done < /etc/shadow
    [[ $no_pass -eq 0 ]] && ok "Semua user punya password"

    echo ""
    echo -e "  ${BOLD}Algoritma hash:${NC}"
    local weak=0
    while IFS=: read -r user pass _; do
        [[ -z "$pass" || "$pass" == "!"* ]] && continue
        local a="${pass:0:3}"
        case "$a" in
            '$1$') warn "$user -- MD5 (LEMAH)"; weak=1
                   reason "MD5 mudah di-crack GPU. Password asli bisa didapat."
                   solution "Reset password: sudo passwd $user (pakai SHA-512)" ;;
            '$6$') ok "$user -- SHA-512 (aman)" ;;
            '$y$') info "$user -- yescrypt" ;;
            *)     info "$user -- $a" ;;
        esac
    done < /etc/shadow
    [[ $weak -eq 0 ]] && ok "Semua hash modern"
}

# -- 4. AUTHORIZED KEYS --
check_authorized_keys() {
    section "4. CEK AUTHORIZED_KEYS (SSH KEY TERSEMBUNYI)"
    local found=0
    while IFS=: read -r user uid gid gecos home shell; do
        [[ ! -d "$home" ]] && continue
        local af="$home/.ssh/authorized_keys"
        local af2="$home/.ssh/authorized_keys2"

        for f in "$af" "$af2"; do
            [[ ! -f "$f" ]] && continue
            found=1
            local kc
            kc=$(grep -c '^ssh-' "$f" 2>/dev/null || echo 0)
            echo ""
            if [[ $kc -gt 0 ]]; then
                info "$user -- $kc key(s) di $(basename "$f")"
                local ln=0
                while IFS= read -r line; do
                    [[ -z "$line" || "$line" == \#* ]] && continue
                    ln=$((ln+1))
                    local kt kb kc2
                    kt=$(echo "$line" | awk '{print $1}')
                    kb=$(echo "$line" | awk '{print $2}')
                    kc2=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf $i" "}')
                    detail "Key#$ln: $kt | ${kc2:-(tanpa comment)}"
                    if [[ ${#kb} -lt 100 ]]; then
                        fail "Key#$ln TERLALU PENDEK (${#kb} chars)"
                        reason "Key SSH user '$user' terlalu pendek."
                        solution "Periksa: cat $f. Jika mencurigakan hapus file."
                    fi
                done < "$f"
                local perm
                perm=$(stat -c %a "$f" 2>/dev/null)
                if [[ "$perm" != "600" && "$perm" != "400" ]]; then
                    warn "Permission $f: $perm (hrs 600)"
                    reason "Permission longgar -- user lain bisa modifikasi key."
                    solution "Perbaiki: chmod 600 $f"
                fi
            fi
        done
        local sd="$home/.ssh"
        [[ -d "$sd" ]] && { local dp; dp=$(stat -c %a "$sd" 2>/dev/null); [[ "$dp" != "700" && "$dp" != "755" ]] && warn "Perm .ssh: $dp (hrs 700)" && reason "Direktori .ssh user '$user' permission '$dp'." && solution "chmod 700 $sd"; }
    done < /etc/passwd
    [[ $found -eq 0 ]] && ok "Tidak ada authorized_keys"
}

# -- 5. KONFIGURASI SSH --
check_ssh_config() {
    section "5. CEK KONFIGURASI SSH"
    local f="/etc/ssh/sshd_config"
    [[ ! -f "$f" ]] && { fail "File $f tidak ada" && reason "SSH config hilang." && solution "Reinstall: sudo apt install --reinstall openssh-server" && return; }

    local rl pa pubkey
    rl=$(grep -i '^PermitRootLogin' "$f" 2>/dev/null | tail -1 | awk '{print $2}' || echo "not set")
    pa=$(grep -i '^PasswordAuthentication' "$f" 2>/dev/null | tail -1 | awk '{print $2}' || echo "not set")
    pubkey=$(grep -i '^PubkeyAuthentication' "$f" 2>/dev/null | tail -1 | awk '{print $2}' || echo "not set")

    case "$rl" in
        no|prohibit-password|without-password) ok "PermitRootLogin: $rl" ;;
        yes) fail "PermitRootLogin: YES -- root bisa SSH langsung!"
             reason "Root bisa login SSH dengan password -- resiko bocor tinggi."
             solution "Edit /etc/ssh/sshd_config: PermitRootLogin no. Restart: sudo systemctl restart sshd" ;;
        *)   info "PermitRootLogin: $rl" ;;
    esac

    case "$pa" in
        no)  ok "PasswordAuthentication: no (key-only)" ;;
        yes) warn "PasswordAuthentication: yes -- rawan brute force"
             reason "Penyerang bisa coba jutaan password (brute force)."
             solution "Jika sudah pakai SSH key, matikan: PasswordAuthentication no di sshd_config." ;;
        *)   info "PasswordAuthentication: $pa" ;;
    esac

    case "$pubkey" in
        yes) ok "PubkeyAuthentication: yes" ;;
        no)  warn "PubkeyAuthentication: no -- SSH key tidak aktif" ;;
    esac

    local au
    au=$(grep -i '^AllowUsers' "$f" 2>/dev/null || echo "")
    if [[ -n "$au" ]]; then
        ok "AllowUsers: $au"
    else
        warn "AllowUsers tidak diset -- semua user bisa SSH"
        reason "Tanpa AllowUsers, user tidak dikenal pun bisa login."
        solution "Tambahkan di sshd_config: AllowUsers root user1 user2"
    fi

    local ec
    ec=$(find /etc/ssh/ -name "*.conf" -type f 2>/dev/null | grep -v "sshd_config$" || true)
    if [[ -n "$ec" ]]; then
        echo "$ec" | while read -r x; do
            warn "Config tambahan: $x"
            detail "Isi: $(head -3 "$x" 2>/dev/null)"
        done
        reason "File konfigurasi tambahan bisa tempat sembunyi backdoor."
        solution "Periksa setiap file di /etc/ssh/*.conf. Hapus yg tak perlu."
    else
        ok "Tidak ada config tambahan"
    fi
}

# -- 6. PORT SSH --
check_ssh_ports() {
    section "6. CEK PORT SSH"
    echo -e "  ${BOLD}SSH listening:${NC}"
    if command -v ss &>/dev/null; then
        local sp
        sp=$(ss -tlnp 2>/dev/null | grep -i sshd || true)
        if [[ -n "$sp" ]]; then
            echo "$sp" | while read -r line; do info "$line"; done
            local ns
            ns=$(echo "$sp" | awk '{print $4}' | grep -oP ':\K\d+' | grep -v '^22$' || true)
            [[ -n "$ns" ]] && for p in $ns; do
                warn "SSH port non-standar: $p"
                reason "SSH di port $p -- bisa sengaja atau backdoor."
                solution "Cek: ps aux | grep sshd | grep -v grep"
            done
            ok "SSHD berjalan"
        else
            fail "SSHD tidak berjalan!"
            reason "SSH server mati -- Anda tidak bisa login."
            solution "Start: sudo systemctl start sshd && sudo systemctl enable sshd"
        fi
    fi

    echo ""
    echo -e "  ${BOLD}Firewall:${NC}"
    local fw=0
    command -v ufw &>/dev/null && { ufw status 2>/dev/null | grep -qi ssh && fw=1; }
    command -v iptables &>/dev/null && { iptables -L -n 2>/dev/null | grep -qiE 'ssh|dpt:22' && fw=1; }
    [[ $fw -eq 0 ]] && warn "Tidak ada firewall SSH" && reason "Semua IP bisa coba SSH." && solution "Install fail2ban: sudo apt install -y fail2ban" || ok "Firewall aktif"
}

# -- 7. LOG SSH --
check_ssh_logs() {
    section "7. CEK LOG SSH LOGIN"
    local logs=("/var/log/auth.log" "/var/log/secure" "/var/log/messages")
    local f=0
    echo -e "  ${BOLD}Login sukses:${NC}"
    for l in "${logs[@]}"; do
        [[ -f "$l" && -r "$l" ]] || continue
        f=1
        local s
        s=$(grep -i 'Accepted' "$l" 2>/dev/null | tail -10 || true)
        if [[ -n "$s" ]]; then
            echo "$s" | while read -r line; do info "$line"; done
            reason "Ada login sukses. Periksa apakah semua dikenal."
            solution "Cek IP: last -20 | grep -v '127.0.0.1|192.168.'"
        else
            info "Tidak ada login di $l"
        fi
    done
    [[ $f -eq 0 ]] && warn "Tidak ada file log auth"

    echo ""
    echo -e "  ${BOLD}Login gagal (brute force):${NC}"
    local bf=0
    for l in "${logs[@]}"; do
        [[ -f "$l" && -r "$l" ]] || continue
        local fl
        fl=$(grep -i 'Failed password' "$l" 2>/dev/null | tail -5 || true)
        [[ -n "$fl" ]] && bf=1 && echo "$fl" | while read -r line; do warn "$line"; done
    done
    [[ $bf -eq 1 ]] && reason "Ada percobaan login gagal -- brute force?" && solution "Install fail2ban: sudo apt install -y fail2ban" || ok "Tidak ada brute force"

    echo ""
    echo -e "  ${BOLD}Riwayat login (last):${NC}"
    command -v last &>/dev/null && { last -20 2>/dev/null | while read -r line; do [[ -z "$line" ]] && continue; info "$line"; done; } || warn "last tidak tersedia"

    echo ""
    echo -e "  ${BOLD}Sedang login:${NC}"
    command -v w &>/dev/null && { local wl; wl=$(w -h 2>/dev/null || true); [[ -n "$wl" ]] && echo "$wl" | while read -r line; do info "$line"; done; }
    command -v who &>/dev/null && { who 2>/dev/null | grep -v '^$' | while read -r line; do info "$line"; done; }
}

# -- 8. CRON JOB --
check_cron_jobs() {
    section "8. CEK CRON JOB TERSEMBUNYI"
    echo -e "  ${BOLD}Crontab user:${NC}"
    local fc=0 sc=0
    while IFS=: read -r user uid gid gecos home shell; do
        [[ ! -d "$home" ]] && continue
        local ct
        ct=$(crontab -u "$user" -l 2>/dev/null || true)
        [[ -z "$ct" ]] && continue
        fc=1
        echo ""
        info "User: ${BOLD}$user${NC}"
        echo "$ct" | while read -r line; do
            [[ -z "$line" || "$line" == \#* ]] && continue
            detail "$line"
            echo "$line" | grep -qiE 'curl|wget|nc |bash |sh |python|perl|/tmp|/dev/tcp|reverse|backdoor|shell' && sc=1
        done
    done < /etc/passwd
    [[ $fc -eq 0 ]] && ok "Tidak ada crontab user"
    [[ $sc -eq 1 ]] && fail "Cron mencurigakan (curl/wget/backdoor)!" && reason "Cron yg download/eksekusi dari luar = backdoor persistence." && solution "Hapus baris: crontab -u <user> -e"

    echo ""
    echo -e "  ${BOLD}System cron:${NC}"
    for cd in /etc/crontab /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
        if [[ -f "$cd" ]]; then
            local co
            co=$(grep -v '^#' "$cd" 2>/dev/null | grep -v '^$' || true)
            [[ -n "$co" ]] && echo "" && info "$cd:" && echo "$co" | while read -r line; do detail "$line"; done
        elif [[ -d "$cd" ]]; then
            local fl
            fl=$(ls "$cd" 2>/dev/null | grep -v 'README|\.' || true)
            [[ -n "$fl" ]] && echo "" && info "$cd:" && echo "$fl" | while read -r f; do detail "$f -- $(head -1 "$cd/$f" 2>/dev/null)"; done
        fi
    done
}

# -- 9. PROCESS MENCURIGAKAN --
check_suspicious_processes() {
    section "9. CEK PROCESS MENCURIGAKAN"
    echo -e "  ${BOLD}Listening port non-standar:${NC}"
    local ns=0
    command -v ss &>/dev/null && {
        ss -tlnp 2>/dev/null | grep -v '127.0.0.1|::1' | while read -r line; do
            local port
            port=$(echo "$line" | grep -oP ':\K\d+' | head -1 || true)
            if [[ "$port" =~ ^(22|80|443|3306|5432|6379|8080|8443|9090|3000)$ ]]; then
                info "$line"
            else
                ns=1; warn "$line"
            fi
        done
    }
    [[ $ns -eq 1 ]] && reason "Port non-standar bisa jadi backdoor." && solution "Cek PID: sudo ss -tlnp | grep -E ':22|:80|:443' -v"

    echo ""
    echo -e "  ${BOLD}Nama process mencurigakan:${NC}"
    local bad_names=("backdoor" "reverse" "nc" "ncat" "netcat" "socat" "meterpreter" "beacon" "cobalt" "sliver" "trojan" "rat" "xmrig" "minerd")
    local fb=0
    for n in "${bad_names[@]}"; do
        local p
        p=$(ps aux 2>/dev/null | grep -i "$n" | grep -v grep | grep -v "$0" || true)
        [[ -n "$p" ]] && fb=1 && echo "$p" | while read -r line; do fail "Process: $line"; done
    done
    [[ $fb -eq 1 ]] && reason "Process backdoor/C2 terdeteksi!" && solution "sudo kill -9 <PID> && sudo rm -f <path>" || ok "Tidak ada process mencurigakan"
}

# -- 10. HIDDEN FILES --
check_hidden_files() {
    section "10. CEK FILE TERSEMBUNYI"
    echo -e "  ${BOLD}File di /root:${NC}"
    if [[ -d /root ]]; then
        find /root -maxdepth 2 -name ".*" -type f 2>/dev/null | while read -r f; do
            local fn
            fn=$(basename "$f")
            case "$fn" in
                .bashrc|.profile|.bash_logout|.bash_history|.viminfo|.lesshst|.selected_editor|.ssh|.gitconfig|.wget-hsts|.my.cnf|.mysql_history|.Xauthority|.xsession-errors|.sudo_as_admin_successful|.motd_shown|.cache|.config) ;;
                *) warn "$f"; reason "File hidden tak dikenal di /root."; solution "Periksa: cat '$f'. Hapus: rm -f '$f'" ;;
            esac
        done
    fi

    echo ""
    echo -e "  ${BOLD}SUID/SGID mencurigakan:${NC}"
    local suid
    suid=$(find / -perm -4000 -o -perm -2000 2>/dev/null | grep -vE '/(usr/|bin/|sbin/|lib/|snap/)' || true)
    if [[ -n "$suid" ]]; then
        echo "$suid" | while read -r f; do
            warn "$f"
            reason "File '$f' punya SUID/SGID -- bisa eksekusi sebagai root."
            solution "Hapus SUID: sudo chmod u-s '$f'. Hapus file: sudo rm -f '$f'"
        done
    else
        ok "Tidak ada SUID/SGID mencurigakan"
    fi
}

# -- 11. SYSTEMD SERVICE --
check_services() {
    section "11. CEK SYSTEMD SERVICE"
    command -v systemctl &>/dev/null || { warn "systemctl tidak ada"; return; }

    echo -e "  ${BOLD}Service mencurigakan:${NC}"
    local bad_services=("backdoor" "reverse" "nc" "netcat" "socat" "xmrig" "trojan" "beacon" "cobalt" "sliver")
    local fb=0
    for s in "${bad_services[@]}"; do
        local sv
        sv=$(systemctl list-units --all --type=service 2>/dev/null | grep -i "$s" || true)
        [[ -n "$sv" ]] && fb=1 && echo "$sv" | while read -r line; do fail "Service: $line"; done
    done
    [[ $fb -eq 1 ]] && reason "Service backdoor/systemd persistence." && solution "sudo systemctl stop <svc> && sudo systemctl disable <svc>" || ok "Service bersih"

    echo ""
    echo -e "  ${BOLD}Service enabled non-standar:${NC}"
    local en
    en=$(systemctl list-unit-files --state=enabled 2>/dev/null | grep -vE '(ssh|nginx|apache|mysql|postgres|docker|ufw|fail2ban|cron|rsyslog|dbus|getty|network|systemd|snapd|containerd|polkit|accounts|udisks|unattended|cloud)' || true)
    [[ -n "$en" ]] && echo "$en" | while read -r line; do [[ -z "$line" ]] && continue; info "$line"; done
}

# -- 12. INTEGRITAS BINARY --
check_binaries() {
    section "12. CEK INTEGRITAS BINARY"
    local bins=("/usr/bin/sshd" "/usr/sbin/sshd" "/usr/bin/ssh" "/usr/bin/passwd" "/usr/bin/su" "/usr/bin/sudo" "/bin/bash" "/bin/sh" "/usr/bin/wget" "/usr/bin/curl")
    for b in "${bins[@]}"; do
        [[ ! -f "$b" ]] && continue
        local md5 sz mt
        md5=$(md5sum "$b" 2>/dev/null | awk '{print $1}')
        sz=$(stat -c %s "$b" 2>/dev/null)
        mt=$(stat -c %y "$b" 2>/dev/null)
        info "$b"
        detail "Size: ${sz}B | $mt"
        detail "MD5: $md5"
        local ft
        ft=$(file "$b" 2>/dev/null)
        if echo "$ft" | grep -q "statically linked"; then
            warn "STATIC binary -- bisa backdoor!"
            reason "Binary normal dynamic link. Static mencurigakan."
            solution "Verifikasi: dpkg --verify \$(dpkg -S $b 2>/dev/null|cut -d: -f1). Reinstall: sudo apt install --reinstall <pkg>"
        fi
    done
}

# -- 13. FILE SYSTEM KRITIS --
check_system_files() {
    section "13. CEK FILE SYSTEM KRITIS"
    echo -e "  ${BOLD}PAM (/etc/pam.d/sshd):${NC}"
    [[ -f /etc/pam.d/sshd ]] && {
        local pam
        pam=$(grep -v '^#' /etc/pam.d/sshd 2>/dev/null | grep -v '^$' || true)
        [[ -n "$pam" ]] && echo "$pam" | while read -r line; do
            detail "$line"
            echo "$line" | grep -qiE 'pam_permit|nullok' && warn "Modul PAM: $line" && reason "Modul PAM bisa nonaktifkan auth." && solution "Hapus baris dari /etc/pam.d/sshd"
        done
    }

    echo ""
    echo -e "  ${BOLD}/etc/hosts (DNS poisoning):${NC}"
    [[ -f /etc/hosts ]] && {
        local he
        he=$(grep -vE '^#|^$|127\.0\.0\.|::1|localhost|ip6-|fe00::0|ff00::0|ff02::' /etc/hosts 2>/dev/null || true)
        [[ -n "$he" ]] && echo "$he" | while read -r line; do warn "Entry: $line"; done && reason "Entry /etc/hosts tambahan -- bisa DNS poisoning." && solution "Hapus: sudo sed -i '/<ip>\s\+<domain>/d' /etc/hosts" || ok "/etc/hosts bersih"
    }

    echo ""
    echo -e "  ${BOLD}DNS (/etc/resolv.conf):${NC}"
    [[ -f /etc/resolv.conf ]] && {
        grep 'nameserver' /etc/resolv.conf 2>/dev/null | while read -r line; do
            local ip
            ip=$(echo "$line" | awk '{print $2}')
            case "$ip" in
                127.0.0.53|8.8.8.8|8.8.4.4|1.1.1.1|1.0.0.0|208.67.222.222|208.67.220.220) info "$line" ;;
                *) warn "DNS non-standar: $line"; reason "DNS '$ip' tidak dikenal -- bisa hijacking."; solution "Ganti ke 8.8.8.8 atau 1.1.1.1 di /etc/resolv.conf" ;;
            esac
        done
    }
}

# -- 14. KERNEL MODULE --
check_kernel_modules() {
    section "14. CEK KERNEL MODULE"
    command -v lsmod &>/dev/null || return
    local bad_mods=("rootkit" "knark" "adore" "suterusu" "diamorphine" "reptile" "enyelkm" "phalanx" "suckit" "rkit")
    local fb=0
    for m in "${bad_mods[@]}"; do
        lsmod 2>/dev/null | grep -qi "$m" && fb=1 && fail "Rootkit: $m"
    done
    [[ $fb -eq 1 ]] && reason "ROOTKIT KERNEL! Malware tingkat kernel." && solution "Backup data, INSTALL ULANG VPS." || ok "Tidak ada rootkit kernel"
}

# -- 15. USER NON-ROOT BISA LOGIN SSH --
check_ssh_login_users() {
    section "15. CEK USER NON-ROOT BISA LOGIN SSH"
    local users
    users=$(awk -F: '$1 != "root" && $7 !~ /(nologin|false)$/ {print $1, "->", $7}' /etc/passwd 2>/dev/null)
    if [[ -n "$users" ]]; then
        local tot
        tot=$(echo "$users" | wc -l)
        echo ""
        echo "$users" | while read -r line; do
            local un
            un=$(echo "$line" | awk '{print $1}')
            id "$un" &>/dev/null && [[ -d "$(getent passwd "$un" | cut -d: -f6)" ]] && warn "$line" || fail "$line -- AKUN MENCURIGAKAN!"
        done
        echo ""
        warn "$tot user non-root dengan shell login"
        reason "$tot user non-root bisa SSH. Setiap user adalah potensi entry point."
        solution "Jika tidak dikenal: sudo userdel -r <user>. Jika dikenal: sudo usermod -s /usr/sbin/nologin <user>"
    else
        ok "Tidak ada user non-root dengan shell login"
    fi
}

# -- 16. RINGKASAN --
summary() {
    section "16. RINGKASAN AUDIT"

    local fail_list="" warn_list="" ok_list=""
    for ((i=1; i<=SECTIONS_RUN; i++)); do
        local st="${S_STATUS[$i]:-ok}"
        local sn="${S_NAME[$i]:-$i}"
        case "$st" in
            fail) fail_list="$fail_list  [X] $sn\n" ;;
            warn) warn_list="$warn_list  [!] $sn\n" ;;
            ok)   ok_list="$ok_list  [OK] $sn\n" ;;
        esac
    done

    echo -e "  ${BOLD}STATISTIK${NC}"
    echo "  Section: $SECTIONS_RUN / $SECTIONS_TOTAL"
    echo -e "  [OK] Aman: $OK_COUNT  [!] Peringatan: $WARNINGS  [X] Kritis: $ISSUES_FOUND"
    echo ""

    # KRITIS
    if [[ -n "$fail_list" ]]; then
        echo -e "  ${RED}${BOLD}=== KRITIS (WAJIB SEGERA DITANGANI) ===${NC}"
        echo ""
        echo -e "$fail_list"
        for ((i=1; i<=SECTIONS_RUN; i++)); do
            [[ "${S_STATUS[$i]:-ok}" != "fail" ]] && continue
            echo ""
            echo -e "  ${RED}--- ${S_NAME[$i]} ---${NC}"
            local rt="${S_REASON[$i]:-}" stext="${S_SOLUTION[$i]:-}"
            if [[ -n "$rt" ]]; then
                echo -e "  ALASAN KRITIS:"
                echo -e "$rt" | while IFS= read -r r; do [[ -z "$r" ]] && continue; echo "    * $r"; done
            fi
            if [[ -n "$stext" ]]; then
                echo -e "  SOLUSI:"
                echo -e "$stext" | while IFS= read -r s; do [[ -z "$s" ]] && continue; echo "    -> $s"; done
            fi
        done
    fi

    # PERINGATAN
    if [[ -n "$warn_list" ]]; then
        echo ""
        echo -e "  ${YELLOW}${BOLD}=== PERINGATAN (SEBAIKNYA DIPERIKSA) ===${NC}"
        echo ""
        echo -e "$warn_list"
        for ((i=1; i<=SECTIONS_RUN; i++)); do
            [[ "${S_STATUS[$i]:-ok}" != "warn" ]] && continue
            echo ""
            echo -e "  ${YELLOW}--- ${S_NAME[$i]} ---${NC}"
            local rt="${S_REASON[$i]:-}" stext="${S_SOLUTION[$i]:-}"
            if [[ -n "$rt" ]]; then
                echo -e "  ALASAN:"
                echo -e "$rt" | while IFS= read -r r; do [[ -z "$r" ]] && continue; echo "    * $r"; done
            fi
            if [[ -n "$stext" ]]; then
                echo -e "  SOLUSI:"
                echo -e "$stext" | while IFS= read -r s; do [[ -z "$s" ]] && continue; echo "    -> $s"; done
            fi
        done
    fi

    # AMAN
    if [[ -n "$ok_list" ]]; then
        echo ""
        echo -e "  ${GREEN}${BOLD}=== AMAN (OK) ===${NC}"
        echo ""
        echo -e "$ok_list"
    fi

    echo ""
    echo -e "  ${BOLD}KESIMPULAN:${NC}"
    if [[ $ISSUES_FOUND -gt 0 ]]; then
        echo -e "  ${RED}${BOLD}$ISSUES_FOUND MASALAH KRITIS! SEGERA TANGANIorg.ppsspp.PPSSPP${NC}"
        echo ""
        echo "  REKOMENDASI:"
        echo "  1. Hapus user tidak dikenal"
        echo "  2. Hapus SSH key mencurigakan"
        echo "  3. PermitRootLogin no"
        echo "  4. PasswordAuthentication no"
        echo "  5. Hapus cron job mencurigakan"
        echo "  6. Ganti semua password"
        echo "  7. sudo apt update && sudo apt upgrade -y"
        echo "  8. sudo apt install -y fail2ban"
        echo "  9. Backup data, install ulang jika banyak temuan"
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "  ${YELLOW}${BOLD}Ada peringatan -- periksa seperlunya.${NC}"
    else
        echo -e "  ${GREEN}${BOLD}VPS AMAN! Tidak ada backdoor/akun tersembunyi.${NC}"
    fi

    echo ""
    echo -e "  ${CYAN}Hasil disimpan: vps_audit_$(date +%Y%m%d_%H%M%S).log${NC}"
}

# -- MAIN --
main() {
    banner
    check_root
    check_all_users
    check_shadow
    check_authorized_keys
    check_ssh_config
    check_ssh_ports
    check_ssh_logs
    check_cron_jobs
    check_suspicious_processes
    check_hidden_files
    check_services
    check_binaries
    check_system_files
    check_kernel_modules
    check_ssh_login_users
    summary
    echo -e "${CYAN}${BOLD}Audit selesai.${NC}"
}

LOG_FILE="vps_audit_$(date +%Y%m%d_%H%M%S).log"
main 2>&1 | tee "$LOG_FILE"
