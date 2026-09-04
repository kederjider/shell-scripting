#!/usr/local/bin/.venv/bin/python
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════╗
║  ANALISIS HTML - PHISHING DETECTOR v2.0                              ║
║                                                                      ║
║  Program untuk menganalisis file HTML yang dicurigai phishing /      ║
║  credential harvesting.                                              ║
║                                                                      ║
║  Fitur:                                                              ║
║   1.  Analisis meta informasi (title, description, dsb.)             ║
║   2.  Deteksi form login palsu & form action ke domain eksternal     ║
║   3.  Deteksi endpoint ekfiltrasi data (AJAX POST, fetch, dll)       ║
║   4.  Deteksi URL mencurigakan (shortener, IP, port, TLD murah)      ║
║   5.  Deteksi JavaScript redirect (location.href, window.open, dll)  ║
║   6.  Deteksi iframe tersembunyi (clickjacking / silent iframe)      ║
║   7.  Deteksi obfuscation (eval, atob, base64, hex/unicode escape)   ║
║   8.  Analisis kesesuaian domain halaman vs endpoint pengirim        ║
║   9.  Analisis tautan & domain eksternal                             ║
║  10.  Deteksi teknik anti-deteksi (Cloudflare, dll)                  ║
║  11.  Perhitungan skor risiko phishing                               ║
║  12.  Generate laporan otomatis -> report_inihari_bulan_tahun.txt    ║
║                                                                      ║
║  Penggunaan:                                                         ║
║   python analisis_html.py [nama_file.html]                           ║
║   python analisis_html.py -i hasil.html -o report.txt                ║
║   python analisis_html.py -i hasil.html --no-save (hanya tampil)     ║
║                                                                      ║
║  ⚠️ HANYA UNTUK TUJUAN EDUKASI & PELAPORAN KEAMANAN SIBER            ║
╚══════════════════════════════════════════════════════════════════════╝
"""

import re
import os
import sys
import argparse
import subprocess
from html.parser import HTMLParser
from urllib.parse import urlparse
from datetime import datetime
from pathlib import Path
from collections import OrderedDict

# ============================================================
# WARNA TERMINAL
# ============================================================
RESET = "\033[0m"
MERAH = "\033[91m"
HIJAU = "\033[92m"
KUNING = "\033[93m"
BIRU = "\033[94m"
MAGENTA = "\033[95m"
CYAN = "\033[96m"
BOLD = "\033[1m"
DIM = "\033[2m"
UNDERLINE = "\033[4m"
BG_MERAH = "\033[41m"
BG_KUNING = "\033[43m"
BG_HIJAU = "\033[42m"
BG_BIRU = "\033[44m"

# Ikon kategori temuan
IKON = {
    "Form":          "📋",
    "Anti-Deteksi":  "🛡️",
    "Ekfiltrasi":    "📤",
    "Obfuscation":   "🔮",
    "Brand":         "🏷️",
    "Lure":          "🎣",
    "PII":           "📇",
    "Domain":        "🌐",
    "Redirect":      "🔀",
    "Iframe":        "🖼️",
    "URL":           "🔗",
    "Meta":          "⚡",
}

# Ikon tingkat risiko
IKON_RISIKO = {
    "SANGAT BERBAHAYA": "🔴",
    "BERBAHAYA":        "🟠",
    "MENCURIGAKAN":     "🟡",
    "AMAN":             "🟢",
}

BANNER = f"""
{BOLD}{CYAN}  ╔══════════════════════════════════════════════════════════════╗
  ║  {MERAH}██████╗ ██╗  ██╗██╗███████╗██╗  ██╗██╗███╗   ██╗ ██████╗    {CYAN}║
  ║  {MERAH}██╔══██╗██║  ██║██║██╔════╝██║  ██║██║████╗  ██║██╔════╝    {CYAN}║
  ║  {MERAH}██████╔╝███████║██║███████╗███████║██║██╔██╗ ██║██║  ███╗   {CYAN}║
  ║  {MERAH}██╔═══╝ ██╔══██║██║╚════██║██╔══██║██║██║╚██╗██║██║   ██║   {CYAN}║
  ║  {MERAH}██║     ██║  ██║██║███████║██║  ██║██║██║ ╚████║╚██████╔╝   {CYAN}║
  ║  {MERAH}╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝    {CYAN}║
  ╠══════════════════════════════════════════════════════════════╣
  ║  {BOLD}{KUNING}🔍 PHISHING DETECTOR v2.0{RESET}{CYAN}                                   ║
  ║  {DIM}Mendeteksi halaman phishing & credential harvesting{RESET}{CYAN}         ║
  ╚══════════════════════════════════════════════════════════════╝{RESET}
