#!/bin/bash
# =============================================================
#   ╔╦╗╔═╗╔═╗╦╔═╔╦╗  ╔╗ ╦╔═╗╦ ╦╦╔═╔╦╗╦═╗╦ ╦╔═╗╦
#   ║║║║╣ ║ ╦╠╩╗ ║   ╠╩╗║║ ║╠═╣╠╩╗ ║ ╠╦╝╠═╣║╣ ║
#   ╩ ╩╚═╝╚═╝╩ ╩ ╩   ╚═╝╩╚═╝╩ ╩╩ ╩ ╩ ╩╚═╩ ╩╚═╝╩═╝
#
#   🌿 GIT MANAGER — Terminal Edition v1.0
#
#   ✨ Fitur : Auto Push • Status • Log & Checkout Hash
#              Cek/Ubah Remote SSH↔HTTPS • Branch
#              Stash • Diff • Undo • Tag • Release Push
# =============================================================

SSH_DIR="$HOME/.ssh"

# =============================================
#  PALET WARNA
# =============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Gradient (truecolor jika didukung, fallback warna dasar)
if [ -n "$COLORTERM" ] && { [ "$COLORTERM" = "truecolor" ] || [ "$COLORTERM" = "24bit" ]; }; then
    G1='\033[38;5;39m'
    G2='\033[38;5;38m'
    G3='\033[38;5;44m'
    G4='\033[38;5;50m'
    G5='\033[38;5;51m'
else
    G1="$BLUE"; G2="$BLUE"; G3="$CYAN"; G4="$CYAN"; G5="$CYAN"
fi

# =============================================
#  UI KIT — konsisten dengan ssh_manager.sh
# =============================================
hr() {
    local width=56 symbol="${1:-─}" out="" i
    for (( i=0; i<width; i++ )); do out+="$symbol"; done
    printf "${DIM}%s${NC}\n" "$out"
}

section() {
    printf "\n  ${G1}┌─${NC} ${BOLD}${G5}⚙ %b${NC} ${G1}─┐${NC}\n" "$1"
    hr
}

info_box() {
    printf "  ${G4}╭─${NC} ${BOLD}${G5}%b${NC}\n" "$1"
    shift
    for line in "$@"; do
        printf "  ${G4}│${NC}   %b\n" "$line"
    done
    printf "  ${G4}╰──────────────${NC}\n"
}

msg_ok()   { printf "  ${GREEN}✔${NC} %b\n" "$1"; }
msg_err()  { printf "  ${RED}✘${NC} %b\n" "$1"; }
msg_warn() { printf "  ${YELLOW}⚠${NC} %b\n" "$1"; }
msg_info() { printf "  ${G4}ℹ${NC} %b\n" "$1"; }
msg_step() { printf "  ${DIM}▸${NC} %b ${DIM}%b${NC}\n" "$1" "${2:-…}"; }

prompt() {
    printf "  ${MAGENTA}❯${NC} ${BOLD}%b${NC}" "$1"
}

