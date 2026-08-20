<p align="center">
  <img src="https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
</p>

<h1 align="center">🐚 Shell Scripting Collection</h1>

<p align="center">
  <strong>Kumpulan Script Shell & Python untuk Automasi, Administrasi,<br>
  Keamanan, dan Monitoring Server Linux</strong>
</p>

<p align="center">
  <a href="#-tentang">Tentang</a> •
  <a href="#-daftar-tools">Daftar Tools</a> •
  <a href="#-instalasi-cepat">Instalasi</a> •
  <a href="#-panduan-ssh--github">SSH & GitHub</a> •
  <a href="#-persyaratan-sistem">Persyaratan</a> •
  <a href="#-struktur-proyek">Struktur</a> •
  <a href="#-catatan-penting">Catatan</a>
</p>

---

## 📖 Tentang

**Shell Scripting Collection** adalah repositori yang berisi puluhan script shell dan Python siap pakai untuk membantu Anda mengelola server Linux secara efisien. Dirancang untuk **sysadmin, developer, dan pentester**, semua tools dikemas dengan antarmuka terminal interaktif berwarna yang memudahkan navigasi.

> ✨ **Highlight:** Menu dashboard terintegrasi (`newmenu.sh`) menyatukan seluruh tools dalam satu tampilan yang elegan dan mudah digunakan.

### 🎯 Yang Bisa Anda Lakukan

| Kategori | Kemampuan |
|----------|-----------|
| 🖥️ **Sistem** | Setup otomatis, reboot terjadwal, monitoring disk & resource |
| 🔐 **Keamanan** | Enkripsi file AES-256, spam detection, deteksi DDoS |
| 🌐 **Jaringan** | DNS lookup, ping test, host-to-IP, IP-to-host, Tailscale, ZeroTier |
| 🔧 **DevOps** | Git manager, SSH manager, service systemd, Nginx, Screen, Tmux |
| 🕵️ **OSINT** | Sherlock username finder, subdomain finder, domain tools |
| 📧 **Utility** | Kirim email, spam post, proxy Squid, DDNS DuckDNS |

---

## 🚀 Instalasi Cepat

### Prasyarat

Semua tools diinstall otomatis, Anda hanya perlu satu command:

```bash
apt update && apt upgrade -y && apt install -y wget curl sed && sleep 2 && \
wget -O /root/setup-all.sh https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/setup-all.sh && \
bash setup-all.sh
```

> ⚠️ **Jalankan sebagai root** (`sudo su` terlebih dahulu). Script ini akan menginstall semua dependensi (Python, pip, git, dll) dan menyalin seluruh tools ke `/usr/local/bin/`.

### Instalasi Manual Per-Tool

Jika Anda hanya ingin menginstall tool tertentu, gunakan perintah berikut:

```bash
# Git Manager (dari folder custom/)
wget -O git_manager.sh https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/custom/git_tools.sh

# SSH Manager
wget -O ssh_manager.sh https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/ssh_manager.sh

# DNS Lookup
wget -O lookup-dns.sh https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/lookup-dns.sh
```

---

## 📋 Daftar Tools

### 🖥️ Administrasi Sistem

| Script | Deskripsi | Cara Pakai |
|--------|-----------|------------|
| `setup-all.sh` | Auto-installer lengkap untuk semua dependensi & tools | `sudo bash setup-all.sh` |
| `newmenu.sh` | **Dashboard utama** — menu interaktif gabungan semua tools | `newmenu.sh` |
| `a-reboot.sh` | Auto-reboot manager dengan penjadwalan cron | `sudo a-reboot.sh` |
| `disk.sh` | Monitoring penggunaan disk dengan progress bar visual | `disk.sh` |
| `upgrader.sh` | Update semua tools dari GitHub ke versi terbaru | `sudo upgrader.sh` |
| `service_manager.sh` | Manajemen service systemd (start/stop/restart/status) | `sudo service_manager.sh` |
| `cek_service.sh` | Cek status service spesifik (bot.py) | `cek_service.sh` |
| `editfile.sh` | Quick file editor dari terminal | `editfile.sh` |
| `root.sh` | Root access helper | `sudo root.sh` |
| `loading.sh` | Animasi loading terminal | `loading.sh` |

### 🔐 Keamanan & Enkripsi