"""

# ============================================================
# POLA / REGEX PENTING
# ============================================================
URL_RE = re.compile(
    r"https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+", re.IGNORECASE)

DOMAIN_RE = re.compile(
    r"(?:https?://)?(?:[a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(?::\d+)?"
    r"(?:/[^\s\"'<>]*)?", re.IGNORECASE)

# Kata kunci endpoint ekfiltrasi data
ENDPOINT_KEYWORDS = [
    "datafinal.php", "data.php", "save.php", "login.php", "send.php",
    "log.php", "steal", "grab", "harvest", "credential", "collect",
    "submit.php", "insert.php", "store.php", "api.php", "k.php",
]

# Kata kunci JavaScript berbahaya / mencurigakan
JS_SUSPICIOUS = [
    "eval(", "atob(", "base64", "btoa(", "fromCharCode",
    "document.write", "innerHTML", "obfusc", "unescape(",
]

# Kata kunci teknik anti-deteksi
ANTI_DETECT = [
    "cloudflare", "cf$cv", "challenge-platform", "turnstile",
    "hcaptcha", "recaptcha", "sang_pengkhianat", "one-time-code",
    "autocomplete=\"false\"", "autocomplete='false'",
]

# Nama platform yang sering dijadikan target phishing
TARGET_BRANDS = [
    "mobile legends", "mlbb", "moonton", "google", "facebook",
    "instagram", "whatsapp", "netflix", "paypal", "shopee",
    "tokopedia", "garena", "free fire", "codashop", "steam",
    "riot", "epic games", "apple id", "microsoft", "outlook",
    "gmail", "yahoo", "telegram", "discord", "twitter",
    "bca", "bni", "bri", "mandiri", "dana", "ovo", "gopay",
]

# Kata kunci umpan (lure) yang sering dipakai phishing
LURE_KEYWORDS = [
    "reward", "exclusive", "free", "gratis", "diamond", "skin",
    "win", "menang", "hadiah", "prize", "bonus", "claim",
    "klaim", "voucher", "discount", "diskon", "gift", "kado",
    "login to continue", "verify your account", "verifikasi akun",
    "account suspended", "akun diblokir", "password expired",
    "urgent", "segera", "limited", "terbatas", "event",
]

# Kata kunci form pencuri kredensial
CRED_FIELD = [
    "email", "password", "passwd", "userpass", "login", "signin",
    "pwd", "pass", "username", "user", "card", "cvv", "pin",
    "otp", "secret", "credential",
]

# Kata kunci data pribadi tambahan (form verifikasi palsu)
PII_FIELD = [
    "phone", "tel", "telepon", "playid", "game id", "zone",
    "server", "level", "points", "id number", "nik", "ktp",
    "birth", "lahir", "address", "alamat", "codetel",
]

PHISHING_BRAND_SITE = {
    "mobile legends": "mobilelegends.com",
    "google": "accounts.google.com",
    "facebook": "facebook.com",
    "moonton": "moonton.com",
    "garena": "garena.com",
    "netflix": "netflix.com",
    "paypal": "paypal.com",
    "shopee": "shopee.co.id",
    "tokopedia": "tokopedia.com",
}

# TLD umum yang valid (untuk memfilter false positive deteksi domain)
TLD_VALID = {
    "com", "org", "net", "info", "io", "me", "dev", "app", "site",
    "online", "store", "shop", "xyz", "top", "tk", "gq", "ml", "ga",
    "cf", "id", "co.id", "biz.id", "or.id", "web.id", "ac.id", "go.id",
    "sch.id", "my.id", "co", "cc", "biz", "eu", "ru", "cn", "in",
    "jp", "kr", "sg", "my", "ph", "th", "vn", "au", "nz", "uk", "us",
    "de", "fr", "es", "it", "nl", "pl", "br", "mx", "ar", "za", "tr",
    "tv", "fm", "gg", "gg", "link", "click", "work", "live", "pro",
    "fun", "club", "life", "world", "today", "win", "loan", "date",
    "sbs", "kim", "men", "icu", "cyou", "monster", "uno", "beauty",
}

# Domain CDN/eksternal umum yang bukan indikator phishing
CDN_UMUM = {
    "cdnjs.cloudflare.com", "ajax.googleapis.com", "code.jquery.com",
    "stackpath.bootstrapcdn.com", "fonts.googleapis.com",
    "fonts.gstatic.com", "site-assets.fontawesome.com",
    "use.fontawesome.com", "www.googletagmanager.com",
    "www.google-analytics.com", "cdn.jsdelivr.net", "unpkg.com",
    "cdn.akamai.net", "akmweb.youngjoygame.com",
}

# TLD murah/berisiko tinggi yang sering dipakai phishing
TLD_RISIKO = {"xyz", "top", "tk", "gq", "ml", "ga", "cf", "sbs",
              "kim", "icu", "cyou", "men", "loan", "date", "click",
              "work", "monster", "uno", "link", "biz.id"}

# Layanan URL shortener yang sering disalahgunakan phishing
URL_SHORTENER = {
    "bit.ly", "tinyurl.com", "t.co", "goo.gl", "is.gd", "buff.ly",
    "rebrand.ly", "shorturl.at", "cutt.ly", "rb.gy", "s.id",
    "tiny.cc", "ow.ly", "shorte.st", "adf.ly", "bc.vc", "t.ly",
}

# Kata kunci redirect via JavaScript
REDIRECT_PATTERN = [
    r"location\.href\s*=",
    r"location\.replace\s*\(",
    r"location\.assign\s*\(",
    r"window\.location\s*=",
    r"window\.open\s*\(",
    r"document\.location\s*=",
    r"top\.location\s*=",
    r"self\.location\s*=",
    r"parent\.location\s*=",
    r"location\.search\s*=",
    r"document\.cookie\s*=",
]

# Pola obfuscation JavaScript
OBFUSCATION_PATTERN = [
    (r"eval\s*\(", "eval() - eksekusi kode dinamis"),
    (r"atob\s*\(", "atob() - decode base64"),
    (r"btoa\s*\(", "btoa() - encode base64"),
    (r"fromCharCode", "String.fromCharCode - karakter terenkode"),
    (r"\\x[0-9a-fA-F]{2}", "hex escape (\\x..) - string terenkode"),
    (r"\\u[0-9a-fA-F]{4}", "unicode escape (\\u....) - string terenkode"),
    (r"unescape\s*\(", "unescape() - decode string"),
    (r"String\.fromCharCode", "String.fromCharCode - karakter terenkode"),
    (r"[A-Za-z0-9+/]{100,}={0,2}", "string base64 panjang (>=100 char)"),
]

# Pola iframe tersembunyi / mencurigakan
IFRAME_SUSPICIOUS = [
    r"visibility\s*:\s*hidden",
    r"display\s*:\s*none",
    r"width\s*:\s*[0-9]{1,2}px",
    r"height\s*:\s*[0-9]{1,2}px",
    r"opacity\s*:\s*0",
    r"position\s*:\s*absolute",
    r"position\s*:\s*fixed",
    r"left\s*:\s*-?[0-9]+px",
    r"top\s*:\s*-?[0-9]+px",
    r"z-index\s*:\s*-?[0-9]+",
    r"frameBorder\s*=\s*[\"']0[\"']",
    r"scrolling\s*=\s*[\"']no[\"']",
]

# Protokol / scheme berbahaya
SCHEME_BAHAYA = ["javascript:", "data:", "vbscript:"]

# Form action yang mencurigakan (selain javascript:void(0))
FORM_ACTION_SUSPICIOUS = [
    "javascript:", "data:", "vbscript:", "#", "?",
]


def cprint(warna, teks):
    """Cetak teks berwarna ke terminal."""
    print(f"{warna}{teks}{RESET}")


def cprint_row(icon, label, value, warna_val=RESET, lebar_label=22):
    """Cetak satu baris tabel: ikon | label : value."""
    print(f"  {icon} {BOLD}{CYAN}{label:<{lebar_label}}{RESET} {DIM}│{RESET} {warna_val}{value}{RESET}")


def separator(judul, lebar=64):
    """Cetak garis pemisah modern dengan judul."""
    pad = lebar - len(judul) - 4
    kiri = pad // 2
    kanan = pad - kiri
    print()
    print(f"  {BIRU}{'─' * kiri}┤ {BOLD}{judul}{RESET} {BIRU}├{'─' * kanan}{RESET}")


def progress_bar(persen, lebar=30):
    """Buat progress bar berwarna berdasarkan persentase."""
    terisi = round(persen / 100 * lebar)
    kosong = lebar - terisi
    if persen >= 70:
        warna = MERAH
        blok = "█"
    elif persen >= 40:
        warna = KUNING
        blok = "█"
    elif persen >= 15:
        warna = CYAN
        blok = "▓"
    else:
        warna = HIJAU
        blok = "█"
    bar = f"{warna}{blok * terisi}{DIM}{'░' * kosong}{RESET}"
    return f"[{bar}] {warna}{BOLD}{persen}%{RESET}"


# ============================================================
# PARSER HTML
# ============================================================
class HtmlPhishingParser(HTMLParser):
    """Parser HTML untuk mengekstrak informasi yang relevan."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.title = ""
        self.meta = {}                 # meta name -> content
        self.forms = []                # daftar form
        self.inputs = []               # daftar input
        self.scripts = []              # konten script (potongan)
        self.links = []                # href eksternal
        self.resources = []            # css/js/img src eksternal
        self.iframes = []              # daftar iframe
        self.meta_refresh = []         # daftar meta refresh
        self.script_count = 0          # jumlah tag <script>
        self._in_title = False
        self._current_form = None

    # -- handler event ----------------------------------------
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)

        if tag == "title":
            self._in_title = True

        elif tag == "meta":
            name = attrs.get("name") or attrs.get("property") or ""
            content = attrs.get("content", "")
            if name:
                self.meta[name.lower()] = content
            # Meta refresh (redirect otomatis) mis. <meta http-equiv="refresh" content="0;url=...">
            if attrs.get("http-equiv", "").lower() == "refresh" and content:
                self.meta_refresh.append(content)

        elif tag == "iframe":
            info = {
                "src": attrs.get("src", ""),
                "width": attrs.get("width", ""),
                "height": attrs.get("height", ""),
                "style": attrs.get("style", ""),
                "frameborder": attrs.get("frameborder", ""),
                "scrolling": attrs.get("scrolling", ""),
                "hidden": attrs.get("hidden", ""),
                "class": attrs.get("class", ""),
                "id": attrs.get("id", ""),
            }
            self.iframes.append(info)

        elif tag == "form":
            self._current_form = {
                "action": attrs.get("action", ""),
                "method": attrs.get("method", "").upper(),
                "id": attrs.get("id", ""),
                "name": attrs.get("name", ""),
                "autocomplete": attrs.get("autocomplete", ""),
            }
            self.forms.append(self._current_form)

        elif tag == "input":
            info = {
                "type": attrs.get("type", "text"),
                "name": attrs.get("name", ""),
                "id": attrs.get("id", ""),
                "placeholder": attrs.get("placeholder", ""),
                "autocomplete": attrs.get("autocomplete", ""),
                "value": attrs.get("value", "")[:80],
                "form": self._current_form,
            }
            self.inputs.append(info)

        elif tag == "script":
            self.script_count += 1
            src = attrs.get("src", "")
            if src:
                self.resources.append(src)

        elif tag == "a":
            href = attrs.get("href", "")
            if href:
                self.links.append(href)

        elif tag in ("link", "img", "iframe", "video", "source"):
            src = attrs.get("href") or attrs.get("src") or ""
            if src:
                self.resources.append(src)

    def handle_endtag(self, tag):
        if tag == "title":
            self._in_title = False
        elif tag == "form":
            self._current_form = None

    def handle_data(self, data):
        if self._in_title:
            self.title += data.strip()