spinner() {
    local pid=$1 msg=$2 sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 "$pid" 2>/dev/null; do
        for (( j=0; j<${#sp}; j++ )); do
            printf "\r  ${G5}%s${NC} ${DIM}%b${NC}   " "${sp:$j:1}" "$msg"
            sleep 0.08
        done
    done
    printf "\r\033[K"
}

progress_bar() {
    local pct=$1 label="${2:-Memproses…}"
    local width=32 filled=$(( pct * width / 100 ))
    printf "\r  ${G5}┃${NC}"
    for (( k=0; k<filled; k++ )); do printf "${G4}█${NC}"; done
    for (( k=filled; k<width; k++ )); do printf "${DIM}░${NC}"; done
    printf "${G5}┃${NC} ${G5}%3d%%${NC} ${DIM}%b${NC}   " "$pct" "$label"
}

typewriter() {
    local text="$1" delay="${2:-0.015}"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        [ "$delay" != "0" ] && sleep "$delay"
    done
    printf "\n"
}

clear_screen() {
    clear
    print_banner
}

separator_alert() {
    printf "  ${RED}▓▒░ %b ░▒▓${NC}\n" "$1"
}

# =============================================
#  BANNER
# =============================================
print_banner() {
    echo -e ""
    echo -e "  ${G1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}    ${G1}G${G2}I${G3}T${NC} ${G4}M${G4}A${G5}N${G5}A${G5}G${G5}E${G5}R           ${NC}                                ${G1}║${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}    ${DIM}🌿 T E R M I N A L   E D I T I O N   v 1 . 0${NC}          ${G1}║${NC}"
    echo -e "  ${G1}║${NC}                                                          ${G1}║${NC}"
    echo -e "  ${G1}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# =============================================
#  UTIL GIT — deteksi repo & konfirmasi
# =============================================

# Pastikan sedang berada di dalam git repo
require_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        msg_err "Kamu tidak sedang berada di dalam ${BOLD}git repository${NC}."
        echo ""
        msg_info "Buka terminal di folder project, atau ${BOLD}cd${NC} ke folder berisi .git"
        msg_info "Atau inisialisasi repo baru lewat menu ${G5}[12]${NC}."
        return 1
    fi
    return 0
}

# Konfirmasi ya/tidak dengan default
confirm() {  # $1=pertanyaan, $2=default (y/n)
    local def="${2:-y}" answer
    prompt "$1 ${DIM}(Y/n)${NC} : "
    read answer
    answer=${answer:-$def}
    [ "$answer" = "y" ] || [ "$answer" = "Y" ]
}

# Ekstrak info remote: protokol + user + repo
parse_remote() {
    REMOTE_URL=$(git remote get-url origin 2>/dev/null)
    REMOTE_PROTO="none"
    REMOTE_USER=""
    REMOTE_REPO=""
    if [[ "$REMOTE_URL" == git@github.com:* ]]; then
        REMOTE_PROTO="ssh"
        REMOTE_USER=$(echo "$REMOTE_URL" | sed 's|git@github.com:||; s|\.git$||' | cut -d'/' -f1)
        REMOTE_REPO=$(echo "$REMOTE_URL" | sed 's|git@github.com:||; s|\.git$||' | cut -d'/' -f2)
    elif [[ "$REMOTE_URL" == https://* ]]; then
        REMOTE_PROTO="https"
        # https://github.com/user/repo.git atau token@github.com
        local stripped=$(echo "$REMOTE_URL" | sed 's|^https://||; s|\.git$||; s|^[^@]*@||')
        REMOTE_USER=$(echo "$stripped" | cut -d'/' -f2)
        REMOTE_REPO=$(echo "$stripped" | cut -d'/' -f3)
    fi
}

# =============================================
#  MENU 1 : AUTO PUSH
# =============================================
auto_push() {
    section "🚀 AUTO PUSH (add → commit → push)"
    require_repo || return

    echo ""
    # Tampilkan ringkasan status dulu
    local added=0 modified=0 deleted=0 untracked=0 staged=0
    while IFS= read -r line; do
        case "$line" in
            "A  "*)  ((added++)) ;;
            "M  "*)  ((modified++)) ;;
            "D  "*)  ((deleted++)) ;;
            "??"*)   ((untracked++)) ;;
        esac
    done < <(git status --porcelain)

    if [ -z "$(git status --porcelain)" ]; then
        msg_ok "Working tree ${BOLD}bersih${NC} — tidak ada perubahan baru. ✨"

        # Cek apakah ada commit lokal yang belum ter-push ke remote
        local branch=$(git branch --show-current)
        local ahead=0
        if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" &>/dev/null; then
            ahead=$(git rev-list --count "@{u}..HEAD" 2>/dev/null)
        fi

        if [ "${ahead:-0}" -gt 0 ]; then
            echo ""
            msg_warn "Ada ${BOLD}${ahead}${NC} commit lokal yang ${BOLD}belum ter-push${NC} ke origin/$branch."
            echo ""
            if confirm "Push sekarang?"; then
                echo ""
                msg_step "git push"
                local start=$(date +%s)
                git push origin "$branch" 2>&1 | sed 's/^/      /' &
                local pid=$!
                spinner $pid "Mengirim ke origin/$branch..."
                wait $pid
                local rc=${PIPESTATUS[0]}
                if [ "$rc" -eq 0 ]; then
                    msg_ok "🚀 Push berhasil ke ${G4}origin/$branch${NC}!"
                else
                    msg_err "Push gagal — lihat pesan error di atas."
                fi
            else
                msg_info "Dibatalkan. Jalankan ${YELLOW}git push${NC} kapan saja."
            fi
        fi
        return
    fi

    info_box "📊 Ringkasan Perubahan" \
             "Staged      → $staged file" \
             "Added       → $added" \
             "Modified    → $modified" \
             "Deleted     → $deleted" \
             "Untracked   → $untracked"
    echo ""

    prompt "Pesan commit ${DIM}(default: update $(date +%d-%m-%Y))${NC} : "
    read commit_msg
    commit_msg=${commit_msg:-"update $(date +%d-%m-%Y)"}

    echo ""
    msg_step "git add -A"
    git add -A

    msg_step "git commit"
    git commit -m "$commit_msg" | sed 's/^/      /'

    msg_step "git push"
    local branch=$(git branch --show-current)
    local start=$(date +%s)
    git push origin "$branch" 2>&1 | sed 's/^/      /' &
    local pid=$!
    spinner $pid "Mengirim ke origin/$branch..."
    wait $pid
    local rc=$?

    if [ $rc -eq 0 ]; then
        msg_ok "🚀 Push berhasil ke ${G4}origin/$branch${NC}!"
    else
        msg_err "Push gagal — lihat pesan error di atas."
        echo ""
        msg_info "Kemungkinan: remote belum ada (menu 4), konflik (menu 5), atau jaringan."
    fi
}

# =============================================
#  MENU 2 : STATUS
# =============================================
git_status() {
    section "📊 GIT STATUS"
    require_repo || return
    echo ""
    git status
}

# =============================================
#  MENU 3 : LOG & CHECKOUT HASH
# =============================================
git_log_checkout() {
    section "📜 LOG & KEMBALI KE HASH"
    require_repo || return
    echo ""

    # Tampilkan log ringkas bergaya graph
    echo -e "  ${DIM}── 20 commit terakhir ──${NC}"
    git log --oneline --decorate -20 | while IFS= read -r line; do
        # Highlight hash dan HEAD
        echo "$line" | sed -E \
            -e "s/^([0-9a-f]{7}) /${G5}\1${NC} /" \
            -e "s/(HEAD[a-z ()->a-zA-Z\/-]*)/${YELLOW}\1${NC}/" \
            -e "s/ \(origin\/([a-zA-Z0-9._-]+)\)/ ${G4}(origin\/\1)${NC}/" \
            -e "s/ \(tag: ([^)]+)\)/ ${MAGENTA}(tag: \1)${NC}/"
    done
    echo ""
    hr
    prompt "Ketik hash untuk checkout ${DIM}(Enter = tidak jadi)${NC} : "
    read hash
    [ -z "$hash" ] && { msg_info "Dibatalkan."; return; }

    # Validasi hash
    if ! git rev-parse --verify "$hash^{commit}" &>/dev/null; then
        msg_err "Hash '${hash}' tidak ditemukan."
        return
    fi

    echo ""
    info_box "📌 Detail Commit" \
             "Hash    → $(git log -1 --format='%h' "$hash")" \
             "Author  → $(git log -1 --format='%an' "$hash")" \
             "Tanggal → $(git log -1 --format='%ad' --date=short "$hash")" \
             "Msg     → $(git log -1 --format='%s' "$hash")"
    echo ""

    echo -e "  ${G4}(1)${NC} Checkout hash ke branch baru ${DIM}(aman, disarankan)${NC}"
    echo -e "  ${G4}(2)${NC} Detach HEAD ke hash ${DIM}(hanya lihat-lihat)${NC}"
    echo -e "  ${G4}(3)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-3]${NC} : "
    read mode
    case $mode in
        1)
            prompt "Nama branch baru : "
            read newbranch
            [ -z "$newbranch" ] && { msg_err "Nama branch wajib diisi."; return; }
            git checkout -b "$newbranch" "$hash" && \
                msg_ok "Branch ${G5}$newbranch${NC} dibuat dari ${G5}$(git log -1 --format='%h' "$hash")${NC}" || \
                msg_err "Gagal checkout."
            ;;
        2)
            git checkout "$hash" && \
                msg_ok "Detach HEAD ke ${G5}$hash${NC}. ${YELLOW}git checkout main${NC} untuk kembali." || \
                msg_err "Gagal checkout."
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
 #   parse_remote
 #   if [ "$REMOTE_PROTO" = "ssh" ]; then
 #       msg_info "Kamu bisa juga checkout remote branch: git checkout -b [nama] origin/branch"
 #   fi
}