| Script | Deskripsi | Cara Pakai |
|--------|-----------|------------|
| `openssl-encrypt.sh` | Enkripsi & dekripsi file dengan AES-256-CBC | `openssl-encrypt.sh` |
| `spam_detector.py` | SpamGuard Elite — deteksi spam 10-layer (ML scoring) | `python3 spam_detector.py` |
| `anti_spam.py` | Filter anti-spam untuk konten | `python3 anti_spam.py` |
| `nobody-spam.py` | Spam filter alternatif | `python3 nobody-spam.py` |
| `mode-hack.sh` | Mode hacking terminal (tampilan) | `mode-hack.sh` |

### 🌐 Jaringan & DNS

| Script | Deskripsi | Cara Pakai |
|--------|-----------|------------|
| `pinghost.sh` | Tes ping interaktif dengan statistik RTT | `pinghost.sh` |
| `lookup-dns.sh` | DNS Lookup tool dengan ASCII art | `lookup-dns.sh` |
| `dns-records.sh` | Cek berbagai record DNS (A, MX, TXT, NS, dll) | `dns-records.sh` |
| `m-host-to-ip.sh` | Konversi hostname/domain ke alamat IP | `m-host-to-ip.sh` |
| `m-ip-to-host.sh` | Reverse DNS — cari hostname dari IP | `m-ip-to-host.sh` |
| `host_to_ip.py` | Host-to-IP versi Python | `python3 host_to_ip.py` |
| `ip_to_host.py` | IP-to-Host versi Python | `python3 ip_to_host.py` |
| `ddns.sh` | Setup DuckDNS Dynamic DNS client | `sudo bash ddns.sh` |
| `setup_proxy_squid.sh` | Auto-setup Squid Proxy dengan autentikasi | `sudo bash setup_proxy_squid.sh` |
| `m-tailscale.sh` | Tailscale VPN Manager | `sudo m-tailscale.sh` |
| `m-zerotier.sh` | ZeroTier VPN Manager | `sudo m-zerotier.sh` |

### 🔧 DevOps & Git

| Script | Deskripsi | Cara Pakai |
|--------|-----------|------------|
| `git_manager.sh` | Git Manager — auto push, status, log, branch, stash, diff, tag | `bash git_manager.sh` |
| `custom/git_tools.sh` | Git Tools (versi alternate) | `bash custom/git_tools.sh` |
| `ssh_manager.sh` | SSH Key Manager — generate, view, delete, copy, test, multi-account | `ssh_manager.sh` |
| `m-nginx.sh` | Nginx site manager (enable/disable/create site) | `sudo m-nginx.sh` |
| `m-screen.sh` | Screen session manager untuk background process | `m-screen.sh` |
| `m-tmux.sh` | Tmux session manager — advanced terminal multiplexer | `m-tmux.sh` |

### 🕵️ OSINT & Reconnaissance

| Script | Deskripsi | Cara Pakai |
|--------|-----------|------------|
| `m-user-finder.sh` | Sherlock wrapper — cari username di 400+ platform | `m-user-finder.sh` |
| `install-sherlock.sh` | Auto-installer Sherlock OSINT tool | `bash install-sherlock.sh` |
| `sub-domain-finder.sh` | Subdomain enumeration tool | `sub-domain-finder.sh` |
| `install-domain-finder.sh` | Installer tools domain finder (Go-based) | `bash install-domain-finder.sh` |
| `m-domain.py` | Domain information gathering | `python3 m-domain.py` |
| `m-tracker.py` | Tracker tool untuk monitoring | `python3 m-tracker.py` |

### 🧪 Testing & Utilities

| Script | Deskripsi | Cara Pakai |
|--------|-----------|------------|
| `m-monitor.sh` | Install & jalankan htop/gotop/btop | `m-monitor.sh` |
| `m-setting.sh` | Menu pengaturan VPS | `m-setting.sh` |
| `m-spam-post.sh` | Spam post tool (wrapper) | `m-spam-post.sh` |
| `spam_post.py` | Spam posting engine (multi-thread) | `python3 spam_post.py` |
| `kirim_email.py` | Kirim email dari terminal | `python3 kirim_email.py` |
| `pentester_tools.py` | **Dark Phantom** — 11 tools pentesting suite | `python3 pentester_tools.py` |
| `custom/pentester.py` | Server load & stress testing (HTTP/TCP/UDP) | `python3 custom/pentester.py` |
| `ddos.py` | DDoS attack tool (DRipper) | `python3 ddos.py` |
| `m-ddos.sh` | DDoS wrapper menu | `m-ddos.sh` |