# ============================================================
# ANALISIS UTAMA
# ============================================================
class PhishingAnalyzer:
    """Menganalisis file HTML dan menghitung skor risiko phishing."""

    def __init__(self, file_path, html_text=None):
        self.file_path = Path(file_path)
        self.html = html_text or self._read_file()
        self.parser = HtmlPhishingParser()
        self.parser.feed(self.html)

        # Hasil analisis (diisi saat analisis)
        self.hasil = OrderedDict()
        self.temuan = []          # list temuan (label, detail, bobot)
        self.skor = 0
        self.maks_skor = 0

    # --------------------------------------------------------
    def _read_file(self):
        """Baca file HTML dengan deteksi encoding otomatis."""
        raw = self.file_path.read_bytes()
        for enc in ("utf-8", "utf-8-sig", "latin-1"):
            try:
                return raw.decode(enc)
            except UnicodeDecodeError:
                continue
        return raw.decode("utf-8", errors="replace")

    # --------------------------------------------------------
    def _tambah(self, kategori, detail, bobot):
        """Catat temuan (maks skor dibatasi 10 per item)."""
        bobot = min(bobot, 10)
        self.temuan.append((kategori, detail, bobot))
        self.skor += bobot
        self.maks_skor += 10

    # --------------------------------------------------------
    def analisis(self):
        """Jalankan seluruh rangkaian analisis."""
        self._analisis_meta()
        self._analisis_forms()
        self._analisis_inputs()
        self._analisis_scripts()
        self._analisis_redirect()
        self._analisis_iframes()
        self._analisis_url()
        self._analisis_obfuscation()
        self._analisis_links_resources()
        self._analisis_domain_consistency()
        self._analisis_anti_deteksi()
        self._analisis_brand_lure()
        self._analisis_domain()
        self._ringkas()
        return self

    # --------------------------------------------------------
    def _analisis_meta(self):
        h = self.parser
        if h.title:
            self.hasil["Judul Halaman"] = h.title.strip()
        if "og:description" in h.meta:
            self.hasil["Deskripsi (OG)"] = h.meta["og:description"]
        if "description" in h.meta:
            self.hasil.setdefault("Deskripsi (Meta)", h.meta["description"])
        if "og:image" in h.meta:
            self.hasil["OG Image"] = h.meta["og:image"]
        self.hasil["Jumlah Form"] = str(len(h.forms))
        self.hasil["Jumlah Input"] = str(len(h.inputs))
        self.hasil["Jumlah Script"] = str(h.script_count)
        self.hasil["Jumlah Link Eksternal"] = str(len(h.links))

    # --------------------------------------------------------
    def _analisis_forms(self):
        if not self.parser.forms:
            self.hasil["Form Login"] = "Tidak ditemukan"
            return

        form_list = []
        for f in self.parser.forms:
            info = f"{f['id'] or '(tanpa id)'} | action={f['action'] or '(kosong)'} | method={f['method'] or '(kosong)'}"

            # Form action javascript:void(0) -> indikasi JS handling (umum di phishing kit)
            if "javascript" in f["action"].lower():
                self._tambah(
                    "Form", f"Form '{f['id']}' memakai action javascript:void(0) "
                    f"(data dikirim via JavaScript, bukan action form)", 7)
            elif f["action"] and f["action"].lower().endswith((".php", ".asp", ".aspx", ".cgi")):
                self._tambah(
                    "Form", f"Form '{f['id']}' mengirim ke file server dinamis: "
                    f"{f['action']}", 5)
            elif f["action"] and any(f["action"].lower().startswith(s) for s in SCHEME_BAHAYA):
                self._tambah(
                    "Form", f"Form '{f['id']}' memakai action berbahaya: "
                    f"{f['action'][:60]}", 6)

            # Form action mengarah ke domain EKSTERNAL (beda dari halaman)
            if f["action"] and f["action"].startswith(("http://", "https://", "//")):
                domain_form = self._domain_dari_url(f["action"])
                if domain_form and domain_form not in CDN_UMUM:
                    # domain halaman (jika diketahui dari file phishing.txt/konteks)
                    self._tambah(
                        "Form", f"Form '{f['id']}' mengirim data ke domain EKSTERNAL: "
                        f"{domain_form} (action={f['action'][:70]})", 9)

            if "off" in f.get("autocomplete", "").lower():
                self._tambah(
                    "Anti-Deteksi", f"Form '{f['id']}' memakai autocomplete=off "
                    f"(mencegah password manager)", 3)

            form_list.append(info)

        self.hasil["Daftar Form"] = "\n".join(f"  - {x}" for x in form_list)

    # --------------------------------------------------------
    def _analisis_inputs(self):
        if not self.parser.inputs:
            return

        cred = []
        pii = []
        hidden = []
        paswd = 0

        for i in self.parser.inputs:
            nama = (i["name"] or i["id"] or i["placeholder"]).lower()

            if i["type"] == "password":
                paswd += 1
                if any(k in nama for k in ("pass", "pwd")):
                    cred.append(nama)

            if i["type"] == "hidden":
                hidden.append(nama)

            if any(k in nama for k in CRED_FIELD):
                cred.append(nama)
            if any(k in nama for k in PII_FIELD):
                pii.append(nama)

            # autocomplete one-time-code -> trik anti password manager
            if "one-time-code" in i.get("autocomplete", "").lower():
                self._tambah(
                    "Anti-Deteksi", f"Input '{nama}' memakai autocomplete=one-time-code "
                    f"(trik mengelabui password manager)", 4)
                i["_counted_otc"] = True

        # Hapus duplikat, pertahankan urutan
        cred = list(dict.fromkeys(cred))
        pii = list(dict.fromkeys(pii))
        hidden = list(dict.fromkeys(hidden))

        self.hasil["Field Kredensial"] = ", ".join(
            cred) if cred else "Tidak ada"
        self.hasil["Field Data Pribadi"] = ", ".join(
            pii) if pii else "Tidak ada"
        self.hasil["Hidden Fields"] = ", ".join(
            hidden) if hidden else "Tidak ada"
        self.hasil["Jumlah Input Password"] = str(paswd)

        if paswd > 0:
            self._tambah("Form", f"Ditemukan {paswd} input password "
                         f"(indikasi form login/pencurian kredensial)", 6)
        if len(cred) >= 2 and paswd > 0:
            self._tambah("Form", "Terdapat field email + password dalam satu halaman "
                         "(form credential harvesting)", 6)
        if hidden:
            self._tambah("Form", f"Terdapat {len(hidden)} hidden field "
                         f"(data disembunyikan untuk dikirim diam-diam)", 3)
        if pii:
            self._tambah("PII", f"Form meminta data pribadi: {', '.join(pii[:6])} "
                         f"(koleksi data tambahan)", 5)

    # --------------------------------------------------------
    def _analisis_scripts(self):
        """Analisis blok <script> untuk endpoint ekfiltrasi."""
        srcs = [s for s in self.parser.resources
                if s.lower().endswith((".js")) or "script" in s.lower()]

        # Ambil potongan konten script (bagian yang menarik)
        script_bodies = re.findall(
            r"<script[^>]*>(.*?)</script>", self.html, re.DOTALL | re.IGNORECASE)

        # 1) Cari endpoint ekfiltrasi
        endpoints = set()
        for body in script_bodies:
            # $.ajax({... url: "..."})
            for m in re.finditer(r"url\s*:\s*[\"']([^\"']+)[\"']", body):
                endpoints.add(m.group(1))
            # fetch("...")
            for m in re.finditer(r"fetch\s*\(\s*[\"']([^\"']+)[\"']", body):
                endpoints.add(m.group(1))
            # XMLHttpRequest open("POST", "...")
            for m in re.finditer(r"open\s*\(\s*[\"']POST[\"']\s*,\s*[\"']([^\"']+)[\"']", body):
                endpoints.add(m.group(1))
            # action = "..."
            for m in re.finditer(r"action\s*=\s*[\"']([^\"']+)[\"']", body):
                endpoints.add(m.group(1))

        # 2) Deteksi teknik kirim data
        teknik = []
        for body in script_bodies:
            for kw in (".ajax(", "XMLHttpRequest", "fetch(", "FormData",
                       ".serialize()", ".submit()", "send("):
                if kw in body:
                    teknik.append(kw.strip("()."))

        # 3) Kata kunci mencurigakan (eval, atob, dll)
        suspicious_js = [k for k in JS_SUSPICIOUS
                         if any(k in b for b in script_bodies)]

        # Filter endpoint: file server dinamis / keyword
        mencurigakan = [
            e for e in endpoints
            if e.lower().endswith((".php", ".asp", ".aspx", ".cgi"))
            or any(k in e.lower() for k in ENDPOINT_KEYWORDS)
        ]

        # Simpan hasil
        if endpoints:
            self.hasil["Endpoint URL (dari JS)"] = ", ".join(sorted(endpoints))
        if teknik:
            self.hasil["Teknik Kirim Data"] = ", ".join(sorted(set(teknik)))
        if suspicious_js:
            self.hasil["JS Mencurigakan"] = ", ".join(suspicious_js)
        if srcs:
            self.hasil["Script Eksternal"] = ", ".join(srcs[:5])

        # Skor
        if mencurigakan:
            for e in mencurigakan:
                self._tambah(
                    "Ekfiltrasi", f"Endpoint ekfiltrasi data ditemukan: '{e}' "
                    f"(data korban dikirim ke sini)", 10)
        if "serialize" in self.html.lower():
            self._tambah(
                "Ekfiltrasi", "Kode memakai .serialize() untuk mengirim seluruh "
                "field form sekaligus", 7)
        if any(k in self.html.lower() for k in (".ajax(", "xmlhttprequest", "fetch(")):
            self._tambah(
                "Ekfiltrasi", "Ditemukan request asinkron (AJAX/fetch/XMLHttpRequest) "
                "yang memungkinkan kirim data tanpa navigasi", 5)
        if suspicious_js:
            self._tambah(
                "Obfuscation", f"Kode JavaScript mencurigakan: {', '.join(suspicious_js)} "
                f"(kemungkinan penyembunyian kode)", 5)

    # --------------------------------------------------------
    @staticmethod
    def _domain_dari_url(url):
        """Ekstrak domain/netloc dari sebuah URL (tanpa validasi ketat)."""
        u = url.strip()
        if u.startswith("//"):
            u = "https:" + u
        if not u.startswith(("http://", "https://")):
            return ""
        try:
            return urlparse(u).netloc.lower().split(":")[0]
        except Exception:
            return ""

    # --------------------------------------------------------
    def _analisis_redirect(self):
        """Deteksi redirect via JavaScript / meta refresh / form javascript:."""
        script_bodies = re.findall(
            r"<script[^>]*>(.*?)</script>", self.html, re.DOTALL | re.IGNORECASE)
        semua_js = "\n".join(script_bodies)

        redirects = []
        # location.href = "...", window.location = "...", window.open("...")
        for pola in REDIRECT_PATTERN:
            for m in re.finditer(pola + r"[\s]*[\"']?([^\"';]+)[\"']?", semua_js):
                target = m.group(1).strip()
                if target and len(target) < 120:
                    redirects.append((pola.strip("\\"), target))

        # Meta refresh
        for mr in self.parser.meta_refresh:
            m = re.search(r"url\s*=\s*([^;\s'\"]+)", mr, re.IGNORECASE)
            if m:
                redirects.append(("meta refresh", m.group(1)))

        if redirects:
            # Ringkas & buang duplikat
            unik = list(dict.fromkeys(redirects))[:8]
            self.hasil["Redirect Ditemukan"] = "; ".join(
                f"{metode} -> {target}" for metode, target in unik)
            for metode, target in unik:
                bobot = 7 if metode != "meta refresh" else 5
                self._tambah(
                    "Redirect", f"Redirect via {metode} menuju: {target[:90]} "
                    f"(korban dialihkan ke halaman lain)", bobot)

        # Redirect ke domain EKSTERNAL (indikator kuat phishing)
        domain_halaman = self._ekstrak_domain()
        for metode, target in redirects:
            d_target = self._domain_dari_url(target)
            if d_target and d_target not in CDN_UMUM and d_target not in domain_halaman:
                self._tambah(
                    "Redirect", f"Redirect mengarah ke domain EKSTERNAL: "
                    f"{d_target} (via {metode})", 9)
                break  # cukup satu temuan

    # --------------------------------------------------------
    def _analisis_iframes(self):
        """Deteksi iframe tersembunyi / clickjacking / iframe mencurigakan."""
        iframes = self.parser.iframes

        if iframes:
            info_list = []
            for f in iframes:
                info = f"src={f['src'][:60] or '(kosong)'} | "
                info += f"w={f['width'] or '-'} h={f['height'] or '-'}"
                if f["style"]:
                    info += f" | style={f['style'][:40]}"
                info_list.append(info)
            self.hasil["Iframe Ditemukan"] = "\n".join(
                f"  - {x}" for x in info_list)

        # 1) Iframe dinamis dibuat via JavaScript (createElement/insertAdjacentHTML)
        script_bodies = re.findall(
            r"<script[^>]*>(.*?)</script>", self.html, re.DOTALL | re.IGNORECASE)
        semua_js = "\n".join(script_bodies)
        if re.search(r"createElement\s*\(\s*[\"']iframe[\"']", semua_js,
                     re.IGNORECASE) or "insertAdjacentHTML" in semua_js and "iframe" in semua_js.lower():
            self._tambah(
                "Iframe", "Iframe dibuat secara DINAMIS via JavaScript "
                "(createElement/insertAdjacentHTML) - pola umum pencurian data", 7)

        # 2) Iframe yang memuat domain eksternal
        domain_halaman = self._ekstrak_domain()
        for f in iframes:
            d = self._domain_dari_url(f["src"])
            if d and d not in CDN_UMUM and d not in domain_halaman:
                self._tambah(
                    "Iframe", f"Iframe memuat domain EKSTERNAL: {d} "
                    f"(berpotensi memuat konten dari pihak lain)", 7)

        # 3) Iframe tersembunyi (clickjacking / silent loading)
        for f in iframes:
            gaya = f"{f['style']} {f['class']} {f['id']} {f['width']} {f['height']}".lower(
            )
            if any(re.search(p, gaya) for p in IFRAME_SUSPICIOUS):
                self._tambah(
                    "Iframe", f"Iframe TERSEMBUNYI: src={f['src'][:60] or '(kosong)'} "
                    f"style={f['style'][:50]} (clickjacking/silent iframe)", 8)
                break

        # 4) Meta refresh ke iframe/objek
        if self.parser.meta_refresh:
            self._tambah(
                "Redirect", f"Ditemukan {len(self.parser.meta_refresh)} meta refresh "
                f"(redirect otomatis): {self.parser.meta_refresh[0][:80]}", 5)

    # --------------------------------------------------------
    def _analisis_url(self):
        """Analisis URL mencurigakan: shortener, IP, port, TLD murah, scheme."""
        # Kumpulkan semua URL (link, resource, iframe, action form)
        all_urls = list(self.parser.links)
        all_urls += self.parser.resources
        all_urls += [f["src"] for f in self.parser.iframes]
        all_urls += [f["action"] for f in self.parser.forms]

        # Regex URL dalam JavaScript & seluruh teks
        script_bodies = re.findall(
            r"<script[^>]*>(.*?)</script>", self.html, re.DOTALL | re.IGNORECASE)
        semua_js = "\n".join(script_bodies)

        url_set = set()
        for u in all_urls:
            if u.startswith(("http://", "https://")):
                url_set.add(u)
        for m in URL_RE.finditer(self.html):
            url_set.add(m.group(0).strip(".,;\"'()[]"))

        # -- 1. URL Shortener
        for u in sorted(url_set):
            d = self._domain_dari_url(u)
            if d and any(s in d for s in URL_SHORTENER):
                self._tambah(
                    "URL", f"URL shortener terdeteksi: {u[:90]} "
                    f"(menyembunyikan tujuan asli)", 6)

        # -- 2. IP langsung / domain berbentuk IP
        for u in sorted(url_set):
            d = self._domain_dari_url(u)
            if d and re.fullmatch(r"\d{1,3}(\.\d{1,3}){3}(:\d+)?", d.split(":")[0]):
                self._tambah(
                    "URL", f"URL memakai IP LANGSUNG (bukan domain): {u[:90]} "
                    f"(menghindari deteksi nama domain)", 8)

        # -- 3. TLD murah/berisiko pada URL eksternal
        for u in sorted(url_set):
            d = self._domain_dari_url(u)
            if d and d not in CDN_UMUM:
                tld = d.rsplit(".", 2)[-1]
                if tld in TLD_RISIKO:
                    self._tambah(
                        "URL", f"URL memakai TLD berisiko tinggi '{tld}': {u[:90]} "
                        f"(TLD sering dipakai phishing)", 4)

        # -- 4. Scheme berbahaya (javascript:, data:)
        for u in sorted(url_set):
            if u.lower().startswith(("javascript:", "vbscript:", "data:text/html")):
                self._tambah(
                    "URL", f"URL memakai scheme berbahaya: {u[:90]} "
                    f"(javascript:/data:/vbscript:)", 7)

        # -- 5. Port non-standar pada URL
        for u in sorted(url_set):
            parsed = urlparse(u)
            if parsed.port and parsed.port not in (80, 443):
                self._tambah(
                    "URL", f"URL memakai port non-standar: {u[:90]} "
                    f"(port {parsed.port} jarang dipakai situs resmi)", 5)

    # --------------------------------------------------------
    def _analisis_obfuscation(self):
        """Deteksi obfuscation: eval, atob, base64, hex/unicode escape."""
        script_bodies = re.findall(
            r"<script[^>]*>(.*?)</script>", self.html, re.DOTALL | re.IGNORECASE)
        semua_js = "\n".join(script_bodies)
        if not semua_js.strip():
            return

        # Cek setiap pola
        tampil = []
        for pola, label in OBFUSCATION_PATTERN:
            # Untuk base64 panjang, jangan match blok script utuh
            if "base64" in label:
                continue
            if re.search(pola, semua_js):
                tampil.append(label)

        # Base64 panjang: string > 100 char base64 (tapi bukan dari kode biasa)
        for m in re.finditer(r"[\"']([A-Za-z0-9+/]{100,}={0,2})[\"']", semua_js):
            panjang = len(m.group(1))
            if panjang >= 100:
                tampil.append(f"string base64 panjang ({panjang} char)")
                break

        # Hex escape beruntun (3+): \x61\x62\x63...
        if len(re.findall(r"\\x[0-9a-fA-F]{2}", semua_js)) >= 3:
            tampil.append("hex escape beruntun (\\x..) - string terenkode")

        # eval bersarang / eval dalam eval
        if re.search(r"eval\s*\(\s*eval\s*\(", semua_js):
            tampil.append(
                "eval BERSARANG (nested eval) - kode terenkripsi berlapis")

        if tampil:
            tampil = list(dict.fromkeys(tampil))
            self.hasil["Obfuscation Terdeteksi"] = ", ".join(tampil)
            bobot = 8 if any(
                "base64" in t or "BERSARANG" in t or "eval" in t for t in tampil) else 5
            self._tambah(
                "Obfuscation", f"Obfuscation terdeteksi: {', '.join(tampil[:6])} "
                f"(kemungkinan menyembunyikan kode jahat)", bobot)

        # Potongan kode terenkode (contoh cuplikan untuk bukti)
        potongan = []
        for m in re.finditer(r"(eval\s*\(\s*[\"'][^\"']{20,}[\"']\s*\))",
                             semua_js):
            potongan.append(m.group(1)[:100])
        for m in re.finditer(r"(atob\s*\(\s*[\"'][^\"']{20,}[\"']\s*\))",
                             semua_js):
            potongan.append(m.group(1)[:100])
        if potongan:
            self.hasil["Cuplikan Kode Terenkode"] = "\n".join(
                f"  {p}" for p in list(dict.fromkeys(potongan))[:3])

    # --------------------------------------------------------
    def _analisis_domain_consistency(self):
        """Bandingkan domain halaman (tampilan) vs domain endpoint pengirim."""
        domains = self._ekstrak_domain()

        # Kumpulkan semua endpoint kirim data
        endpoints = set()
        script_bodies = re.findall(
            r"<script[^>]*>(.*?)</script>", self.html, re.DOTALL | re.IGNORECASE)
        for body in script_bodies:
            for m in re.finditer(r"url\s*:\s*[\"']([^\"']+)[\"']", body):
                endpoints.add(m.group(1))
            for m in re.finditer(r"fetch\s*\(\s*[\"']([^\"']+)[\"']", body):
                endpoints.add(m.group(1))
        # action form
        for f in self.parser.forms:
            if f["action"]:
                endpoints.add(f["action"])

        # Domain halaman: asumsi domain pertama yang bukan CDN = domain halaman
        domain_halaman = set(domains) - CDN_UMUM

        # Cari endpoint yang mengirim ke domain EKSTERNAL
        for ep in sorted(endpoints):
            if not ep.startswith(("http://", "https://", "//")):
                # endpoint relatif -> domain yang sama (bukan mismatch)
                continue
            d_ep = self._domain_dari_url(ep)
            if not d_ep or d_ep in CDN_UMUM:
                continue
            if domain_halaman and d_ep not in domain_halaman:
                self._tambah(
                    "Domain", f"MISMATCH DOMAIN: halaman menampilkan domain "
                    f"{', '.join(sorted(domain_halaman)[:2])} tetapi data dikirim "
                    f"ke domain LAIN: {d_ep} (via endpoint {ep[:70]})", 10)

        # Bandingkan dengan brand yang diklaim (mis. mobilelegends.com)
        for brand, resmi in PHISHING_BRAND_SITE.items():
            if brand in self.html.lower():
                if resmi not in self.html.lower() and resmi not in domains:
                    pass  # sudah dihitung di _analisis_links_resources

    # --------------------------------------------------------
    def _ekstrak_domain(self):
        """Ekstrak domain valid dari seluruh isi file (tanpa false positive)."""
        domains = set()
        # Dari link & resource parser
        all_urls = self.parser.links + self.parser.resources
        for u in all_urls:
            if u.startswith(("http://", "https://")):
                d = urlparse(u).netloc.lower()
            elif u.startswith("//"):
                d = (u.split("/")[2].lower() if len(u.split("/")) > 2 else "")
            else:
                continue
            if self._domain_valid(d):
                domains.add(d)

        # Dari seluruh teks file (regex ketat)
        for m in DOMAIN_RE.finditer(self.html):
            u = m.group(0).strip(".,;\"'()[]")
            if u.startswith(("http://", "https://")):
                d = urlparse(u).netloc.lower()
            else:
                d = u.split("/")[0].lower()
            if self._domain_valid(d):
                domains.add(d)

        # Buang domain CDN umum
        domains = {d for d in domains if d not in CDN_UMUM}
        # Buang domain yang cuma punya satu label tanpa titik
        domains = {d for d in domains if "." in d and len(d) > 4}
        return domains

    @staticmethod
    def _domain_valid(domain):
        """Validasi apakah string benar-benar domain (bukan kode JS/JSX, dll)."""
        if not domain or len(domain) > 100:
            return False
        # Harus punya minimal 1 titik, huruf/angka/titik/- saja
        if not re.fullmatch(r"[a-z0-9\-]+(\.[a-z0-9\-]+)+", domain):
            return False
        # Label JS/CSS umum yang tidak pernah jadi label domain sungguhan
        label_js = {
            "style", "src", "top", "left", "right", "width", "height",
            "value", "length", "inner", "outer", "text", "play", "show",
            "hide", "open", "close", "click", "focus", "blur", "append",
            "class", "name", "type", "data", "html", "doc", "window",
            "document", "body", "head", "content", "current", "target",
            "index", "key", "node", "file", "code", "site", "title",
            "css", "js", "json", "url", "href", "path", "send", "log",
            "page", "home", "main", "start", "end", "stop", "get",
            "set", "add", "remove", "push", "pop", "map", "join",
            "split", "replace", "char", "codeat", "from", "to", "in",
            "of", "and", "or", "not", "is", "has", "with", "for",
        }
        labels = domain.split(".")
        if any(lb in label_js for lb in labels):
            return False
        # Semua label harus valid (tidak mulai/akhir dengan tanda hubung)
        for label in labels:
            if len(label) == 0 or label.startswith("-") or label.endswith("-"):
                return False
            if not re.fullmatch(r"[a-z0-9\-]+", label):
                return False
        # TLD harus berupa ekstensi yang dikenal
        tld = domain.rsplit(".", 2)[-1]
        if tld in ("co", "id", "my", "us", "uk"):
            tld2 = ".".join(domain.split(".")[-2:])
            return tld2 in TLD_VALID or tld in TLD_VALID
        return tld in TLD_VALID

    # --------------------------------------------------------
    def _analisis_links_resources(self):
        """Kumpulkan domain eksternal dari link & resource."""
        domains = self._ekstrak_domain()
        # Hapus domain CDN umum
        domains = {d for d in domains if d not in CDN_UMUM}

        if domains:
            self.hasil["Domain Eksternal"] = ", ".join(sorted(domains))

        # Bandingkan dengan situs resmi brand target
        for brand, resmi in PHISHING_BRAND_SITE.items():
            if brand in self.html.lower():
                if resmi not in self.html.lower():
                    self._tambah(
                        "Brand", f"Halaman memuat identitas '{brand.title()}' "
                        f"tetapi TIDAK ada referensi ke situs resmi {resmi} "
                        f"(indikasi kloning brand)", 5)

    # --------------------------------------------------------
    def _analisis_anti_deteksi(self):
        lower = self.html.lower()
        # Kecualikan autocomplete one-time-code (sudah dihitung di _analisis_inputs)
        sudah_dihitung = any(i.get("_counted_otc") for i in self.parser.inputs)
        for kw in ANTI_DETECT:
            if kw.lower() == "one-time-code" and sudah_dihitung:
                continue  # sudah dilaporkan pada analisis input
            if kw.lower() in lower:
                label = {
                    "cloudflare": "Cloudflare challenge/script",
                    "cf$cv": "Cloudflare challenge params",
                    "challenge-platform": "Cloudflare challenge platform",
                    "turnstile": "Cloudflare Turnstile CAPTCHA",
                    "hcaptcha": "hCaptcha",
                    "recaptcha": "reCAPTCHA",
                    "sang_pengkhianat": "nama class 'sang_pengkhianat' (penanda kit phishing lokal)",
                    "one-time-code": "autocomplete=one-time-code (anti password manager)",
                }.get(kw.lower(), kw)
                self._tambah("Anti-Deteksi", f"Terindikasi: {label}", 4)

    # --------------------------------------------------------
    def _analisis_brand_lure(self):
        lower = self.html.lower()

        brands = [b for b in TARGET_BRANDS if b in lower]
        lures = [l for l in LURE_KEYWORDS if l in lower]

        if brands:
            self.hasil["Brand Target Terdeteksi"] = ", ".join(brands)
            self._tambah(
                "Brand", f"Meniru identitas brand: {', '.join(brands[:6])} "
                f"(halaman dikloning menyerupai brand asli)", 6)
        if lures:
            self.hasil["Kata Umpan (Lure)"] = ", ".join(lures[:8])
            self._tambah(
                "Lure", f"Menggunakan kata umpan: {', '.join(lures[:5])} "
                f"(taktik menarik korban)", 4)

        # Kloning halaman lengkap: banyak meta og:image dan referensi aset
        if self.parser.resources and len(self.parser.resources) > 15:
            self._tambah(
                "Anti-Deteksi", f"Halaman memuat {len(self.parser.resources)} aset eksternal "
                f"(indikasi kloning halaman resmi secara menyeluruh)", 3)

    # --------------------------------------------------------
    def _analisis_domain(self):
        """Analisis domain dari endpoint ekfiltrasi yang ditemukan."""
        domains = self._ekstrak_domain()
        # situs resmi, bukan domain penyerang
        domains.discard("mobilelegends.com")

        # Endpoint relatif (tanpa domain) dianggap bagian dari domain penyerang
        rel_endpoints = set()
        for body in re.findall(r"<script[^>]*>(.*?)</script>", self.html,
                               re.DOTALL | re.IGNORECASE):
            for m in re.finditer(r"url\s*:\s*[\"']([^\"']+)[\"']", body):
                u = m.group(1)
                if not u.startswith(("http", "//", "data:", "javascript:")):
                    rel_endpoints.add(u)

        self.hasil["Endpoint Relatif (JS)"] = (
            ", ".join(sorted(rel_endpoints)) if rel_endpoints else "Tidak ada")

        if domains:
            self.hasil["Domain Utama"] = ", ".join(sorted(domains))

        # Skor: domain asing pada endpoint ekfiltrasi
        for d in domains:
            if any(k in d for k in ("biz.id", "xyz", "top", "tk", "ml",
                                    "gq", "cf", "ga", "link", "sbs")):
                self._tambah(
                    "Domain", f"Domain endpoint '{d}' memakai TLD murah/umum dipakai "
                    f"phishing (biz.id/xyz/top/tk/gq/dll)", 4)

    # --------------------------------------------------------
    def _ringkas(self):
        """Hitung skor & tingkat risiko."""
        self.persen = round((self.skor / self.maks_skor)
                            * 100) if self.maks_skor else 0

        if self.persen >= 70:
            self.tingkat = "SANGAT BERBAHAYA (PHISHING TERKONFIRMASI)"
            self.warna = MERAH
        elif self.persen >= 40:
            self.tingkat = "BERBAHAYA (INDIKASI PHISHING KUAT)"
            self.warna = KUNING
        elif self.persen >= 15:
            self.tingkat = "MENCURIGAKAN (PERLU VERIFIKASI)"
            self.warna = CYAN
        else:
            self.tingkat = "AMAN / NORMAL"
            self.warna = HIJAU

        self.hasil["Skor Risiko"] = f"{self.skor}/{self.maks_skor} ({self.persen}%)"
        self.hasil["Tingkat Risiko"] = self.tingkat