# =============================================
#  MENU 4 : REMOTE — CEK & UBAH SSH/HTTPS
# =============================================
remote_check_switch() {
    section "🔗 REMOTE — CEK & UBAH SSH ↔ HTTPS"
    require_repo || return
    echo ""

    parse_remote

    if [ -z "$REMOTE_URL" ]; then
        msg_warn "Belum ada remote ${BOLD}origin${NC} di repo ini."
        echo ""
        prompt "Tambahkan remote sekarang? (y/n) : "
        read addnow
        if [ "$addnow" = "y" ] || [ "$addnow" = "Y" ]; then
            prompt "Repo GitHub ${DIM}(format: user/repo)${NC} : "
            read userrepo
            [ -z "$userrepo" ] && { msg_err "Format wajib 'user/repo'."; return; }
            git remote add origin "git@github.com:${userrepo}.git"
            msg_ok "Remote origin ditambahkan via ${G5}SSH${NC}."
        fi
        return
    fi

    # Tampilkan status remote dengan gaya
    if [ "$REMOTE_PROTO" = "ssh" ]; then
        info_box "✅ Remote Aktif — SSH 🔑" \
                 "URL      → ${G5}$REMOTE_URL${NC}" \
                 "User     → $REMOTE_USER" \
                 "Repo     → $REMOTE_REPO" \
                 "Protokol → ${GREEN}SSH${NC} (tanpa password, ideal untuk push)"
    elif [ "$REMOTE_PROTO" = "https" ]; then
        info_box "⚠ Remote Aktif — HTTPS 🌐" \
                 "URL      → ${YELLOW}$REMOTE_URL${NC}" \
                 "User     → $REMOTE_USER" \
                 "Repo     → $REMOTE_REPO" \
                 "Protokol → ${YELLOW}HTTPS${NC} (butuh login/token tiap push)"
    else
        info_box "❓ Remote Tidak Dikenal" \
                 "URL → $REMOTE_URL"
    fi

    echo ""
    echo -e "  ${G4}(1)${NC} Ganti ke ${G5}SSH${NC} ${DIM}(git@github.com:...) — disarankan${NC}"
    echo -e "  ${G4}(2)${NC} Ganti ke ${YELLOW}HTTPS${NC} ${DIM}(https://github.com/...)${NC}"
    echo -e "  ${G4}(3)${NC} Lihat semua remote ${DIM}(git remote -v)${NC}"
    echo -e "  ${G4}(4)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-4]${NC} : "
    read opt
    case $opt in
        1)
            git remote set-url origin "git@github.com:${REMOTE_USER}/${REMOTE_REPO}.git"
            msg_ok "Remote diganti ke ${G5}SSH${NC}:"
            echo -e "      ${DIM}$(git remote get-url origin)${NC}"
            ;;
        2)
            git remote set-url origin "https://github.com/${REMOTE_USER}/${REMOTE_REPO}.git"
            msg_ok "Remote diganti ke ${YELLOW}HTTPS${NC}:"
            echo -e "      ${DIM}$(git remote get-url origin)${NC}"
            ;;
        3)
            echo ""
            git remote -v | sed 's/^/  /'
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU 5 : PULL & SYNC
# =============================================
git_pull() {
    section "⬇️  PULL & SYNC DARI GITHUB"
    require_repo || return
    echo ""

    local branch=$(git branch --show-current)
    msg_step "Branch aktif" "$branch"

    if [ "$(git status --porcelain | wc -l)" -gt 0 ]; then
        msg_warn "Ada perubahan lokal yang belum di-commit — lebih baik commit/stash dulu."
        echo ""
        if confirm "Tetap pull sekarang? (mungkin konflik)"; then
            :
        else
            msg_info "Dibatalkan — gunakan menu ${G5}[10]${NC} untuk stash."
            return
        fi
    fi

    echo ""
    msg_step "git pull"
    git pull origin "$branch" 2>&1 | sed 's/^/      /' &
    local pid=$!
    spinner $pid "Menarik dari origin/$branch..."
    wait $pid
    if [ $? -eq 0 ]; then
        msg_ok "Pull selesai! ✨"
    else
        msg_err "Pull gagal — cek konflik dengan menu ${G5}[2]${NC} status."
    fi
}

