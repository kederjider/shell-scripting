#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
   ╔══════════════════════════════════════════════════════════════════╗
   ║     🛡️  SPAMGUARD PRO v1.0 — Advanced Anti-Spam Engine         ║
   ║     Multi-Layer  •  AI-Heuristic  •  Real-Time  •  Reporting   ║
   ╚══════════════════════════════════════════════════════════════════╝
   SpamGuard Pro — Anti-spam canggih dengan 7 layer deteksi spam.
   Deteksi: email, SMS, komentar, form submission, username, teks.
"""

import subprocess, sys, os, re, json, time, hashlib, math
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any
from collections import Counter, defaultdict

# ═══════════════════════════════════════════════════════════════════
# 🎨 DARK TERMINAL COLOR SYSTEM
# ═══════════════════════════════════════════════════════════════════
class Color:
    RESET   = "\033[0m"
    BOLD    = "\033[1m"
    DIM     = "\033[2m"
    ITALIC  = "\033[3m"
    UNDER   = "\033[4m"
    BLINK   = "\033[5m"
    R = "\033[0;31m"
    G = "\033[0;32m"
    Y = "\033[1;33m"
    B = "\033[0;34m"
    M = "\033[0;35m"
    C = "\033[0;36m"
    W = "\033[1;37m"
    GR = "\033[2;37m"
    BR = "\033[1;31m"
    BG = "\033[1;32m"
    BY = "\033[1;93m"
    BB = "\033[1;34m"
    BM = "\033[1;35m"
    BC = "\033[1;36m"
    BGR = "\033[41m"
    BGG = "\033[42m"
    BGY = "\033[43m"
    BGB = "\033[44m"
    BGM = "\033[45m"
    BGC = "\033[46m"
    DARK_FG  = "\033[38;2;180;180;200m"
    ACCENT   = "\033[38;2;0;255;136m"
    WARN_C   = "\033[38;2;255;165;0m"
    DANGER_C = "\033[38;2;255;50;50m"
    INFO_C   = "\033[38;2;0;200;255m"
    PURPLE   = "\033[38;2;180;100;255m"
    GOLD     = "\033[38;2;255;215;0m"
    SILVER   = "\033[38;2;192;192;192m"

OK    = f"{Color.G}✔{Color.RESET}"
FAIL  = f"{Color.R}✘{Color.RESET}"
WARN  = f"{Color.WARN_C}⚠{Color.RESET}"
INFO  = f"{Color.INFO_C}ℹ{Color.RESET}"
ARROW = f"{Color.ACCENT}➤{Color.RESET}"
BULLET= f"{Color.PURPLE}◆{Color.RESET}"
STAR  = f"{Color.GOLD}★{Color.RESET}"

# ═══════════════════════════════════════════════════════════════════
# 🧩 UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

def cls(): os.system("cls" if os.name == "nt" else "clear")

def thin_hr():
    print(f"  {Color.DIM}{'─' * 64}{Color.RESET}")

def banner():
    print(f"""
{Color.ACCENT}  ╔{'═' * 62}╗
  ║{Color.RESET}  {Color.PURPLE}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄{Color.ACCENT}  ║
  ║{Color.RESET}  {Color.BOLD}{Color.ACCENT}   🛡️  SPAMGUARD PRO v1.0{Color.RESET}                              {Color.ACCENT}  ║
  ║{Color.RESET}  {Color.DIM}   ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰{Color.ACCENT}  ║
  ║{Color.RESET}  {Color.DARK_FG}  Multi-Layer AI  •  7 Detectors  •  Real-Time  •  Report  {Color.ACCENT}  ║
  ║{Color.RESET}  {Color.PURPLE}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀{Color.ACCENT}  ║
  {Color.ACCENT}╚{'═' * 62}╝{Color.RESET}""")

def header(title: str, subtitle: str = ""):
    print(f"\n  {Color.PURPLE}┌{'─' * 62}┐{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.BOLD}{Color.ACCENT}{title}{Color.RESET}")
    if subtitle:
        print(f"  {Color.PURPLE}│{Color.RESET}  {Color.DIM}{subtitle}{Color.RESET}")
    print(f"  {Color.PURPLE}└{'─' * 62}┘{Color.RESET}")

def pause():
    input(f"\n  {Color.ACCENT}[⏎]{Color.RESET} {Color.DIM}Tekan Enter untuk kembali...{Color.RESET}")

def ok(msg):     print(f"  {OK}  {Color.G}{msg}{Color.RESET}")
def fail(msg):   print(f"  {FAIL}  {Color.DANGER_C}{msg}{Color.RESET}")
def warn(msg):   print(f"  {WARN}  {Color.WARN_C}{msg}{Color.RESET}")
def info(msg):   print(f"  {INFO}  {Color.INFO_C}{msg}{Color.RESET}")
def detail(msg): print(f"     {Color.DIM}{msg}{Color.RESET}")

def box(color: str, title: str, text: str):
    print(f"  {color}┌{'─' * 60}┐{Color.RESET}")
    print(f"  {color}│{Color.RESET}  {Color.BOLD}{Color.W}{title}{Color.RESET}")
    print(f"  {color}├{'─' * 60}┤{Color.RESET}")
    for line_text in text.split("\n"):
        print(f"  {color}│{Color.RESET}  {Color.W}{line_text}{Color.RESET}")
    print(f"  {color}└{'─' * 60}┘{Color.RESET}")

def get_timestamp() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def save_result(tool_name: str, data: str):
    dir_name = "hasil_antispam"
    os.makedirs(dir_name, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{dir_name}/{tool_name}_{timestamp}.txt"
    with open(filename, "w", encoding="utf-8") as f:
        f.write(data)
    return filename

def progress_bar(current: int, total: int, prefix: str = "", width: int = 36) -> str:
    pct = current / total if total > 0 else 0
    filled = int(width * pct)
    bar = f"{Color.ACCENT}{'█' * filled}{Color.DIM}{'░' * (width - filled)}{Color.RESET}"
    return f"  {prefix} {bar} {Color.ACCENT}{int(pct*100)}%{Color.RESET}"

# ═══════════════════════════════════════════════════════════════════
# 📦 AUTO DEPENDENCY CHECK
# ═══════════════════════════════════════════════════════════════════

def check_deps():
    import importlib
    need = []
    for lib in ["requests"]:
        try:
            importlib.import_module(lib)
        except ImportError:
            need.append(lib)
    if not need:
        return
    print(f"\n  {Color.WARN_C}[!] Installing {len(need)} package(s)...{Color.RESET}")
    for lib in need:
        print(f"  {Color.DIM}⏳ {lib}...{Color.RESET}", end=" ", flush=True)
        r = subprocess.run([sys.executable, "-m", "pip", "install", lib, "--quiet"], capture_output=True, timeout=60)
        print(f"{Color.G}✔{Color.RESET}" if r.returncode == 0 else f"{Color.R}✘{Color.RESET}")
    print()

# ═══════════════════════════════════════════════════════════════════
# 🧠 SPAM DETECTION DATABASES
# ═══════════════════════════════════════════════════════════════════

# Known spam keywords (weighted)
SPAM_KEYWORDS = {
    # URGENCY / PRESSURE
    "segera": 3, "urgent": 4, "urgently": 4, "now": 2, "sekarang": 2,
    "last chance": 5, "kesempatan terakhir": 5, "limited time": 4,
    "act now": 5, "bertindak sekarang": 5, "don't miss": 4,
    "expires": 3, "kadaluarsa": 2, "hurry": 4, "cepat": 2,
    "today only": 5, "hanya hari ini": 5, "closing": 3,
    "only hours": 5, "24 hours": 4, "24 jam": 4,

    # MONEY / FINANCIAL
    "free money": 5, "uang gratis": 5, "cash": 4, "bonus": 3,
    "earn money": 5, "dapatkan uang": 5, "income": 4, "rich": 4,
    "million": 3, "juta": 3, "billion": 3, "milyar": 3,
    "investment": 3, "investasi": 3, "profit": 4, "keuntungan": 4,
    "double your": 5, "lipat gandakan": 5, "guaranteed return": 5,
    "no risk": 5, "tanpa risiko": 5, "100% free": 4,
    "make money": 5, "fast cash": 5, "get paid": 4,
    "wire transfer": 4, "bank account": 3, "credit card": 3,
    "kartu kredit": 3, "rekening bank": 3, "paypal": 2,
    "bitcoin": 2, "crypto": 2, "nigerian": 5, "prince": 5,

    # PRIZE / WINNING
    "winner": 4, "pemenang": 4, "won": 4, "menang": 4,
    "prize": 4, "hadiah": 4, "lottery": 5, "lotre": 5,
    "congratulations": 3, "selamat": 2, "claim": 4, "klaim": 4,
    "free gift": 4, "hadiah gratis": 4, "selected": 3,
    "dipilih": 3, "exclusive": 3, "eksklusif": 3,

    # PHARMA / HEALTH
    "viagra": 5, "cialis": 5, "xanax": 5, "pharmacy": 4,
    "apotek": 3, "medicine": 3, "obat": 3, "pills": 4,
    "weight loss": 4, "turun berat": 4, "diet": 2,
    "supplement": 3, "suplemen": 3, "herbal": 2,
    "miracle cure": 5, "obat ajaib": 5, "penis": 5,

    # ADULT
    "xxx": 5, "porn": 5, "sex": 5, "nude": 5, "adult": 4,
    "singles": 3, "dating": 3, "kencan": 3, "hookup": 4,
    "hot girls": 5, "cewek panas": 5, "escort": 5,

    # SUSPICIOUS ACTIONS
    "click here": 4, "klik disini": 4, "click below": 4,
    "open link": 4, "buka link": 4, "download now": 4,
    "subscribe": 2, "berlangganan": 2, "unsubscribe": 0,
    "opt out": 0, "verify": 3, "verifikasi": 3,
    "confirm": 3, "konfirmasi": 3, "update your": 3,

    # THREATS / FEAR
    "virus detected": 5, "virus terdeteksi": 5, "hacked": 5,
    "suspended": 4, "ditangguhkan": 4, "blocked": 3,
    "warning": 3, "peringatan": 3, "security alert": 4,
    "unauthorized": 3, "suspicious activity": 4,
    "your account": 3, "akun anda": 3, "password": 2,
    "login": 2, "locked": 3, "verify identity": 4,

    # JOB / WORK SCAMS
    "work from home": 5, "kerja dari rumah": 5, "easy job": 5,
    "pekerjaan mudah": 5, "no experience": 4, "tanpa pengalaman": 4,
    "earn weekly": 5, "penghasilan mingguan": 5, "part time": 3,
    "flexible hours": 3, "be your own boss": 4, "jadi bos sendiri": 4,
}

# Known spam email domains
SPAM_DOMAINS = {
    "mail.ru": 5, "yandex.ru": 3, "protonmail.com": 0,
    "gmail.com": -1, "yahoo.com": 0, "outlook.com": 0,
    "hotmail.com": 0, "icloud.com": 0,
    "guerrillamail.com": 5, "mailinator.com": 5, "tempmail.com": 5,
    "10minutemail.com": 5, "sharklasers.com": 5, "trashmail.com": 5,
    "throwaway.email": 5, "yopmail.com": 5, "dispostable.com": 5,
    "getnada.com": 5, "temp-mail.org": 5, "fakeinbox.com": 5,
    "emailondeck.com": 5, "spam4.me": 5, "spambog.com": 5,
    "myspam.xyz": 5, "0wnd.net": 5, "wuzup.net": 5,
}

# Known spam TLDs
SPAM_TLDS = {
    ".tk": 4, ".ml": 4, ".ga": 4, ".cf": 4, ".gq": 4,
    ".xyz": 3, ".top": 3, ".club": 3, ".work": 3, ".date": 3,
    ".review": 4, ".country": 4, ".stream": 3, ".download": 4,
    ".win": 4, ".bid": 4, ".trade": 4, ".webcam": 5, ".loan": 5,
    ".men": 4, ".click": 4, ".link": 3, ".online": 2, ".site": 2,
    ".website": 2, ".space": 2, ".tech": 2, ".store": 1,
    ".com": -1, ".org": 0, ".net": 0, ".edu": -1, ".gov": -1,
    ".io": 0, ".co": 0, ".id": 0, ".sg": 0, ".my": 0,
}

# Known spam URL shorteners
SPAM_SHORTENERS = [
    "bit.ly", "tinyurl.com", "ow.ly", "goo.gl", "is.gd",
    "buff.ly", "adf.ly", "shorte.st", "bc.vc", "short.link",
    "cutt.ly", "t.co", "rebrand.ly", "snip.ly", "v.gd",
    "shorturl.at", "tiny.cc", "tr.im", "clck.ru", "soo.gd",
    "t2m.io", "cur.lv", "lnkd.in", "short.gy", "ouo.io",
]

# Spam phrase patterns (regex)
SPAM_PATTERNS = [
    (r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b", 4, "IP Address"),  # Raw IP in text
    (r"https?://[^\s]{100,}", 5, "Very long URL"),
    (r"<script[^>]*>", 5, "Script tag in text"),
    (r"<iframe[^>]*>", 5, "Iframe in text"),
    (r"<\s*a\s+href=", 3, "HTML link in text"),
    (r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", 0, "Email address"),
    (r"\b[A-Z]{10,}\b", 3, "ALL CAPS WORD"),
    (r"[!]{3,}", 2, "Multiple exclamation marks"),
    (r"[$€£¥]{3,}", 3, "Multiple currency symbols"),
    (r"\b(?:[A-Z][a-z]* ){10,}", 2, "Excessive capitalization"),
    (r"\b\d{16}\b", 5, "Credit card number"),
    (r"\b\d{3}[-.]?\d{2}[-.]?\d{4}\b", 4, "SSN pattern"),
    (r"<[^>]*\bon\w+\s*=[^>]*>", 5, "Event handler in HTML"),
    (r"\b(?:[a-z0-9]+\.){4,}[a-z]{2,}\b", 3, "Excessive subdomains"),
    (r"[\x00-\x08\x0B\x0C\x0E-\x1F]", 5, "Control characters"),
    (r"&#\d+;", 3, "HTML entities"),
    (r"%[0-9A-Fa-f]{2}", 2, "URL encoding"),
    (r"[^\x00-\x7F]{10,}", 3, "Non-ASCII spam"),
]

# ═══════════════════════════════════════════════════════════════════
# 🧠 SPAM DETECTION ENGINE — 7 LAYER DEFENSE
# ═══════════════════════════════════════════════════════════════════

class SpamDetectionResult:
    """Container for spam detection result."""
    def __init__(self):
        self.score = 0
        self.max_score = 100
        self.details = []
        self.layers = {}
        self.is_spam = False
        self.confidence = 0.0
        self.verdict = ""
        self.recommendations = []

    def add_detail(self, layer: str, point: str, score: int, max_score: int):
        self.details.append({
            "layer": layer,
            "point": point,
            "score": score,
            "max": max_score
        })
        self.score += score
        self.max_score += max_score

    def finalize(self):
        if self.max_score > 0:
            self.confidence = min(100.0, (self.score / self.max_score) * 100)
        self.is_spam = self.confidence >= 50.0
        if self.confidence >= 90:
            self.verdict = "🔴 DEFINITELY SPAM"
        elif self.confidence >= 70:
            self.verdict = "🟠 HIGH LIKELIHOOD SPAM"
        elif self.confidence >= 50:
            self.verdict = "🟡 SUSPICIOUS — Likely Spam"
        elif self.confidence >= 30:
            self.verdict = "🟢 LOW RISK — Probably Clean"
        else:
            self.verdict = "🟢 CLEAN — Not Spam"

# ───────────────────────────────────────────────────────────────────
# LAYER 1: Keyword Density Analysis
# ───────────────────────────────────────────────────────────────────

def layer1_keyword_analysis(text: str, result: SpamDetectionResult):
    """Analyze spam keyword density & score."""
    text_lower = text.lower()
    total_keywords = 0
    keyword_hits = []

    for keyword, weight in SPAM_KEYWORDS.items():
        count = text_lower.count(keyword)
        if count > 0:
            total_keywords += count * weight
            keyword_hits.append((keyword, count, weight))

    # Sort by weight
    keyword_hits.sort(key=lambda x: x[2], reverse=True)

    if total_keywords > 50:
        score = 25
        detail_text = f"CRITICAL: {total_keywords} keyword spam point(s)"
    elif total_keywords > 30:
        score = 20
        detail_text = f"HIGH: {total_keywords} keyword spam point(s)"
    elif total_keywords > 15:
        score = 12
        detail_text = f"MEDIUM: {total_keywords} keyword spam point(s)"
    elif total_keywords > 5:
        score = 6
        detail_text = f"LOW: {total_keywords} keyword spam point(s)"
    else:
        score = 0
        detail_text = f"Clean: {total_keywords} keyword spam point(s)"

    result.add_detail("1. Keyword Analysis", detail_text, score, 25)
    result.layers["keyword_hits"] = keyword_hits[:10]
    result.layers["keyword_total"] = total_keywords

# ───────────────────────────────────────────────────────────────────
# LAYER 2: URL & Link Analysis
# ───────────────────────────────────────────────────────────────────

def layer2_url_analysis(text: str, result: SpamDetectionResult):
    """Analyze URLs, shorteners, suspicious domains."""
    url_pattern = r'https?://[^\s<>"{}|\\^`\[\]]+'
    urls = re.findall(url_pattern, text, re.IGNORECASE)
    url_score = 0
    url_details = []

    for url in urls:
        url_lower = url.lower()

        # Check shorteners
        for shortener in SPAM_SHORTENERS:
            if shortener in url_lower:
                url_score += 8
                url_details.append(f"Shortener: {shortener}")
                break

        # Check TLD
        for tld, weight in SPAM_TLDS.items():
            if url_lower.endswith(tld) or f"{tld}/" in url_lower:
                if weight > 0:
                    url_score += weight
                    url_details.append(f"Suspicious TLD: {tld} (+{weight})")

        # Check raw IP
        if re.search(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', url_lower):
            url_score += 6
            url_details.append("Raw IP URL")

        # Very long URL
        if len(url) > 150:
            url_score += 4
            url_details.append(f"Long URL ({len(url)} chars)")

    # Multiple URLs
    if len(urls) > 5:
        url_score += 5
        url_details.append(f"Excessive URLs: {len(urls)}")

    if url_score > 20:
        score = 20
        detail_text = f"CRITICAL: {url_score} URL risk point(s) from {len(urls)} URL(s)"
    elif url_score > 10:
        score = 12
        detail_text = f"HIGH: {url_score} URL risk point(s) from {len(urls)} URL(s)"
    elif url_score > 3:
        score = 6
        detail_text = f"MEDIUM: {url_score} URL risk point(s) from {len(urls)} URL(s)"
    else:
        score = max(0, url_score)
        detail_text = f"Clean: {url_score} URL risk point(s) from {len(urls)} URL(s)"

    result.add_detail("2. URL Analysis", detail_text, score, 20)
    result.layers["url_count"] = len(urls)
    result.layers["url_details"] = url_details[:5]

# ───────────────────────────────────────────────────────────────────
# LAYER 3: Email Address Analysis
# ───────────────────────────────────────────────────────────────────

def layer3_email_analysis(text: str, result: SpamDetectionResult):
    """Analyze email addresses in text."""
    email_pattern = r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
    emails = re.findall(email_pattern, text)
    email_score = 0
    email_details = []

    for email in emails:
        domain = email.split("@")[1].lower() if "@" in email else ""

        # Check disposable domains
        for spam_domain, weight in SPAM_DOMAINS.items():
            if domain == spam_domain:
                if weight > 0:
                    email_score += weight
                    email_details.append(f"Disposable: {domain} (+{weight})")

        # Check spam TLD
        for tld, weight in SPAM_TLDS.items():
            if domain.endswith(tld) and weight > 0:
                email_score += weight
                email_details.append(f"Spam TLD: {tld} (+{weight})")

        # Numeric-heavy email
        digits = sum(c.isdigit() for c in email.split("@")[0])
        if digits > 5:
            email_score += 3
            email_details.append("Numeric-heavy email")

    if email_score > 10:
        score = 15
        detail_text = f"CRITICAL: {email_score} email risk point(s) from {len(emails)} email(s)"
    elif email_score > 5:
        score = 8
        detail_text = f"HIGH: {email_score} email risk point(s) from {len(emails)} email(s)"
    elif email_score > 0:
        score = 3
        detail_text = f"LOW: {email_score} email risk point(s) from {len(emails)} email(s)"
    else:
        score = 0
        detail_text = f"Clean: {len(emails)} email(s) found"

    result.add_detail("3. Email Analysis", detail_text, score, 15)
    result.layers["email_count"] = len(emails)
    result.layers["email_details"] = email_details[:5]

# ───────────────────────────────────────────────────────────────────
# LAYER 4: Text Structure & Formatting Analysis
# ───────────────────────────────────────────────────────────────────

def layer4_text_structure(text: str, result: SpamDetectionResult):
    """Analyze text structure: caps, formatting, length."""
    struct_score = 0
    struct_details = []

    # All caps ratio
    if len(text) > 0:
        upper_count = sum(1 for c in text if c.isupper())
        letter_count = sum(1 for c in text if c.isalpha())
        if letter_count > 0:
            caps_ratio = upper_count / letter_count
            if caps_ratio > 0.5:
                struct_score += 8
                struct_details.append(f"Excessive CAPS: {int(caps_ratio*100)}%")
            elif caps_ratio > 0.3:
                struct_score += 4
                struct_details.append(f"High CAPS: {int(caps_ratio*100)}%")

    # Exclamation marks
    exclaim_count = text.count("!")
    if exclaim_count > 10:
        struct_score += 6
        struct_details.append(f"Excessive !!!: {exclaim_count}")
    elif exclaim_count > 5:
        struct_score += 3
        struct_details.append(f"Many !!!: {exclaim_count}")

    # Question marks
    question_count = text.count("?")
    if question_count > 10:
        struct_score += 3
        struct_details.append(f"Excessive ???: {question_count}")

    # Line count (spam often has many short lines)
    lines = text.split("\n")
    short_lines = [l for l in lines if 0 < len(l.strip()) < 30]
    if len(short_lines) > 20:
        struct_score += 4
        struct_details.append(f"Many short lines: {len(short_lines)}")

    # Repeated characters
    repeated = re.findall(r'(.)\1{4,}', text)
    if repeated:
        struct_score += 3
        struct_details.append("Repeated characters")

    # Empty lines (spam often padded)
    empty_lines = sum(1 for l in lines if l.strip() == "")
    if empty_lines > 20:
        struct_score += 3
        struct_details.append(f"Excessive empty lines: {empty_lines}")

    if struct_score > 10:
        score = 15
        detail_text = f"CRITICAL: {struct_score} structure risk point(s)"
    elif struct_score > 5:
        score = 8
        detail_text = f"HIGH: {struct_score} structure risk point(s)"
    elif struct_score > 0:
        score = 3
        detail_text = f"LOW: {struct_score} structure risk point(s)"
    else:
        score = 0
        detail_text = "Clean: Normal text structure"

    result.add_detail("4. Text Structure", detail_text, score, 15)
    result.layers["struct_details"] = struct_details[:5]

# ───────────────────────────────────────────────────────────────────
# LAYER 5: Pattern & Regex Matching
# ───────────────────────────────────────────────────────────────────

def layer5_pattern_matching(text: str, result: SpamDetectionResult):
    """Match known spam patterns via regex."""
    pattern_score = 0
    pattern_details = []

    for pattern, weight, desc in SPAM_PATTERNS:
        matches = re.findall(pattern, text, re.IGNORECASE)
        if matches:
            pattern_score += weight
            pattern_details.append(f"{desc}: {len(matches)} match(es) (+{weight})")

    if pattern_score > 15:
        score = 15
        detail_text = f"CRITICAL: {pattern_score} pattern risk point(s)"
    elif pattern_score > 8:
        score = 10
        detail_text = f"HIGH: {pattern_score} pattern risk point(s)"
    elif pattern_score > 0:
        score = 5
        detail_text = f"LOW: {pattern_score} pattern risk point(s)"
    else:
        score = 0
        detail_text = "Clean: No suspicious patterns"

    result.add_detail("5. Pattern Matching", detail_text, score, 15)
    result.layers["pattern_details"] = pattern_details[:5]

# ───────────────────────────────────────────────────────────────────
# LAYER 6: Bayesian-Style Heuristic Analysis
# ───────────────────────────────────────────────────────────────────

def layer6_heuristic_analysis(text: str, result: SpamDetectionResult):
    """Heuristic analysis using entropy, word frequency, etc."""
    heur_score = 0
    heur_details = []

    # Shannon entropy of text (spam tends to have higher entropy)
    if len(text) > 0:
        char_freq = Counter(text.lower())
        entropy = 0
        for count in char_freq.values():
            p = count / len(text)
            entropy -= p * math.log2(p)
        if entropy > 5.0:
            heur_score += 5
            heur_details.append(f"High entropy: {entropy:.2f}")
        elif entropy > 4.5:
            heur_score += 2
            heur_details.append(f"Moderate entropy: {entropy:.2f}")

    # Word count vs unique words (spam often repetitive)
    words = re.findall(r'\b\w+\b', text.lower())
    if len(words) > 0:
        unique_ratio = len(set(words)) / len(words)
        if unique_ratio < 0.3:
            heur_score += 5
            heur_details.append(f"Repetitive words: uniqueness {unique_ratio:.1%}")
        elif unique_ratio < 0.5:
            heur_score += 2
            heur_details.append(f"Somewhat repetitive: uniqueness {unique_ratio:.1%}")

    # Number density (spam often has many numbers)
    digit_count = sum(c.isdigit() for c in text)
    if len(text) > 0:
        digit_ratio = digit_count / len(text)
        if digit_ratio > 0.2:
            heur_score += 4
            heur_details.append(f"High digit density: {digit_ratio:.1%}")

    # Special character density
    special_chars = sum(1 for c in text if not c.isalnum() and not c.isspace() and c not in ".,!?-;:()[]{}'\"")
    if len(text) > 0:
        special_ratio = special_chars / len(text)
        if special_ratio > 0.15:
            heur_score += 3
            heur_details.append(f"High special char density: {special_ratio:.1%}")

    # Average word length (spam often has weird words)
    if words:
        avg_word_len = sum(len(w) for w in words) / len(words)
        if avg_word_len > 8:
            heur_score += 2
            heur_details.append(f"Long words avg: {avg_word_len:.1f}")

    if heur_score > 8:
        score = 10
        detail_text = f"CRITICAL: {heur_score} heuristic risk point(s)"
    elif heur_score > 3:
        score = 5
        detail_text = f"HIGH: {heur_score} heuristic risk point(s)"
    elif heur_score > 0:
        score = 2
        detail_text = f"LOW: {heur_score} heuristic risk point(s)"
    else:
        score = 0
        detail_text = "Clean: Normal heuristic profile"

    result.add_detail("6. Heuristic Analysis", detail_text, score, 10)
    result.layers["entropy"] = entropy if 'entropy' in dir() else 0
    result.layers["heur_details"] = heur_details[:5]

# ───────────────────────────────────────────────────────────────────
# LAYER 7: Sender/Header Reputation Check
# ───────────────────────────────────────────────────────────────────

def layer7_reputation_check(sender: str, subject: str, result: SpamDetectionResult):
    """Check sender reputation & subject line."""
    rep_score = 0
    rep_details = []

    sender_lower = sender.lower() if sender else ""

    # Sender domain check
    if "@" in sender_lower:
        domain = sender_lower.split("@")[1]
        for spam_domain, weight in SPAM_DOMAINS.items():
            if domain == spam_domain and weight > 0:
                rep_score += weight
                rep_details.append(f"Spam domain: {domain} (+{weight})")

        for tld, weight in SPAM_TLDS.items():
            if domain.endswith(tld) and weight > 0:
                rep_score += weight
                rep_details.append(f"Spam TLD: {tld} (+{weight})")

    # Numeric sender
    if sender_lower:
        digits = sum(c.isdigit() for c in sender_lower.split("@")[0])
        if digits > 5:
            rep_score += 3
            rep_details.append("Numeric-heavy sender")

    # Subject line analysis
    if subject:
        subj_lower = subject.lower()
        # All caps subject
        if subject.isupper():
            rep_score += 4
            rep_details.append("ALL CAPS subject")
        # Spam keywords in subject
        subj_keywords = 0
        for kw, w in SPAM_KEYWORDS.items():
            if kw in subj_lower:
                subj_keywords += w
        if subj_keywords > 10:
            rep_score += 6
            rep_details.append(f"Spam keywords in subject: {subj_keywords} pts")
        elif subj_keywords > 5:
            rep_score += 3
            rep_details.append(f"Some spam keywords in subject: {subj_keywords} pts")

        # Subject length (very short or very long = suspicious)
        if len(subject) < 3:
            rep_score += 2
            rep_details.append("Very short subject")
        elif len(subject) > 200:
            rep_score += 3
            rep_details.append("Very long subject")

    if rep_score > 10:
        score = 10
        detail_text = f"CRITICAL: {rep_score} reputation risk point(s)"
    elif rep_score > 5:
        score = 6
        detail_text = f"HIGH: {rep_score} reputation risk point(s)"
    elif rep_score > 0:
        score = 2
        detail_text = f"LOW: {rep_score} reputation risk point(s)"
    else:
        score = 0
        detail_text = "Clean: Good reputation"

    result.add_detail("7. Reputation Check", detail_text, score, 10)
    result.layers["rep_details"] = rep_details[:5]

# ═══════════════════════════════════════════════════════════════════
# 🏗️ MAIN SCAN FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

def scan_email():
    """Scan a complete email for spam."""
    cls()
    header("📧 EMAIL SPAM SCANNER", "Full email analysis — 7 layers of detection")
    info("Analisis email lengkap: header, body, links, attachments")
    thin_hr()

    print(f"  {Color.DIM}Masukkan detail email untuk dianalisis{Color.RESET}")
    print()

    sender = input(f"  {ARROW} {Color.W}From (pengirim):{Color.RESET} ").strip()
    subject = input(f"  {ARROW} {Color.W}Subject (judul):{Color.RESET} ").strip()
    print(f"  {ARROW} {Color.W}Body (isi email):{Color.RESET}")
    print(f"  {Color.DIM}  (Ketik isi email, akhiri dengan baris kosong + Enter){Color.RESET}")

    lines = []
    while True:
        line = input()
        if line == "":
            break
        lines.append(line)
    body = "\n".join(lines)

    full_text = f"{subject}\n\n{body}"

    if not full_text.strip():
        fail("Isi email kosong!")
        pause(); return

    # Run analysis
    print(f"\n  {Color.PURPLE}[*] Running 7-layer spam analysis...{Color.RESET}\n")
    time.sleep(0.5)

    result = SpamDetectionResult()

    # Layer 1-5 on full text
    layer1_keyword_analysis(full_text, result)
    print(f"  {Color.DIM}  [1/7] Keyword Analysis...{Color.RESET}")
    layer2_url_analysis(full_text, result)
    print(f"  {Color.DIM}  [2/7] URL Analysis...{Color.RESET}")
    layer3_email_analysis(full_text, result)
    print(f"  {Color.DIM}  [3/7] Email Analysis...{Color.RESET}")
    layer4_text_structure(full_text, result)
    print(f"  {Color.DIM}  [4/7] Text Structure...{Color.RESET}")
    layer5_pattern_matching(full_text, result)
    print(f"  {Color.DIM}  [5/7] Pattern Matching...{Color.RESET}")
    layer6_heuristic_analysis(full_text, result)
    print(f"  {Color.DIM}  [6/7] Heuristic Analysis...{Color.RESET}")
    layer7_reputation_check(sender, subject, result)
    print(f"  {Color.DIM}  [7/7] Reputation Check...{Color.RESET}")

    result.finalize()

    # Display results
    print(f"\n  {Color.PURPLE}╔{'═' * 60}╗{Color.RESET}")
    print(f"  {Color.PURPLE}║{Color.RESET} {Color.BOLD}{Color.ACCENT}📊 SPAM ANALYSIS RESULTS{Color.RESET}{' ' * 35}{Color.PURPLE}║{Color.RESET}")
    print(f"  {Color.PURPLE}╠{'═' * 60}╣{Color.RESET}")

    # Layer details
    for d in result.details:
        bar_width = int(d["score"] / d["max"] * 30) if d["max"] > 0 else 0
        bar_filled = f"{Color.ACCENT}{'█' * bar_width}{Color.DIM}{'░' * (30 - bar_width)}{Color.RESET}"
        pct = int(d["score"] / d["max"] * 100) if d["max"] > 0 else 0
        print(f"  {Color.PURPLE}║{Color.RESET} {Color.W}{d['layer']:<25}{Color.RESET} {bar_filled} {Color.ACCENT}{pct:>3}%{Color.RESET}  {Color.PURPLE}║{Color.RESET}")

    print(f"  {Color.PURPLE}╠{'═' * 60}╣{Color.RESET}")

    # Score & verdict
    verdict_color = Color.DANGER_C if result.is_spam else Color.G
    print(f"  {Color.PURPLE}║{Color.RESET} {Color.BOLD}Spam Score: {verdict_color}{result.confidence:.1f}%{Color.RESET}{' ' * (43 - len(f'{result.confidence:.1f}%'))}    {Color.PURPLE}║{Color.RESET}")
    print(f"  {Color.PURPLE}║{Color.RESET} {Color.BOLD}Verdict: {verdict_color}{result.verdict}{Color.RESET}{' ' * (46 - len(result.verdict))}   {Color.PURPLE}║{Color.RESET}")

    print(f"  {Color.PURPLE}╠{'═' * 60}╣{Color.RESET}")

    # Detailed findings
    if result.layers.get("keyword_hits"):
        print(f"  {Color.PURPLE}║{Color.RESET} {Color.WARN_C}⚠  Top Spam Keywords:{Color.RESET}{' ' * 36}{Color.PURPLE}║{Color.RESET}")
        for kw, count, weight in result.layers["keyword_hits"][:5]:
            print(f"  {Color.PURPLE}║{Color.RESET}   {Color.DIM}• {kw} ({count}x, +{weight}){Color.RESET}")

    if result.layers.get("url_details"):
        print(f"  {Color.PURPLE}║{Color.RESET} {Color.WARN_C}⚠  URL Issues:{Color.RESET}{' ' * 43}{Color.PURPLE}║{Color.RESET}")
        for ud in result.layers["url_details"][:3]:
            print(f"  {Color.PURPLE}║{Color.RESET}   {Color.DIM}• {ud}{Color.RESET}")

    if result.layers.get("struct_details"):
        print(f"  {Color.PURPLE}║{Color.RESET} {Color.WARN_C}⚠  Structure Issues:{Color.RESET}{' ' * 38}{Color.PURPLE}║{Color.RESET}")
        for sd in result.layers["struct_details"][:3]:
            print(f"  {Color.PURPLE}║{Color.RESET}   {Color.DIM}• {sd}{Color.RESET}")

    print(f"  {Color.PURPLE}╚{'═' * 60}╝{Color.RESET}")

    # Recommendations
    print()
    if result.is_spam:
        box(Color.DANGER_C, "🚨 SPAM DETECTED",
             f"Skor: {result.confidence:.1f}%\n"
             f"Rekomendasi:\n"
             f"• JANGAN klik link apapun\n"
             f"• JANGAN balas email ini\n"
             f"• Laporkan sebagai spam/phishing\n"
             f"• Blokir pengirim: {sender}")
    elif result.confidence >= 30:
        box(Color.WARN_C, "⚠️  SUSPICIOUS",
             f"Skor: {result.confidence:.1f}%\n"
             f"Rekomendasi:\n"
             f"• Berhati-hati dengan email ini\n"
             f"• Verifikasi pengirim sebelum bertindak\n"
             f"• Jangan klik link mencurigakan")
    else:
        box(Color.G, "✅ CLEAN",
             f"Skor: {result.confidence:.1f}%\n"
             f"Email ini kemungkinan besar aman.")

    # Save
    report = f"╔══════════════════════════════════════════════╗\n"
    report += f"║   SPAMGUARD PRO — EMAIL SPAM REPORT        ║\n"
    report += f"╚══════════════════════════════════════════════╝\n\n"
    report += f"Time    : {get_timestamp()}\n"
    report += f"Sender  : {sender}\n"
    report += f"Subject : {subject}\n"
    report += f"Score   : {result.confidence:.1f}%\n"
    report += f"Verdict : {result.verdict}\n"
    report += f"{'─'*50}\n\n"
    for d in result.details:
        report += f"[{d['layer']}] Score: {d['score']}/{d['max']} — {d['point']}\n"
    report += f"\nBody Preview:\n{body[:500]}\n"

    filename = save_result("email_scan", report)
    ok(f"Laporan disimpan → {filename}")

    pause()

def scan_text():
    """Scan plain text for spam."""
    cls()
    header("📝 TEXT SPAM SCANNER", "Analyze any text for spam indicators")
    info("Cocok untuk: komentar, SMS, chat, postingan, form")
    thin_hr()

    print(f"  {Color.DIM}Masukkan teks yang akan dianalisis{Color.RESET}")
    print(f"  {Color.DIM}(Ketik teks, akhiri dengan baris kosong + Enter){Color.RESET}")
    print()

    lines = []
    while True:
        line = input()
        if line == "":
            break
        lines.append(line)
    text = "\n".join(lines)

    if not text.strip():
        fail("Teks kosong!")
        pause(); return

    print(f"\n  {Color.PURPLE}[*] Running spam analysis...{Color.RESET}\n")

    result = SpamDetectionResult()
    layer1_keyword_analysis(text, result)
    print(f"  {Color.DIM}  [1/6] Keyword Analysis...{Color.RESET}")
    layer2_url_analysis(text, result)
    print(f"  {Color.DIM}  [2/6] URL Analysis...{Color.RESET}")
    layer3_email_analysis(text, result)
    print(f"  {Color.DIM}  [3/6] Email Analysis...{Color.RESET}")
    layer4_text_structure(text, result)
    print(f"  {Color.DIM}  [4/6] Text Structure...{Color.RESET}")
    layer5_pattern_matching(text, result)
    print(f"  {Color.DIM}  [5/6] Pattern Matching...{Color.RESET}")
    layer6_heuristic_analysis(text, result)
    print(f"  {Color.DIM}  [6/6] Heuristic Analysis...{Color.RESET}")

    result.finalize()

    # Compact display
    print(f"\n  {Color.PURPLE}╔{'═' * 60}╗{Color.RESET}")
    print(f"  {Color.PURPLE}║{Color.RESET} {Color.BOLD}{Color.ACCENT}📊 SPAM ANALYSIS RESULT{Color.RESET}{' ' * 34}{Color.PURPLE}║{Color.RESET}")
    print(f"  {Color.PURPLE}╠{'═' * 60}╣{Color.RESET}")

    for d in result.details:
        bar_width = int(d["score"] / d["max"] * 30) if d["max"] > 0 else 0
        bar_filled = f"{Color.ACCENT}{'█' * bar_width}{Color.DIM}{'░' * (30 - bar_width)}{Color.RESET}"
        pct = int(d["score"] / d["max"] * 100) if d["max"] > 0 else 0
        print(f"  {Color.PURPLE}║{Color.RESET} {Color.W}{d['layer']:<25}{Color.RESET} {bar_filled} {Color.ACCENT}{pct:>3}%{Color.RESET}  {Color.PURPLE}║{Color.RESET}")

    print(f"  {Color.PURPLE}╠{'═' * 60}╣{Color.RESET}")
    verdict_color = Color.DANGER_C if result.is_spam else Color.G
    print(f"  {Color.PURPLE}║{Color.RESET} {Color.BOLD}Score: {verdict_color}{result.confidence:.1f}%{Color.RESET}  →  {verdict_color}{result.verdict}{Color.RESET}{' ' * (18 - len(result.verdict))}{Color.PURPLE}║{Color.RESET}")
    print(f"  {Color.PURPLE}╚{'═' * 60}╝{Color.RESET}")

    if result.is_spam:
        print(f"\n  {Color.DANGER_C}🚨 SPAM DETECTED — Skor: {result.confidence:.1f}%{Color.RESET}")
    elif result.confidence >= 30:
        print(f"\n  {Color.WARN_C}⚠️  SUSPICIOUS — Skor: {result.confidence:.1f}%{Color.RESET}")
    else:
        print(f"\n  {Color.G}✅ CLEAN — Skor: {result.confidence:.1f}%{Color.RESET}")

    report = f"SPAMGUARD PRO — TEXT SCAN REPORT\n{'='*50}\n"
    report += f"Time    : {get_timestamp()}\n"
    report += f"Score   : {result.confidence:.1f}%\n"
    report += f"Verdict : {result.verdict}\n"
    report += f"{'─'*50}\n\n"
    for d in result.details:
        report += f"[{d['layer']}] Score: {d['score']}/{d['max']} — {d['point']}\n"
    report += f"\nText Preview:\n{text[:500]}\n"

    filename = save_result("text_scan", report)
    ok(f"Laporan disimpan → {filename}")

    pause()

def scan_batch():
    """Batch scan multiple texts."""
    cls()
    header("📋 BATCH SPAM SCANNER", "Scan multiple texts at once")
    info("Pisahkan setiap teks dengan '---' (3 tanda hubung)")
    thin_hr()

    print(f"  {Color.DIM}Masukkan teks-teks yang akan dianalisis{Color.RESET}")
    print(f"  {Color.DIM}(Pisahkan dengan --- pada baris tersendiri, akhiri dengan baris kosong){Color.RESET}")
    print()

    lines = []
    while True:
        line = input()
        if line == "":
            break
        lines.append(line)
    full = "\n".join(lines)

    texts = [t.strip() for t in full.split("---") if t.strip()]

    if not texts:
        fail("Tidak ada teks untuk dianalisis!")
        pause(); return

    print(f"\n  {Color.PURPLE}[*] Analyzing {len(texts)} text(s)...{Color.RESET}\n")

    results = []
    for i, text in enumerate(texts, 1):
        result = SpamDetectionResult()
        layer1_keyword_analysis(text, result)
        layer2_url_analysis(text, result)
        layer3_email_analysis(text, result)
        layer4_text_structure(text, result)
        layer5_pattern_matching(text, result)
        layer6_heuristic_analysis(text, result)
        result.finalize()
        results.append((i, text, result))

        verdict_icon = f"{Color.DANGER_C}SPAM{Color.RESET}" if result.is_spam else f"{Color.G}CLEAN{Color.RESET}"
        preview = text[:60].replace("\n", " ") + ("..." if len(text) > 60 else "")
        print(f"  {Color.PURPLE}[{i}]{Color.RESET} {verdict_icon} {Color.ACCENT}{result.confidence:.0f}%{Color.RESET} {Color.DIM}{preview}{Color.RESET}")

    # Summary
    spam_count = sum(1 for _, _, r in results if r.is_spam)
    clean_count = len(results) - spam_count

    print(f"\n  {Color.PURPLE}┌{'─' * 60}┐{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.BOLD}Batch Summary{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  Total: {Color.W}{len(results)}{Color.RESET}  |  {Color.DANGER_C}Spam: {spam_count}{Color.RESET}  |  {Color.G}Clean: {clean_count}{Color.RESET}")
    print(f"  {Color.PURPLE}└{'─' * 60}┘{Color.RESET}")

    report = f"SPAMGUARD PRO — BATCH SCAN REPORT\n{'='*50}\n"
    report += f"Time   : {get_timestamp()}\n"
    report += f"Total  : {len(results)}\n"
    report += f"Spam   : {spam_count}\n"
    report += f"Clean  : {clean_count}\n"
    report += f"{'─'*50}\n\n"
    for i, text, r in results:
        report += f"[{i}] Score: {r.confidence:.1f}% — {r.verdict}\n"
        report += f"    Text: {text[:100]}\n\n"

    filename = save_result("batch_scan", report)
    ok(f"Laporan disimpan → {filename}")

    pause()

def view_results():
    """View saved spam scan results."""
    cls()
    header("📁 VIEW SAVED RESULTS", "Browse spam scan reports")
    thin_hr()

    result_dir = "hasil_antispam"
    if not os.path.isdir(result_dir):
        fail("Belum ada hasil scan!")
        pause(); return

    files = sorted(
        [f for f in os.listdir(result_dir) if f.endswith(".txt")],
        key=lambda x: os.path.getmtime(os.path.join(result_dir, x)),
        reverse=True
    )

    if not files:
        fail("Belum ada hasil scan!")
        pause(); return

    print(f"\n  {Color.PURPLE}┌{'─' * 60}┐{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET} {Color.BOLD}{Color.ACCENT}  #  DATE       TIME     SCAN TYPE              SIZE{Color.RESET}       {Color.PURPLE}│{Color.RESET}")
    print(f"  {Color.PURPLE}├{'─' * 60}┤{Color.RESET}")

    file_info = []
    for i, fname in enumerate(files, 1):
        fpath = os.path.join(result_dir, fname)
        size = os.path.getsize(fpath)
        mtime = datetime.fromtimestamp(os.path.getmtime(fpath))
        date_str = mtime.strftime("%Y-%m-%d")
        time_str = mtime.strftime("%H:%M:%S")
        tool_name = fname.replace("_", " ").replace(".txt", "")
        if len(tool_name) > 22:
            tool_name = tool_name[:19] + "..."
        size_str = f"{size}B" if size < 1024 else f"{size/1024:.1f}KB"
        print(f"  {Color.PURPLE}│{Color.RESET} {Color.ACCENT}{i:2d}{Color.RESET}  {Color.DIM}{date_str} {time_str}{Color.RESET}  {Color.W}{tool_name:<22}{Color.RESET} {Color.DIM}{size_str:>6}{Color.RESET}     {Color.PURPLE}│{Color.RESET}")
        file_info.append((fname, fpath, size))

    print(f"  {Color.PURPLE}└{'─' * 60}┘{Color.RESET}")
    print(f"\n  {Color.DIM}Pilih nomor untuk melihat, [d] hapus, [0] hapus semua, [Enter] kembali{Color.RESET}")

    choice = input(f"\n  {ARROW} {Color.W}Pilihan:{Color.RESET} ").strip()
    if not choice:
        return

    if choice == "0":
        confirm = input(f"  {Color.DANGER_C}[!] Hapus SEMUA? Ketik 'DELETE ALL':{Color.RESET} ").strip()
        if confirm == "DELETE ALL":
            for fname, _, _ in file_info:
                os.remove(os.path.join(result_dir, fname))
            try:
                os.rmdir(result_dir)
            except:
                pass
            ok("Semua file dihapus!")
        pause(); return

    if choice.lower() == "d":
        num_str = input(f"  {ARROW} {Color.W}Nomor file:{Color.RESET} ").strip()
        if num_str.isdigit():
            idx = int(num_str) - 1
            if 0 <= idx < len(file_info):
                os.remove(os.path.join(result_dir, file_info[idx][0]))
                ok(f"'{file_info[idx][0]}' dihapus!")
        pause(); return

    if choice.isdigit():
        idx = int(choice) - 1
        if 0 <= idx < len(file_info):
            cls()
            header(f"📄 {file_info[idx][0]}")
            thin_hr()
            try:
                with open(file_info[idx][1], "r", encoding="utf-8") as f:
                    for line in f.read().split("\n"):
                        if "SPAM" in line or "CRITICAL" in line:
                            print(f"  {Color.DANGER_C}{line}{Color.RESET}")
                        elif "CLEAN" in line or "SAFE" in line:
                            print(f"  {Color.G}{line}{Color.RESET}")
                        elif "Score" in line or "Verdict" in line:
                            print(f"  {Color.W}{line}{Color.RESET}")
                        else:
                            print(f"  {Color.DARK_FG}{line}{Color.RESET}")
            except Exception as e:
                fail(f"Error: {e}")
            pause()

# ═══════════════════════════════════════════════════════════════════
# 📋 MAIN MENU
# ═══════════════════════════════════════════════════════════════════

def show_menu():
    cls()
    banner()

    total_files = 0
    if os.path.isdir("hasil_antispam"):
        total_files = len([f for f in os.listdir("hasil_antispam") if f.endswith(".txt")])

    print(f"  {Color.PURPLE}┌{'─' * 60}┐{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.DARK_FG}Reports : {Color.ACCENT}{total_files}{Color.RESET} {Color.DARK_FG}scan(s) saved{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.DARK_FG}Time    : {get_timestamp()}{Color.RESET}")
    print(f"  {Color.PURPLE}├{'─' * 60}┤{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.ACCENT}[1]{Color.RESET} 📧 {Color.W}Email Spam Scanner{Color.RESET}       {Color.DIM}7-layer full analysis{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.ACCENT}[2]{Color.RESET} 📝 {Color.W}Text Spam Scanner{Color.RESET}        {Color.DIM}SMS, komentar, chat, form{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.ACCENT}[3]{Color.RESET} 📋 {Color.W}Batch Spam Scanner{Color.RESET}       {Color.DIM}Multiple texts sekaligus{Color.RESET}")
    print(f"  {Color.PURPLE}├{'─' * 60}┤{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.ACCENT}[4]{Color.RESET} 📁 {Color.W}View Saved Results{Color.RESET}      {Color.DIM}Browse scan history{Color.RESET}")
    print(f"  {Color.PURPLE}├{'─' * 60}┤{Color.RESET}")
    print(f"  {Color.PURPLE}│{Color.RESET}  {Color.DANGER_C}[0]{Color.RESET} 🚪 {Color.DANGER_C}Exit{Color.RESET}")
    print(f"  {Color.PURPLE}└{'─' * 60}┘{Color.RESET}")
    print()

# ═══════════════════════════════════════════════════════════════════
# 🏗️ ENTRY POINT
# ═══════════════════════════════════════════════════════════════════

TOOLS = {
    "1": scan_email,
    "2": scan_text,
    "3": scan_batch,
    "4": view_results,
}

def main():
    check_deps()

    while True:
        try:
            show_menu()
            choice = input(f"  {Color.ACCENT}❯{Color.RESET} {Color.W}Pilih [0-4]:{Color.RESET} ").strip()

            if choice == "0":
                cls()
                box(Color.PURPLE, "👋 Terima kasih!\n   SPAMGUARD PRO v1.0 — Stay protected.",
                    "")
                print()
                sys.exit(0)

            if choice in TOOLS:
                TOOLS[choice]()
            else:
                fail("Pilihan tidak valid! Gunakan 0-4.")
                time.sleep(1)

        except KeyboardInterrupt:
            print(f"\n\n  {Color.WARN_C}[!] Program dihentikan.{Color.RESET}\n")
            sys.exit(0)
        except Exception as e:
            print(f"\n  {Color.DANGER_C}[✘] Error: {e}{Color.RESET}")
            import traceback
            traceback.print_exc()
            pause()

if __name__ == "__main__":
    main()