# ============================================================
# NAMA FILE LAPORAN (report_hari_bulan_tahun)
# ============================================================
BULAN_ID = {
    1: "januari", 2: "februari", 3: "maret", 4: "april", 5: "mei",
    6: "juni", 7: "juli", 8: "agustus", 9: "september", 10: "oktober",
    11: "november", 12: "desember",
}


def nama_report_tanggal():
    """Nama file laporan default: report_hari_bulan_tahun.txt (mis. report_04_september_2026.txt)."""
    now = datetime.now()
    return f"report_{now.day:02d}_{BULAN_ID[now.month]}_{now.year}.txt"


# ============================================================
# PEMBUAT LAPORAN
# ============================================================
def buat_report(analyzer, out_path):
    """Generate file laporan — teks bersih & panjang penuh (tidak terpotong)."""
    # Tanggal untuk header laporan (nama bulan bahasa Indonesia)
    now = datetime.now()
    now_display = (f"{now.day:02d} {BULAN_ID[now.month]} {now.year}, "
                   f"{now.strftime('%H:%M:%S')}")
    h = analyzer.parser

    lines = []
    a = lines.append

    # ── Header ──────────────────────────────────────────────
    a("=" * 72)
    a("                  LAPORAN ANALISIS KEAMANAN FILE HTML")
    a("=" * 72)
    a(f"File Dianalisis  : {analyzer.file_path}")
    a(f"Tanggal Analisis : {now_display}")
    a(f"Hasil Analisis   : {analyzer.hasil.get('Tingkat Risiko', '-')}")
    a("=" * 72)
    a("")

    # ── 1. Ringkasan ────────────────────────────────────────
    a("1. RINGKASAN EKSEKUTIF")
    a("-" * 72)
    a(f"   Skor Risiko    : {analyzer.hasil.get('Skor Risiko', '-')}")
    a(f"   Tingkat Risiko : {analyzer.hasil.get('Tingkat Risiko', '-')}")
    a(f"   Judul Halaman  : {h.title or '(tidak ada)'}")
    if "Deskripsi (OG)" in analyzer.hasil:
        a(f"   Deskripsi (OG) : {analyzer.hasil['Deskripsi (OG)']}")
    a("")
    if analyzer.persen >= 40:
        a("   Kesimpulan awal: File ini menunjukkan karakteristik halaman PHISHING")
        a("   atau credential harvesting. Data yang dimasukkan korban berpotensi")
        a("   dikirim ke server penyerang.")
    elif analyzer.persen >= 15:
        a("   Kesimpulan awal: File ini mengandung beberapa indikator mencurigakan.")
        a("   Disarankan verifikasi manual lebih lanjut sebelum menyimpulkan.")
    else:
        a("   Kesimpulan awal: Tidak ditemukan indikator phishing yang signifikan.")
    a("")

    # ── 2. Informasi halaman ────────────────────────────────
    a("2. INFORMASI HALAMAN")
    a("-" * 72)
    for k, v in analyzer.hasil.items():
        if k.startswith(("Jumlah", "Domain Utama", "Domain Eksternal")):
            a(f"   - {k:<22}: {v}")
    a("")

    # ── 3. Form & input ─────────────────────────────────────
    a("3. FORM & INPUT")
    a("-" * 72)
    if h.forms:
        a("   Form yang ditemukan:")
        for f in h.forms:
            fid = f['id'] or '(tanpa id)'
            fact = f['action'] or '(kosong)'
            fmethod = f['method'] or '(kosong)'
            fauto = f['autocomplete'] or '(kosong)'
            a(f"   - Form ID: {fid}")
            a(f"     Action : {fact}")
            a(f"     Method : {fmethod}")
            a(f"     Autocomplete: {fauto}")
        a("")
        a("   Input field yang ditemukan:")
        a(f"   - Kredensial    : {analyzer.hasil.get('Field Kredensial', '-')}")
        a(f"   - Data Pribadi  : {analyzer.hasil.get('Field Data Pribadi', '-')}")
        a(f"   - Hidden Fields : {analyzer.hasil.get('Hidden Fields', '-')}")
        a(f"   - Input Password: {analyzer.hasil.get('Jumlah Input Password', '0')}")
    else:
        a("   Tidak ditemukan form pada halaman ini.")
    a("")

    # ── 4. Endpoint ekfiltrasi ──────────────────────────────
    a("4. ENDPOINT EKFILTRASI DATA (TERPENTING)")
    a("-" * 72)
    ep = analyzer.hasil.get("Endpoint URL (dari JS)")
    rel = analyzer.hasil.get("Endpoint Relatif (JS)")
    a(f"   - Endpoint Absolut (URL lengkap): {ep or 'Tidak ditemukan'}")
    a(f"   - Endpoint Relatif (file server) : {rel or 'Tidak ditemukan'}")
    a(f"   - Teknik Kirim Data              : {analyzer.hasil.get('Teknik Kirim Data', 'Tidak terdeteksi')}")
    a("")
    a("   Catatan: Endpoint relatif seperti datafinal.php menunjuk ke file")
    a("   di domain yang sama dengan halaman phishing (domain penyerang).")
    a("")

    # ── 5. Redirect & iframe ────────────────────────────────
    a("5. REDIRECT & IFRAME")
    a("-" * 72)
    rd = analyzer.hasil.get("Redirect Ditemukan")
    if rd:
        a(f"   - Redirect Terdeteksi: {rd}")
    else:
        a("   - Redirect Terdeteksi: Tidak ditemukan redirect via JS/meta refresh.")

    ifr = analyzer.hasil.get("Iframe Ditemukan")
    if ifr:
        a("   - Iframe Terdeteksi:")
        for line in ifr.split("\n"):
            if line.strip():
                a(f"     * {line.strip()}")
    else:
        a("   - Iframe Terdeteksi: Tidak ditemukan iframe tersembunyi.")
    a("")

    # ── 6. JavaScript & obfuscation ─────────────────────────
    a("6. JAVASCRIPT & OBFUSCATION")
    a("-" * 72)
    a(f"   - JS Mencurigakan: {analyzer.hasil.get('JS Mencurigakan', 'Tidak ditemukan')}")
    obf = analyzer.hasil.get("Obfuscation Terdeteksi")
    if obf:
        a(f"   - Obfuscation Terdeteksi: {obf}")
    a("")

    # ── 7. Anti-deteksi ─────────────────────────────────────
    a("7. TEKNIK ANTI-DETEKSI / RED FLAGS")
    a("-" * 72)
    ad = [t for (k, t, _) in analyzer.temuan if k == "Anti-Deteksi"]
    if ad:
        for i, t in enumerate(ad, 1):
            a(f"   {i}. {t}")
    else:
        a("   Tidak ditemukan teknik anti-deteksi yang jelas.")
    a("")

    # ── 8. Rincian temuan ───────────────────────────────────
    a("8. RINCIAN TEMUAN & BOBOT")
    a("-" * 72)
    if analyzer.temuan:
        a(f"   {'No':>3} | {'Bobot':^5} | {'Kategori':<14} | Detail Temuan")
        a(f"   {'-'*3}-+-{'-'*5}-+-{'-'*14}-+-{'-'*40}")
        for i, (k, d, b) in enumerate(analyzer.temuan, 1):
            ikon = IKON.get(k, "•")
            a(f"   {i:>3} |  {b:>3}  | {ikon} {k:<12} | {d}")
    else:
        a("   Tidak ada temuan mencurigakan.")
    a("")

    # ── 9. Kesimpulan ───────────────────────────────────────
    a("9. KESIMPULAN & REKOMENDASI")
    a("-" * 72)
    if analyzer.persen >= 70:
        a("   File ini TERKONFIRMASI sebagai halaman phishing/credential harvesting.")
        a("   Rekomendasi:")
        a("     1. JANGAN memasukkan data asli ke halaman ini.")
        a("     2. Laporkan domain ke penyedia hosting & registrar.")
        a("     3. Laporkan ke Google Safe Browsing & PhishTank.")
        a("     4. Laporkan ke Cloudflare Abuse (jika dilindungi Cloudflare).")
        a("     5. Jika korban: segera ganti password & aktifkan 2FA.")
    elif analyzer.persen >= 40:
        a("   File ini menunjukkan indikasi phishing yang kuat.")
        a("   Rekomendasi: verifikasi manual & waspadai sebelum mengisi data.")
    elif analyzer.persen >= 15:
        a("   File ini mencurigakan. Perlu verifikasi lebih lanjut.")
    else:
        a("   Tidak ditemukan indikator phishing yang signifikan.")
    a("")
    a("=" * 72)
    a("   Laporan ini dibuat otomatis oleh PHISHING DETECTOR v2.0")
    a("   Hanya untuk tujuan edukasi & pelaporan keamanan siber.")
    a("=" * 72)

    Path(out_path).write_text("\n".join(lines), encoding="utf-8")
    return lines