# =============================================
#  MENU 6 : BRANCH MANAGER
# =============================================
branch_manager() {
    section "🌿 BRANCH MANAGER"
    require_repo || return
    echo ""

    # Daftar branch dengan highlight current
    echo -e "  ${DIM}── Branch lokal ──${NC}"
    git branch | while IFS= read -r b; do
        b_no_star=$(echo "$b" | sed 's/^\* //')
        if [[ "$b" == \** ]]; then
            echo -e "  ${GREEN}●${NC} ${BOLD}${G5}$b_no_star${NC} ${DIM}(aktif)${NC}"
        else
            echo -e "  ${DIM}○${NC} $b_no_star"
        fi
    done
    echo ""

    echo -e "  ${G4}(1)${NC} Buat & pindah branch baru ${DIM}(checkout -b)${NC}"
    echo -e "  ${G4}(2)${NC} Pindah branch ${DIM}(checkout)${NC}"
    echo -e "  ${G4}(3)${NC} Hapus branch"
    echo -e "  ${G4}(4)${NC} Push branch baru ke origin ${DIM}(push -u)${NC}"
    echo -e "  ${G4}(5)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-5]${NC} : "
    read opt
    case $opt in
        1)
            prompt "Nama branch baru : "
            read nb
            [ -z "$nb" ] && { msg_err "Nama wajib diisi."; return; }
            git checkout -b "$nb" && msg_ok "Branch ${G5}$nb${NC} dibuat & aktif." || msg_err "Gagal."
            ;;
        2)
            prompt "Nama branch tujuan : "
            read tb
            git checkout "$tb" && msg_ok "Pindah ke ${G5}$tb${NC}." || msg_err "Branch tidak ditemukan."
            ;;
        3)
            prompt "Nama branch yang dihapus : "
            read db
            # Cegah hapus branch aktif
            if [ "$(git branch --show-current)" = "$db" ]; then
                msg_err "Tidak bisa hapus branch yang sedang aktif. Pindah dulu."
                return
            fi
            git branch -D "$db" && msg_ok "Branch ${G5}$db${NC} dihapus." || msg_err "Gagal hapus."
            ;;
        4)
            prompt "Nama branch : "
            read pb
            git push -u origin "$pb" 2>&1 | sed 's/^/      /' && msg_ok "Branch ${G5}$pb${NC} terkirim & tracking origin."
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU 7 : STASH MANAGER
# =============================================
stash_manager() {
    section "📦 STASH MANAGER"
    require_repo || return
    echo ""

    echo -e "  ${DIM}── Stash tersimpan ──${NC}"
    local stash_list=$(git stash list)
    if [ -z "$stash_list" ]; then
        msg_info "Belum ada stash."
    else
        echo "$stash_list" | sed 's/^/  /'
    fi
    echo ""

    echo -e "  ${G4}(1)${NC} Stash sekarang ${DIM}(simpan perubahan sementara)${NC}"
    echo -e "  ${G4}(2)${NC} Pop stash terbaru ${DIM}(ambil kembali)${NC}"
    echo -e "  ${G4}(3)${NC} Hapus stash terbaru"
    echo -e "  ${G4}(4)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-4]${NC} : "
    read opt
    case $opt in
        1)
            git stash && msg_ok "Perubahan distash. ✅" || msg_err "Tidak ada yang bisa distash."
            ;;
        2)
            git stash pop 2>&1 | sed 's/^/      /' && msg_ok "Stash di-pop." || msg_err "Pop gagal."
            ;;
        3)
            git stash drop && msg_ok "Stash terbaru dihapus."
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU 8 : DIFF VIEWER
# =============================================
diff_viewer() {
    section "🔍 DIFF — Lihat Perubahan"
    require_repo || return
    echo ""

    echo -e "  ${G4}(1)${NC} Perubahan belum di-stage ${DIM}(working dir)${NC}"
    echo -e "  ${G4}(2)${NC} Perubahan sudah di-stage"
    echo -e "  ${G4}(3)${NC} Perubahan antara 2 commit terakhir"
    echo -e "  ${G4}(4)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-4]${NC} : "
    read opt
    echo ""
    case $opt in
        1) git diff | less -R ;;
        2) git diff --cached | less -R ;;
        3) git diff HEAD~1 HEAD | less -R ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU 9 : COMMIT HISTORY & UNDO