---

## 🔑 Panduan SSH & GitHub

### 1. Generate SSH Key

Cek apakah sudah punya SSH key:

```bash
ls ~/.ssh/id_ed25519.pub
```

Jika belum ada, buat baru:

```bash
ssh-keygen -t ed25519 -C "email_kamu@example.com"
```

### 2. Tambahkan ke GitHub

Tampilkan public key Anda:

```bash
cat ~/.ssh/id_ed25519.pub
```

Lalu:
1. Buka [GitHub Settings → SSH and GPG keys](https://github.com/settings/keys)
2. Klik **New SSH key**
3. Paste public key → **Save**

### 3. Test Koneksi

```bash
ssh -T git@github.com
```

Jika berhasil, akan muncul: `Hi username\! You've successfully authenticated...`

> 💡 Gunakan `ssh_manager.sh` untuk mengelola multiple SSH key dengan mudah\!

---

## 📦 Persyaratan Sistem

| Komponen | Minimum |
|----------|---------|
| **OS** | Ubuntu 20.04+ / Debian 11+ / RHEL 8+ / Arch / Alpine |
| **Bash** | 4.0+ |
| **Python** | 3.8+ |
| **Tools** | `wget`, `curl`, `git`, `sed`, `tar`, `unzip`, `gzip` |
| **Akses** | Root / sudo (untuk instalasi) |

> Semua dependensi diinstall otomatis oleh `setup-all.sh`.

---

## 📁 Struktur Proyek

```
shell-scripting/
├── setup-all.sh              # 🔧 Auto-installer utama
├── newmenu.sh                # 🏠 Dashboard menu terintegrasi
│
├── 🔐 Keamanan
│   ├── openssl-encrypt.sh    # Enkripsi/dekripsi file AES-256
│   ├── spam_detector.py      # SpamGuard Elite detection
│   ├── anti_spam.py          # Anti-spam filter
│   └── nobody-spam.py        # Spam filter alternatif
│
├── 🌐 Jaringan
│   ├── pinghost.sh           # Ping test interaktif
│   ├── lookup-dns.sh         # DNS lookup
│   ├── dns-records.sh        # DNS records checker
│   ├── m-host-to-ip.sh       # Host → IP
│   ├── m-ip-to-host.sh       # IP → Host
│   ├── ddns.sh               # DuckDNS setup
│   ├── setup_proxy_squid.sh  # Squid proxy auto-setup
│   ├── m-tailscale.sh        # Tailscale manager
│   └── m-zerotier.sh         # ZeroTier manager
│
├── 🔧 DevOps
│   ├── git_manager.sh        # Git manager
│   ├── ssh_manager.sh        # SSH key manager
│   ├── service_manager.sh    # Systemd service manager
│   ├── m-nginx.sh            # Nginx site manager
│   ├── m-screen.sh           # Screen session manager
│   └── m-tmux.sh             # Tmux session manager
│
├── 🖥️ Sistem
│   ├── a-reboot.sh           # Auto-reboot scheduler
│   ├── disk.sh               # Disk usage monitor
│   ├── upgrader.sh           # Tools updater
│   ├── cek_service.sh        # Service checker
│   ├── m-monitor.sh          # htop/gotop/btop installer
│   └── m-setting.sh          # VPS settings menu
│
├── 🕵️ OSINT
│   ├── m-user-finder.sh      # Sherlock username finder
│   ├── install-sherlock.sh   # Sherlock installer
│   ├── sub-domain-finder.sh  # Subdomain enumeration
│   ├── install-domain-finder.sh
│   ├── m-domain.py           # Domain info gathering
│   └── m-tracker.py          # Tracking tool
│
├── 🧪 Testing
│   ├── pentester_tools.py    # Dark Phantom pentest suite
│   ├── ddos.py               # DRipper DDoS tool
│   ├── m-ddos.sh             # DDoS menu wrapper
│   ├── m-spam-post.sh        # Spam post wrapper
│   ├── spam_post.py          # Spam posting engine
│   └── kirim_email.py        # Email sender
│
├── 📁 custom/
│   ├── git_tools.sh          # Git tools alternate
│   └── pentester.py          # Server load/stress tester
│
├── 📄 Data
│   ├── env.example           # Contoh environment variables
│   ├── rapi.txt              # Data file
│   └── ua.txt                # User-Agent list
│
└── README.md                 # Dokumentasi ini
```

---

## ⚠️ Catatan Penting

### Izin & Etika Penggunaan

- ✅ **DIPERBOLEHKAN:** Testing pada server sendiri, server staging, lab environment
- ❌ **DILARANG:** Digunakan untuk menyerang server/infrastruktur pihak lain tanpa izin tertulis
- ⚖️ Penggunaan tools pentesting/DDoS pada target tanpa izin adalah **tindakan ilegal** dan dapat dikenai sanksi pidana

### Mode Hacking

Beberapa tools memiliki tampilan "hacker theme" (cyberpunk) yang hanya bersifat **estetika visual** dan tidak mempengaruhi fungsi. Semua tools tetap berjalan normal dengan fungsionalitas sesungguhnya.

### Kompatibilitas

- Script telah diuji pada **Ubuntu 20.04/22.04/24.04** dan **Debian 11/12**
- Dukungan untuk RHEL/CentOS/Fedora dan Arch Linux tersedia di `setup-all.sh`
- Python scripts membutuhkan Python 3.8+

---

## 🤝 Kontribusi

Kontribusi selalu diterima\! Silakan:

1. **Fork** repositori ini
2. Buat branch fitur (`git checkout -b fitur-keren`)
3. Commit perubahan (`git commit -m 'Menambah fitur keren'`)
4. Push ke branch (`git push origin fitur-keren`)
5. Buka **Pull Request**

---

## ❤️ Dukung Proyek Ini

<div align="center">

<a href="https://trakteer.id/kireevtimur/tip">
  <img src="https://img.shields.io/badge/🔥%20TRAKTEER%20•%20Support%20Me-ED1C24?style=for-the-badge&logo=buymeacoffee&logoColor=white&labelColor=C41E3A&color=ED1C24" alt="Trakteer">
</a>

<br><br>

<table>
<tr>
<td align="center" style="background: linear-gradient(135deg, #C41E3A, #8B0000); padding: 30px; border-radius: 16px;">

<img src="https://img.shields.io/badge/❤️%20BANTU%20DEVELOPER%20TETAP%20HIDUP-ED1C24?style=for-the-badge&logo=heart&logoColor=white&labelColor=C41E3A&color=ED1C24" alt="Bantu">

<br><br>

<h3 style="color: #FF6B6B;">🙏 Mohon Dukungannya, Kawan! 🙏</h3>

<p style="color: #FFD700; font-size: 16px; max-width: 600px;">
  <b>Script ini dibuat dengan ❤️, kopi ☕, dan begadang 🦉</b><br><br>
  Kalau tools ini bermanfaat buat kamu, <b>jangan lupa traktir es teh</b> 🧊🍵<br>
  biar makin semangat ngoding & bikin tools keren lainnya!<br><br>
  <i>"Seteguk es teh darimu, sejuta semangat untukku!"</i> 🥹✨<br><br>
  <b>👉 Klik tombol merah di bawah ya, gak nyampe harga gorengan! 👈</b>
</p>

<br>

<a href="https://trakteer.id/kireevtimur/tip">
  <img src="https://img.shields.io/badge/🍵%20TRAKTIR%20ES%20TEH%20SEKARANG!-FF0000?style=for-the-badge&logo=buymeacoffee&logoColor=white&labelColor=B22222&color=FF0000&scale=2" alt="Traktir Es Teh" width="380">
</a>

<br><br>

<sub style="color: #FF9999;">
  💰 Mulai dari <b>Rp 2.000</b> aja udah bikin developer senyum-senyum sendiri 😁<br>
  🔗 <a href="https://trakteer.id/kireevtimur/tip" style="color: #FF6B6B;">trakteer.id/kireevtimur/tip</a>
</sub>

</td>
</tr>
</table>

</div>

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

<p align="center">
  <sub>Made with ❤️ by <a href="https://github.com/kederjider">kederjider</a> • Terakhir diperbarui: Agustus 2024</sub>
</p>