# ============================================================
# TAMPILAN TERMINAL
# ============================================================
def tampilkan_ringkasan(analyzer):
    """Tampilkan hasil analisis ke terminal — format terbuka, teks panjang TIDAK dipotong."""
    h = analyzer.parser

    # ── Header & info dasar ─────────────────────────────────
    print()
    print("=" * 60)
    print("📊 HASIL ANALISIS PHISHING")
    print("=" * 60)

    nama = analyzer.file_path.name
    ukuran = f"{analyzer.file_path.stat().st_size:,} bytes"
    print(f"📁 File      : {BOLD}{nama}{RESET} ({ukuran})")
    if h.title:
        print(f"🏷️  Judul     : {BOLD}{h.title.strip()}{RESET}")
    if "Deskripsi (OG)" in analyzer.hasil:
        print(f"📝 Deskripsi : {analyzer.hasil['Deskripsi (OG)']}")
    print("-" * 60)

    # ── Statistik ringkas ───────────────────────────────────
    stats = [
        ("📋", "Form", str(len(h.forms))),
        ("⌨️ ", "Input", str(len(h.inputs))),
        ("📜", "Script", str(h.script_count)),
        ("🔗", "Link", str(len(h.links))),
        ("🖼️ ", "Iframe", str(len(h.iframes))),
    ]
    stat_line = "  ".join(f"{i} {l}: {v}" for i, l, v in stats)
    print(f"Statistik  : {stat_line}")

    # ── Brand, lure, endpoint, kredensial ───────────────────
    if "Brand Target Terdeteksi" in analyzer.hasil:
        print(
            f"🎯 Brand      : {MERAH}{analyzer.hasil['Brand Target Terdeteksi']}{RESET}")
    if "Kata Umpan (Lure)" in analyzer.hasil:
        print(
            f"🎣 Umpan      : {KUNING}{analyzer.hasil['Kata Umpan (Lure)']}{RESET}")
    ep = analyzer.hasil.get("Endpoint URL (dari JS)")
    rel = analyzer.hasil.get("Endpoint Relatif (JS)")
    if ep:
        print(f"📤 Endpoint   : {MERAH}{BOLD}{ep}{RESET}")
    elif rel:
        print(f"📤 Endpoint   : {KUNING}{rel}{RESET}")
    cred = analyzer.hasil.get("Field Kredensial", "")
    if cred and cred != "Tidak ada":
        print(f"🔑 Kredensial : {MERAH}{cred}{RESET}")
    pii = analyzer.hasil.get("Field Data Pribadi", "")
    if pii and pii != "Tidak ada":
        print(f"📇 Data Pribadi: {KUNING}{pii}{RESET}")

    # ── Skor & tingkat risiko ───────────────────────────────
    print("-" * 60)
    ikon_r = "🔴" if analyzer.persen >= 70 else (
        "🟠" if analyzer.persen >= 40 else ("🟡" if analyzer.persen >= 15 else "🟢"))
    bar = progress_bar(analyzer.persen, 25)
    print(f"{ikon_r} SKOR RISIKO   : {bar}  ({analyzer.skor}/{analyzer.maks_skor})")
    tingkat_pendek = analyzer.tingkat.split("(")[0].strip()
    print(f"{ikon_r} Tingkat Risiko: {analyzer.warna}{BOLD}{tingkat_pendek}{RESET}")

    # ── Rincian temuan (detail penuh, tidak dipotong) ───────
    if analyzer.temuan:
        print()
        print("=" * 60)
        print("TEMUAN TERPENTING")
        print("=" * 60)
        for i, (k, d, b) in enumerate(analyzer.temuan[:15], 1):
            ikon = IKON.get(k, "•")
            warna = MERAH if b >= 7 else (KUNING if b >= 4 else HIJAU)
            print(
                f"  {i:>2}. {ikon} {BOLD}{k}{RESET}  [{warna}Bobot {b}{RESET}]")
            print(f"      {d}")
    print()