# =============================================
commit_undo() {
    section "⏪ UNDO COMMIT"
    require_repo || return
    echo ""

    echo -e "  ${DIM}── 5 commit terakhir ──${NC}"
    git log --oneline -5 | sed 's/^/  /'
    echo ""
    echo -e "  ${G4}(1)${NC} Undo commit terakhir, ${GREEN}simpan perubahan${NC} ${DIM}(soft reset)${NC}"
    echo -e "  ${G4}(2)${NC} Undo commit terakhir, ${RED}buang perubahan${NC} ${DIM}(hard reset)${NC}"
    echo -e "  ${G4}(3)${NC} Ubah pesan commit terakhir ${DIM}(amend)${NC}"
    echo -e "  ${G4}(4)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-4]${NC} : "
    read opt
    case $opt in
        1)
            git reset --soft HEAD~1 && msg_ok "Commit dibuka, perubahan tetap di stage."
            ;;
        2)
            separator_alert "PERINGATAN — TIDAK BISA DIBATALKAN"
            if confirm "Yakin buang commit & semua perubahannya?"; then
                git reset --hard HEAD~1 && msg_ok "Commit terakhir dibuang permanen."
            else
                msg_info "Dibatalkan."
            fi
            ;;
        3)
            prompt "Pesan commit baru : "
            read newmsg
            [ -z "$newmsg" ] && { msg_err "Pesan wajib diisi."; return; }
            git commit --amend -m "$newmsg" && msg_ok "Pesan commit diperbarui."
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU 10 : TAG & RELEASE
# =============================================
tag_release() {
    section "🏷  TAG & RELEASE"
    require_repo || return
    echo ""

    echo -e "  ${DIM}── Tag lokal ──${NC}"
    git tag | tail -10 | while IFS= read -r t; do
        echo -e "  ${MAGENTA}🏷${NC} $t"
    done
    [ -z "$(git tag)" ] && msg_info "Belum ada tag."
    echo ""

    echo -e "  ${G4}(1)${NC} Buat tag baru ${DIM}(annotated)${NC}"
    echo -e "  ${G4}(2)${NC} Push semua tag ke origin"
    echo -e "  ${G4}(3)${NC} Hapus tag lokal"
    echo -e "  ${G4}(4)${NC} Batal"
    echo ""
    prompt "Pilih ${DIM}[1-4]${NC} : "
    read opt
    case $opt in
        1)
            prompt "Nama tag ${DIM}(contoh: v1.0.0)${NC} : "
            read tn
            [ -z "$tn" ] && { msg_err "Nama tag wajib diisi."; return; }
            prompt "Pesan release ${DIM}(opsional)${NC} : "
            read tp
            if [ -n "$tp" ]; then
                git tag -a "$tn" -m "$tp"
            else
                git tag -a "$tn" -m "Release $tn"
            fi
            msg_ok "Tag ${MAGENTA}$tn${NC} dibuat."
            ;;
        2)
            git push origin --tags 2>&1 | sed 's/^/      /' && msg_ok "Semua tag terkirim ke origin."
            ;;
        3)
            prompt "Nama tag dihapus : "
            read td
            git tag -d "$td" && msg_ok "Tag ${MAGENTA}$td${NC} dihapus."
            ;;
        *) msg_info "Dibatalkan." ;;
    esac
}

# =============================================
#  MENU 11 : REPO INFO
# =============================================
repo_info() {
    section "ℹ️  REPO INFO"
    require_repo || return
    echo ""

    parse_remote
    local branch=$(git branch --show-current)
    local ncommits=$(git rev-list --count HEAD 2>/dev/null)
    local ntags=$(git tag | wc -l)
    local nbranches=$(git branch | wc -l)

    info_box "📊 Statistik Repo" \
             "Branch aktif   → ${G5}$branch${NC}" \
             "Total commit   → $ncommits" \
             "Total branch   → $nbranches" \
             "Total tag      → $ntags" \
             "Remote         → ${REMOTE_PROTO^^}: $REMOTE_USER/$REMOTE_REPO" \
             "Lokasi         → $(pwd)"
}

# =============================================
#  MENU 12 : INIT REPO BARU
# =============================================
init_repo() {
    section "✨ INIT REPO BARU"
    echo ""

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        msg_warn "Folder ini ${BOLD}sudah${NC} merupakan git repo."
        return
    fi

    if confirm "Inisialisasi git repo di $(pwd)?"; then
        git init
        msg_ok "Repo baru dibuat. 🎉"

        # Otomatis kecualikan script manager ini dari git
        local exclude_file=".git/info/exclude"
        local scripts=("git_manager.sh" "ssh_manager.sh" "ssh_managser.sh" "*.sh.bak")
        for s in "${scripts[@]}"; do
            if ! grep -qxF "$s" "$exclude_file" 2>/dev/null; then
                echo "$s" >> "$exclude_file"
            fi
        done
        msg_ok "Script manager otomatis dikecualikan ${DIM}(.git/info/exclude)${NC}"

        echo ""
        prompt "Tambahkan remote GitHub? ${DIM}(user/repo, Enter = lewati)${NC} : "
        read ur
        if [ -n "$ur" ]; then
            git remote add origin "git@github.com:${ur}.git"
            msg_ok "Remote origin via ${G5}SSH${NC} → ${ur}"
        fi
    else
        msg_info "Dibatalkan."
    fi
}

# =============================================
#  MENU 13 : PANDUAN
# =============================================
show_help() {
    section "❓ PANDUAN CEPAT"
    echo ""
    info_box "🚀 Alur kerja harian paling umum" \
             "${G5}[1]${NC} Auto Push    → add+commit+push dalam satu langkah" \
             "${G5}[2]${NC} Status       → lihat file berubah/t belum di-commit" \
             "${G5}[5]${NC} Pull         → ambil update dari GitHub sebelum kerja" \
             "${G5}[9]${NC} Undo         → salah commit? batalkan di sini"
    echo ""
    info_box "🔗 Remote SSH vs HTTPS" \
             "SSH    → git@github.com:user/repo.git (tanpa password, ideal)" \
             "HTTPS  → https://github.com/user/repo.git (butuh token)" \
             "Menu ${G5}[4]${NC} bisa cek & ganti kapan saja"
    echo ""
    info_box "💡 Tips" \
             "Rekomendasi urutan aman: pull → kerja → status → push" \
             "Branch untuk fitur baru: menu ${G5}[6]${NC} checkout -b" \
             "Ragu-ragu? Stash dulu di menu ${G5}[7]${NC} sebelum eksperimen"
}