# ============================================================
# AUTO VIRTUAL ENVIRONMENT
# ============================================================
def pastikan_venv():
    """
    Pastikan environment .venv tersedia sebelum program dijalankan.
    - Jika .venv sudah ada  -> skip (program berjalan normal).
    - Jika .venv tidak ada  -> auto-create, lalu jalankan ulang program
      menggunakan interpreter .venv (auto-aktivasi virtual).
    Kembalikan True jika program perlu dijalankan ulang di dalam .venv.
    """
    skrip = Path(__file__).resolve()
    folder = skrip.parent
    venv_dir = folder / ".venv"

    if sys.prefix.startswith(str(venv_dir)):
        # Sudah berjalan di dalam .venv -> tidak perlu apa-apa
        return False

    # Windows: .venv\Scripts\python.exe | Linux/macOS: .venv/bin/python
    if os.name == "nt":
        py_venv = venv_dir / "Scripts" / "python.exe"
        marker = venv_dir / "Scripts" / "activate.bat"
    else:
        py_venv = venv_dir / "bin" / "python"
        marker = venv_dir / "bin" / "activate"

    # Cek apakah .venv benar-benar valid (punya interpreter aktif)
    venv_ok = py_venv.exists()

    if not venv_ok:
        cprint(KUNING, f"\n  ⚠️  .venv tidak ditemukan — membuat virtual environment...")
        try:
            hasil = subprocess.run(
                [sys.executable, "-m", "venv", str(venv_dir)],
                capture_output=True, text=True,
            )
            if hasil.returncode != 0:
                cprint(
                    MERAH, f"  ❌ Gagal membuat .venv: {hasil.stderr.strip()}")
                cprint(DIM, "     Lanjut dengan Python sistem.")
                print()
                return False
            cprint(HIJAU, "  ✅ .venv berhasil dibuat.")
        except Exception as e:
            cprint(MERAH, f"  ❌ Gagal membuat .venv: {e}")
            cprint(DIM, "     Lanjut dengan Python sistem.")
            print()
            return False
    else:
        cprint(HIJAU, "  ✅ .venv ditemukan.")

    # Auto-aktivasi: jalankan ulang program dengan interpreter .venv
    if sys.executable.lower() != str(py_venv).lower() or not marker.exists():
        cprint(CYAN, "  🔄 Mengaktifkan .venv & menjalankan ulang...")
        sys.stdout.flush()
        try:
            cmd = [str(py_venv), str(skrip)] + sys.argv[1:]
            hasil = subprocess.run(cmd)
            sys.exit(hasil.returncode)
        except KeyboardInterrupt:
            sys.exit(130)
        except Exception as e:
            cprint(MERAH, f"  ❌ Gagal menjalankan dengan .venv: {e}")
    return False


# ============================================================
# MAIN
# ============================================================
def main():
    parser = argparse.ArgumentParser(
        description="Analisis file HTML untuk deteksi phishing & credential harvesting.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Contoh:\n"
            "  python analisis_html.py hasil.html\n"
            "  python analisis_html.py -i hasil.html -o report.txt\n"
            "  python analisis_html.py -i hasil.html --no-save\n"
            "\n"
            "Catatan:\n"
            "  Laporan disimpan di direktori: hasil_analisis_html/\n"
            "  (dibuat otomatis bila belum ada)\n"
            "  Nama file default: report_hari_bulan_tahun.txt\n"
            "  Contoh: hasil_analisis_html/report_15_september_2026.txt\n"
        ),
    )
    parser.add_argument("file", nargs="?",
                        help="file HTML yang akan dianalisis")
    parser.add_argument("-i", "--input", dest="input_file",
                        help="file HTML yang akan dianalisis (alternatif)")
    parser.add_argument("-o", "--output", default=None,
                        help="nama file laporan output — otomatis disimpan "
                             "di dalam direktori hasil_analisis_html/ "
                             "(default: report_hari_bulan_tahun.txt, "
                             "mis. report_04_september_2026.txt)")
    parser.add_argument("--no-save", action="store_true",
                        help="hanya tampilkan hasil di terminal, tanpa menyimpan report")
    parser.add_argument("--silent", action="store_true",
                        help="tanpa banner (output ringkas)")
    parser.add_argument("--no-venv", action="store_true",
                        help="nonaktifkan auto-create/aktivasi .venv")
    args = parser.parse_args()

    # Auto pastikan .venv tersedia (kecuali --no-venv)
    if not args.no_venv:
        pastikan_venv()

    if not args.silent:
        print(BANNER)

    # Tentukan file input
    input_file = args.input_file or args.file
    if not input_file:
        cprint(MERAH, "\n  ❌ Error: file HTML belum ditentukan.")
        cprint(
            KUNING, "  Penggunaan: python analisis_html.py [nama_file.html]")
        sys.exit(1)

    path = Path(input_file)
    if not path.exists():
        cprint(MERAH, f"\n  ❌ Error: file '{input_file}' tidak ditemukan.")
        sys.exit(1)

    if not path.is_file():
        cprint(MERAH, f"\n  ❌ Error: '{input_file}' bukan file.")
        sys.exit(1)

    cprint(
        CYAN, f"\n  🔍 Menganalisis: {BOLD}{path}{RESET} {DIM}({path.stat().st_size:,} bytes){RESET}")

    # Analisis
    try:
        analyzer = PhishingAnalyzer(path).analisis()
    except Exception as e:
        cprint(MERAH, f"\n  ❌ Gagal menganalisis: {e}")
        sys.exit(1)

    # Tampilkan hasil
    tampilkan_ringkasan(analyzer)

    # Simpan report — selalu ke direktori hasil_analisis_html (dibuat bila belum ada)
    if not args.no_save:
        try:
            dir_hasil = Path("hasil_analisis_html")
            dir_hasil.mkdir(parents=True, exist_ok=True)
            if not args.output:
                # Default: nama file otomatis ber-format report_hari_bulan_tahun.txt
                args.output = nama_report_tanggal()
            # Bila -o hanya nama file (tanpa folder), tempatkan di direktori hasil
            p_out = Path(args.output)
            if not p_out.is_absolute() and str(p_out.parent) == ".":
                args.output = dir_hasil / p_out
            buat_report(analyzer, args.output)
            cprint(
                HIJAU, f"  ✅ Laporan disimpan: {BOLD}{args.output}{RESET}\n")
        except Exception as e:
            cprint(MERAH, f"  ❌ Gagal menyimpan laporan: {e}")
            sys.exit(1)
    else:
        cprint(DIM, "  (--no-save aktif: laporan tidak disimpan)\n")


if __name__ == "__main__":
    main()