# =============================================
#  MENU 14 : IGNORE SCRIPT — ANTI TER-PUSH
# =============================================
ignore_manager() {
    section "🛡  IGNORE SCRIPT — ANTI TER-PUSH"
    require_repo || return
    echo ""

    info_box "🎯 Tujuan" \
             "Mencegah file script manager ikut terkirim ke GitHub" \
             "saat kamu menjalankan ${G5}[1]${NC} Auto Push ${DIM}(karena git add -A${NC}" \
             "${DIM}              memasukkan semua file tanpa pilih-pilih)${NC}."
    echo ""

    info_box "① Metode LOCAL → .git/info/exclude" \
             "Perintah : ${CYAN}echo \"git_manager.sh\" >> .git/info/exclude${NC}" \
             "Sifat    → ${GREEN}Hanya berlaku di komputermu${NC}" \
             "         → Aturannya tersimpan di folder .git ${DIM}(tidak ter-push)${NC}" \
             "         → Tanpa commit, tanpa mengubah isi repo" \
             "Cocok    → Script pribadi / tools sendiri ${G5}★ disarankan${NC}"
    echo ""

    info_box "② Metode GLOBAL → .gitignore" \
             "Perintah : ${CYAN}echo -e \"git_manager.sh\" >> .gitignore${NC}" \
             "           ${CYAN}git add .gitignore${NC}" \
             "           ${CYAN}git commit -m \"ignore manager scripts\"${NC}" \
             "Sifat    → ${YELLOW}Berlaku untuk semua orang${NC} yang clone repo ini" \
             "         → File .gitignore ${BOLD}ikut ter-push${NC} ke GitHub" \
             "Cocok    → Aturan bersama dalam project tim"
    echo ""

    prompt "Pilih metode ${DIM}[1 = Local / 2 = Global / lainnya = batal]${NC} : "
    read method
    echo ""

    local files=("git_manager.sh" "ssh_manager.sh" "ssh_managser.sh" "*.sh.bak")
    local f extra

    case $method in
        # ---------- METODE 1 : LOCAL ----------
        1)
            msg_step "Menulis aturan ke ${BOLD}.git/info/exclude${NC}"
            local exclude_file="$(git rev-parse --git-dir)/info/exclude"
            for f in "${files[@]}"; do
                if grep -qxF "$f" "$exclude_file" 2>/dev/null; then
                    msg_info "Sudah ada    → ${DIM}$f${NC}"
                else
                    echo "$f" >> "$exclude_file"
                    msg_ok "Dikecualikan → ${G5}$f${NC}"
                fi
            done

            # Opsi tambah file lain secara manual
            while true; do
                prompt "Tambah file lain? ${DIM}(Enter = selesai)${NC} : "
                read extra
                [ -z "$extra" ] && break
                if grep -qxF "$extra" "$exclude_file" 2>/dev/null; then
                    msg_info "Sudah ada    → ${DIM}$extra${NC}"
                else
                    echo "$extra" >> "$exclude_file"
                    msg_ok "Dikecualikan → ${G5}$extra${NC}"
                fi
            done

            echo ""
            separator_alert "HASIL AKHIR"
            msg_ok "Metode ${GREEN}LOCAL${NC} selesai! File di atas kini ${BOLD}tak terlihat${NC} oleh git."
            msg_info "Buktikan dengan menu ${G5}[2]${NC} Status — file tidak akan muncul di daftar."
            msg_info "Aturan ini ${BOLD}tidak ikut ter-push${NC} — tersimpan hanya di komputermu."
            ;;

        # ---------- METODE 2 : GLOBAL ----------
        2)
            msg_step "Menulis aturan ke ${BOLD}.gitignore${NC}"
            for f in "${files[@]}"; do
                if grep -qxF "$f" .gitignore 2>/dev/null; then
                    msg_info "Sudah ada    → ${DIM}$f${NC}"
                else
                    echo "$f" >> .gitignore
                    msg_ok "Ditambahkan  → ${G5}$f${NC}"
                fi
            done

            # Opsi tambah file lain secara manual
            while true; do
                prompt "Tambah file lain? ${DIM}(Enter = selesai)${NC} : "
                read extra
                [ -z "$extra" ] && break
                if grep -qxF "$extra" .gitignore 2>/dev/null; then
                    msg_info "Sudah ada    → ${DIM}$extra${NC}"
                else
                    echo "$extra" >> .gitignore
                    msg_ok "Ditambahkan  → ${G5}$extra${NC}"
                fi
            done

            # Jika script sudah terlanjur di-track, lepaskan dulu dari index
            echo ""
            for f in "${files[@]}"; do
                [[ "$f" == \** ]] && continue   # wildcard tidak bisa dicek
                if git ls-files --error-unmatch "$f" &>/dev/null; then
                    msg_warn "'$f' sudah terlanjur di-track — melepas dari index..."
                    git rm --cached "$f" &>/dev/null
                    msg_ok "Dilepas dari tracking ${DIM}(file fisik tetap ada di folder)${NC}"
                fi
            done

            echo ""
            msg_step "git add .gitignore && git commit -m \"ignore manager scripts\""
            git add .gitignore
            git add -u   # ikut stage pelepasan rm --cached (jika ada)
            local commit_out
            commit_out=$(git commit -m "ignore manager scripts" 2>&1)
            if echo "$commit_out" | grep -q "nothing to commit"; then
                msg_warn "Tidak ada perubahan baru untuk di-commit ${DIM}(mungkin sudah pernah)${NC}."
            else
                msg_ok "Commit ${G5}\"ignore manager scripts\"${NC} berhasil dibuat."
            fi

            echo ""
            separator_alert "HASIL AKHIR"
            msg_ok "Metode ${YELLOW}GLOBAL${NC} selesai! Aturan berlaku untuk semua clone repo."
            msg_info "Ingat: file ${YELLOW}.gitignore ikut ter-push${NC} saat Auto Push berikutnya."
            ;;

        *)
            msg_info "Dibatalkan — tidak ada yang diubah."
            ;;
    esac
}

# =============================================
#  MENU 15 : SYNC DENGAN GITHUB
# =============================================
git_sync() {
    section "🔄 SYNC — SAMAKAN LOCAL DENGAN GITHUB"
    require_repo || return
    echo ""

    local branch=$(git branch --show-current)
    msg_step "Branch aktif" "$branch"

    # Cek apakah remote origin ada
    if ! git remote get-url origin &>/dev/null; then
        msg_err "Remote ${BOLD}origin${NC} belum ada. Tambah via menu ${G5}[4]${NC} dulu."
        return
    fi

    parse_remote

    # 1. FETCH — ambil info terbaru dari GitHub tanpa merge
    msg_step "Fetch dari remote..."
    git fetch origin 2>&1 | sed 's/^/      /' || { msg_err "Fetch gagal."; return; }
    msg_ok "Fetch selesai. 📡"
    echo ""

    # 2. Cek posisi local vs remote
    local ahead=0 behind=0
    ahead=$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)
    behind=$(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo 0)

    info_box "🔄 Status Remote ${DIM}(origin/$branch)${NC}" \
             "Local ahead  → ${GREEN}+${ahead}${NC} commit ${DIM}(belum di-push)${NC}" \
             "Local behind → ${YELLOW}-${behind}${NC} commit ${DIM}(ketinggalan dari GitHub)${NC}" \
             "" \
             "Remote → ${REMOTE_PROTO^^}: ${G5}$REMOTE_USER/$REMOTE_REPO${NC}"
    echo ""

    # 3. Aksi berdasarkan kondisi
    if [ "$behind" -eq 0 ] && [ "$ahead" -eq 0 ]; then
        msg_ok "Local sama persis dengan GitHub. Tidak perlu sync. ✨"
        return
    fi

    if [ "$behind" -gt 0 ]; then
        msg_warn "Local ${BOLD}tertinggal${NC} ${behind} commit dari GitHub."
        echo ""

        # Cek dulu apakah ada perubahan lokal yang belum di-commit
        local has_changes=0
        if [ -n "$(git status --porcelain)" ]; then
            has_changes=1
            msg_warn "Ada perubahan lokal yang belum di-commit."
            echo ""
            echo -e "  ${G4}(1)${NC} Stash dulu → lalu pull secara aman           ${GREEN}★ rekomendasi${NC}"
            echo -e "  ${G4}(2)${NC} Commit dulu → lalu rebase/pull"
            echo -e "  ${G4}(3)${NC} Pull paksa (timbun file lokal — hati-hati!)"
            echo -e "  ${G4}(4)${NC} Batal — urungkan sync"
            echo ""
            prompt "Pilih cara ${DIM}[1–4]${NC} : "
            read sync_opt
            echo ""

            case $sync_opt in
                1)
                    msg_step "Stash perubahan lokal..."
                    git stash push -m "auto-stash sebelum sync $(date '+%H:%M:%S')" | sed 's/^/      /'
                    msg_ok "Stash berhasil."
                    echo ""
                    ;;
                2)
                    msg_step "Commit perubahan lokal..."
                    git add -A
                    git commit -m "sync: commit sementara $(date '+%d-%m-%Y %H:%M')" | sed 's/^/      /'
                    echo ""
                    ;;
                3)
                    msg_warn "Melakukan pull paksa — file lokal yang bertabrakan akan ditimpa."
                    if ! confirm "Yakin?"; then
                        msg_info "Dibatalkan."
                        return
                    fi
                    ;;
                *)
                    msg_info "Dibatalkan."
                    return
                    ;;
            esac
        fi

        # Pull — tentukan strategi: rebase atau merge
        echo ""
        if [ "$has_changes" -eq 1 ] && [ "$sync_opt" = "1" ]; then
            # Stash → pull → pop stash
            msg_step "git pull --rebase (riwayat lebih rapi)"
            git pull --rebase origin "$branch" 2>&1 | sed 's/^/      /' || {
                msg_err "Konflik terjadi saat rebase. Selesaikan secara manual:"
                msg_info "  git status → perbaiki file konflik → git rebase --continue"
                msg_info "  lalu: git stash pop"
                return
            }
            msg_ok "Pull selesai."

            # Pop stash
            echo ""
            msg_step "Mengembalikan stash..."
            if git stash list | grep -q "auto-stash sebelum sync"; then
                git stash pop | sed 's/^/      /' && msg_ok "Stash dikembalikan."
            else
                msg_info "Tidak ada stash untuk dikembalikan."
            fi
        elif [ "$has_changes" -eq 1 ] && [ "$sync_opt" = "2" ]; then
            # Commit → pull biasa
            msg_step "git pull"
            git pull origin "$branch" 2>&1 | sed 's/^/      /'
        elif [ "$has_changes" -eq 1 ] && [ "$sync_opt" = "3" ]; then
            # Pull paksa — simpan dulu, hard reset
            msg_step "Menyimpan file lokal yang berkonflik..."
            git stash push -m "konflik-sync-backup" 2>/dev/null
            msg_step "git pull --force (reset ke origin/$branch)"
            git fetch origin
            git reset --hard "origin/$branch"
            msg_ok "Local sudah sama persis dengan GitHub. ⚡"
        else
            # Tidak ada perubahan lokal
            msg_step "git pull"
            git pull origin "$branch" 2>&1 | sed 's/^/      /' || {
                msg_err "Pull gagal. Coba cek konflik via menu ${G5}[2]${NC}."
                return
            }
            msg_ok "Pull selesai — local sudah update. 🎉"
        fi

        # Validasi hasil
        local behind_after=0
        behind_after=$(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo 0)
        if [ "$behind_after" -eq 0 ]; then
            msg_ok "✅ Sekarang local ${GREEN}sama persis${NC} dengan GitHub."
        else
            msg_warn "Masih tertinggal ${behind_after} commit — coba ulangi atau cek konflik."
        fi

    elif [ "$ahead" -gt 0 ]; then
        # Hanya ahead, tidak behind — push saja
        msg_info "Local ${BOLD}lebih maju${NC} ${ahead} commit dari GitHub."
        echo ""
        if confirm "Kirim ${ahead} commit lokal ke GitHub (push)?"; then
            echo ""
            msg_step "git push"
            git push origin "$branch" 2>&1 | sed 's/^/      /' &
            local pid=$!
            spinner $pid "Mengirim ke origin/$branch..."
            wait $pid
            rc=$?
            if [ "$rc" -eq 0 ]; then
                msg_ok "Push berhasil! ✅"
            else
                msg_err "Push gagal."
            fi
        else
            msg_info "Dibatalkan — ${YELLOW}git push${NC} nanti aja."
        fi
    fi
}

# =============================================
#  MENU UTAMA
# =============================================
show_menu() {
    clear_screen

    # Status ringkas repo (jika ada)
    local repo_stat="${YELLOW}○${NC} bukan git repo"
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local br=$(git branch --show-current 2>/dev/null)
        if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
            repo_stat="${GREEN}●${NC} ${G5}$br${NC} ${DIM}• bersih${NC}"
        else
            local dirty=$(git status --porcelain | wc -l)
            repo_stat="${YELLOW}●${NC} ${G5}$br${NC} ${DIM}• $dirty perubahan${NC}"
        fi
    fi
    printf "  ${DIM}Status:${NC} %b   ${DIM}│${NC}  🐙 github.com\n" "$repo_stat"
    echo ""

    echo -e "  ${G1}╭───${NC} ${BOLD}${G5}MENU UTAMA${NC}"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}│${NC}   ${G5}01${NC} ${CYAN}🚀${NC}  Auto Push (add → commit → push)"
    echo -e "  ${G1}│${NC}   ${G5}02${NC} ${CYAN}📊${NC}  Status Repo"
    echo -e "  ${G1}│${NC}   ${G5}03${NC} ${CYAN}📜${NC}  Log & Kembali ke Hash"
    echo -e "  ${G1}│${NC}   ${G5}04${NC} ${CYAN}🔗${NC}  Remote: SSH ↔ HTTPS"
    echo -e "  ${G1}│${NC}   ${G5}05${NC} ${CYAN}⬇️${NC}  Pull dari GitHub"
    echo -e "  ${G1}│${NC}   ${G5}06${NC} ${CYAN}🌿${NC}  Branch Manager"
    echo -e "  ${G1}│${NC}   ${G5}07${NC} ${CYAN}📦${NC}  Stash Manager"
    echo -e "  ${G1}│${NC}   ${G5}08${NC} ${CYAN}🔍${NC}  Diff Viewer"
    echo -e "  ${G1}│${NC}   ${G5}09${NC} ${CYAN}⏪${NC}  Undo Commit"
    echo -e "  ${G1}│${NC}   ${G5}10${NC} ${CYAN}🏷${NC}   Tag & Release"
    echo -e "  ${G1}│${NC}   ${G5}11${NC} ${CYAN}ℹ️${NC}  Repo Info"
    echo -e "  ${G1}│${NC}   ${G5}12${NC} ${CYAN}✨${NC}  Init Repo Baru"
    echo -e "  ${G1}│${NC}   ${G5}13${NC} ${CYAN}❓${NC}  Panduan"
    echo -e "  ${G1}│${NC}   ${G5}14${NC} ${CYAN}🛡${NC}   Ignore Script (Anti Ter-Push)"
    echo -e "  ${G1}│${NC}   ${G5}15${NC} ${CYAN}🔄${NC}  Sync dengan GitHub (pull & samakan)"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}│${NC}   ${RED}00${NC} ${RED}🚪${NC}  Keluar"
    echo -e "  ${G1}│${NC}"
    echo -e "  ${G1}╰${NC}"
    echo ""

    prompt "Pilih menu ${DIM}[00–15]${NC} : "
    read choice

    case $choice in
        1|01)  auto_push ;;
        2|02)  git_status ;;
        3|03)  git_log_checkout ;;
        4|04)  remote_check_switch ;;
        5|05)  git_pull ;;
        6|06)  branch_manager ;;
        7|07)  stash_manager ;;
        8|08)  diff_viewer ;;
        9|09)  commit_undo ;;
        10)    tag_release ;;
        11)    repo_info ;;
        12)    init_repo ;;
        13)    show_help ;;
        14)    ignore_manager ;;
        15)    git_sync ;;
        0|00)  goodbye ;;
        *)     echo ""; msg_err "Pilihan tidak valid — coba lagi." ;;
    esac
}

goodbye() {
    echo ""
    for pct in 100; do progress_bar $pct "menutup sesi..."; done
    printf "\r\033[K"
    echo ""
    typewriter "  🌿 Git session selesai. Happy coding! 👋" 0.02
    echo ""
    exit 0
}

# =============================================
#  INIT — satu siklus eksekusi
# =============================================
trap 'echo ""; echo -e "  ${YELLOW}⚠ Dihentikan oleh user.${NC}"; exit 1' INT TERM

show_menu

# Setelah aksi selesai: tanya sekali, lanjut atau keluar
echo ""
hr
prompt "Kembali ke menu? ${DIM}(Enter = ya / n = keluar)${NC} : "
read -r again
if [ "$again" != "n" ] && [ "$again" != "N" ]; then
    show_menu   # menu terakhir kali; pilih 00 untuk keluar
fi
