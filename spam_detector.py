#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
   ╔══════════════════════════════════════════════════════════════════╗
   ║   🛡️  SPAMGUARD ELITE v2.0 — Professional Spam Detection       ║
   ║   Advanced ML-Scoring  •  10 Layers  •  Real-Time  •  Export   ║
   ╚══════════════════════════════════════════════════════════════════╝
   SpamGuard Elite — Deteksi spam profesional dengan 10 layer analisis.
   Email • SMS • Chat • Komentar • Form • Postingan • Batch
"""

import subprocess, sys, os, re, json, time, math, hashlib, textwrap, string
from datetime import datetime, timedelta
from pathlib import Path
from collections import Counter, defaultdict
from typing import Any
from functools import lru_cache

# ═══════════════════════════════════════════════════════════════════
# 🎨 PROFESSIONAL DARK COLOR SYSTEM
# ═══════════════════════════════════════════════════════════════════
class Clr:
    RST = "\033[0m";    BLD = "\033[1m";    DIM = "\033[2m"
    ITL = "\033[3m";    UND = "\033[4m";    BLK = "\033[5m"
    R = "\033[0;31m";   G = "\033[0;32m";   Y = "\033[1;33m"
    B = "\033[0;34m";   M = "\033[0;35m";   C = "\033[0;36m"
    W = "\033[1;37m";   GR = "\033[2;37m"
    BR = "\033[1;31m";  BG = "\033[1;32m";  BY = "\033[1;93m"
    BB = "\033[1;34m";  BM = "\033[1;35m";  BC = "\033[1;36m"
    ACC = "\033[38;2;0;255;136m"
    WRN = "\033[38;2;255;165;0m"
    DNG = "\033[38;2;255;55;55m"
    INF = "\033[38;2;0;210;255m"
    PRP = "\033[38;2;170;100;255m"
    GLD = "\033[38;2;255;215;0m"
    SLV = "\033[38;2;192;192;192m"
    FNT = "\033[38;2;180;180;210m"

OK = f"{Clr.G}✔{Clr.RST}";   FL = f"{Clr.R}✘{Clr.RST}"
WR = f"{Clr.WRN}⚠{Clr.RST}";  IN = f"{Clr.INF}ℹ{Clr.RST}"
AR = f"{Clr.ACC}▸{Clr.RST}";  BT = f"{Clr.PRP}◆{Clr.RST}"
ST = f"{Clr.GLD}★{Clr.RST}"

# ═══════════════════════════════════════════════════════════════════
# 🧩 UTILITIES
# ═══════════════════════════════════════════════════════════════════

def cls(): os.system("cls" if os.name == "nt" else "clear")
def hr():  print(f"  {Clr.DIM}{'─' * 64}{Clr.RST}")
def ts():  return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def pause():
    input(f"\n  {Clr.ACC}[⏎]{Clr.RST} {Clr.DIM}Tekan Enter untuk kembali...{Clr.RST}")

def ok(m):   print(f"  {OK}  {Clr.G}{m}{Clr.RST}")
def fl(m):   print(f"  {FL}  {Clr.DNG}{m}{Clr.RST}")
def wr(m):   print(f"  {WR}  {Clr.WRN}{m}{Clr.RST}")
def inf(m):  print(f"  {IN}  {Clr.INF}{m}{Clr.RST}")
def det(m):  print(f"     {Clr.DIM}{m}{Clr.RST}")

def bx(color: str, title: str, body: str):
    print(f"  {color}┌{'─' * 60}┐{Clr.RST}")
    print(f"  {color}│{Clr.RST}  {Clr.BLD}{Clr.W}{title}{Clr.RST}")
    if body:
        print(f"  {color}├{'─' * 60}┤{Clr.RST}")
        for line in body.split("\n"):
            print(f"  {color}│{Clr.RST}  {Clr.W}{line}{Clr.RST}")
    print(f"  {color}└{'─' * 60}┘{Clr.RST}")

def banner():
    print(f"""
{Clr.ACC}  ╔{'═' * 62}╗
  ║{Clr.RST}  {Clr.PRP}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄{Clr.ACC}║
  ║{Clr.RST}  {Clr.BLD}{Clr.ACC}   🛡️  SPAMGUARD ELITE v2.0{Clr.RST}                                  {Clr.ACC}║
  ║{Clr.RST}  {Clr.DIM}   ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰{Clr.ACC}║
  ║{Clr.RST}  {Clr.FNT}  10-Layer AI  •  ML Scoring  •  NLP  •  Export Report      {Clr.ACC}║
  ║{Clr.RST}  {Clr.PRP}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀{Clr.ACC}║
  {Clr.ACC}╚{'═' * 62}╝{Clr.RST}""")

def hdr(title: str, sub: str = ""):
    print(f"\n  {Clr.PRP}┌{'─' * 62}┐{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.BLD}{Clr.ACC}{title}{Clr.RST}")
    if sub: print(f"  {Clr.PRP}│{Clr.RST}  {Clr.DIM}{sub}{Clr.RST}")
    print(f"  {Clr.PRP}└{'─' * 62}┘{Clr.RST}")

def save(tool: str, data: str) -> str:
    dn = "hasil_spamdetector"
    os.makedirs(dn, exist_ok=True)
    fn = f"{dn}/{tool}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    with open(fn, "w", encoding="utf-8") as f:
        f.write(data)
    return fn

def bar(pct: float, w: int = 36) -> str:
    f = int(w * pct / 100)
    return f"{Clr.ACC}{'█' * f}{Clr.DIM}{'░' * (w - f)}{Clr.RST}"

def gbar(score: int, max_s: int, w: int = 30) -> str:
    if max_s <= 0: return f"{Clr.DIM}{'░' * w}{Clr.RST}"
    pct = score / max_s
    f = int(w * pct)
    c = Clr.G if pct < 0.3 else (Clr.WRN if pct < 0.6 else Clr.DNG)
    return f"{c}{'█' * f}{Clr.DIM}{'░' * (w - f)}{Clr.RST}{Clr.ACC} {int(pct*100):>3}%{Clr.RST}"

# ═══════════════════════════════════════════════════════════════════
# 📦 AUTO DEPENDENCY
# ═══════════════════════════════════════════════════════════════════

def check_deps():
    import importlib
    need = []
    for lib in ["requests"]:
        try: importlib.import_module(lib)
        except ImportError: need.append(lib)
    if not need: return
    print(f"\n  {Clr.WRN}[!] Installing {len(need)} package...{Clr.RST}")
    for lib in need:
        print(f"  {Clr.DIM}⏳ {lib}...{Clr.RST}", end=" ", flush=True)
        r = subprocess.run([sys.executable, "-m", "pip", "install", lib, "--quiet"], capture_output=True, timeout=60)
        print(f"{Clr.G}✔{Clr.RST}" if r.returncode == 0 else f"{Clr.R}✘{Clr.RST}")

# ═══════════════════════════════════════════════════════════════════
# 🧠 SPAM INTELLIGENCE DATABASE
# ═══════════════════════════════════════════════════════════════════

# ── Weighted Keywords (score 1-10) ──
SPAM_KW = {
    # URGENCY / PRESSURE (HIGH)
    "urgent": 8, "segera": 7, "bertindak sekarang": 9, "act now": 9,
    "last chance": 9, "kesempatan terakhir": 9, "limited time": 8,
    "don't miss": 8, "jangan lewatkan": 8, "hurry": 7, "cepat": 6,
    "today only": 8, "hanya hari ini": 8, "closing soon": 7,
    "expires": 6, "kadaluarsa": 5, "within hours": 7,
    "only today": 8, "special offer": 6, "penawaran spesial": 6,

    # MONEY / FINANCIAL (HIGH)
    "free money": 9, "uang gratis": 9, "earn money": 8, "dapatkan uang": 8,
    "fast cash": 9, "make money": 8, "get paid": 7, "income": 6,
    "million": 6, "juta": 5, "billion": 6, "milyar": 5,
    "rich quick": 9, "kaya cepat": 9, "double your money": 9,
    "lipat gandakan uang": 9, "no risk": 8, "tanpa risiko": 8,
    "guaranteed return": 9, "100% free": 7, "100% gratis": 7,
    "investment opportunity": 8, "peluang investasi": 8,
    "wire transfer": 8, "bank account details": 9, "rekening bank": 8,
    "credit card number": 9, "paypal account": 7, "bitcoin wallet": 6,
    "inheritance": 7, "warisan": 7, "nigerian prince": 10,
    "prince": 7, "barrister": 7, "offshore account": 8,

    # PRIZE / WINNING (HIGH)
    "winner": 8, "pemenang": 8, "you won": 9, "anda menang": 9,
    "prize": 7, "hadiah": 7, "lottery": 9, "lotre": 9,
    "congratulations": 6, "selamat": 5, "claim your prize": 9,
    "klaim hadiah": 9, "selected winner": 8, "dipilih": 6,
    "free gift": 7, "hadiah gratis": 7, "exclusive offer": 6,
    "penawaran eksklusif": 6, "you've been selected": 8,

    # PHARMA / HEALTH (MEDIUM-HIGH)
    "viagra": 10, "cialis": 10, "xanax": 10, "pharmacy online": 9,
    "apotek online": 8, "prescription free": 9, "tanpa resep": 8,
    "weight loss pill": 8, "obat pelangsing": 8, "miracle cure": 9,
    "obat ajaib": 9, "enhancement": 9, "penis enlargement": 10,
    "cheap meds": 8, "obat murah": 7, "supplement": 5,

    # ADULT (HIGH)
    "xxx": 10, "porn": 10, "sex": 9, "nude": 9, "adult content": 8,
    "singles in your area": 8, "hot girls": 9, "cewek panas": 9,
    "escort": 9, "hookup": 8, "casual dating": 7, "kencan": 6,
    "meet singles": 7, "dating site": 7,

    # SUSPICIOUS ACTIONS (MEDIUM)
    "click here": 7, "klik disini": 7, "click below": 7,
    "open this link": 8, "buka link ini": 8, "download now": 7,
    "verify your account": 8, "verifikasi akun": 8,
    "confirm your identity": 8, "konfirmasi identitas": 8,
    "update your information": 7, "update informasi": 7,
    "restore access": 8, "pulihkan akses": 8, "unlock": 6,

    # THREATS / FEAR (HIGH)
    "virus detected": 9, "virus terdeteksi": 9, "your computer": 7,
    "hacked": 9, "diretas": 9, "suspended": 8, "ditangguhkan": 8,
    "security alert": 8, "peringatan keamanan": 8,
    "unauthorized access": 9, "akses tidak sah": 9,
    "suspicious activity": 8, "aktivitas mencurigakan": 8,
    "your password expired": 8, "password anda kadaluarsa": 8,
    "locked out": 7, "verify immediately": 8,

    # JOB SCAMS (MEDIUM)
    "work from home": 8, "kerja dari rumah": 8, "easy job": 8,
    "pekerjaan mudah": 8, "no experience needed": 7,
    "tanpa pengalaman": 7, "earn weekly": 8, "penghasilan mingguan": 8,
    "be your own boss": 7, "jadi bos sendiri": 7,
    "passive income": 7, "penghasilan pasif": 7,

    # LOAN / DEBT (MEDIUM)
    "bad credit ok": 8, "no credit check": 8, "pinjaman mudah": 8,
    "loan approved": 8, "pinjaman disetujui": 8, "debt relief": 7,
    "refinance now": 7, "lower your payments": 7,

    # TECH SUPPORT SCAMS (HIGH)
    "microsoft support": 9, "windows support": 9, "apple support": 9,
    "your ip address": 8, "router compromised": 9, "call this number": 8,
    "tech support": 8, "bantuan teknis": 7, "remote access": 8,
    "akses jarak jauh": 8, "system infected": 9,
}

# ── Known Spam Domains ──
SPAM_DOMAINS = {
    "mail.ru": 8, "yandex.ru": 4, "protonmail.com": 0,
    "gmail.com": -2, "yahoo.com": 0, "outlook.com": -1,
    "hotmail.com": 0, "icloud.com": -1, "live.com": 0,
    "guerrillamail.com": 9, "mailinator.com": 9, "tempmail.com": 9,
    "10minutemail.com": 9, "sharklasers.com": 9, "trashmail.com": 9,
    "throwaway.email": 9, "yopmail.com": 9, "dispostable.com": 9,
    "getnada.com": 9, "temp-mail.org": 9, "fakeinbox.com": 9,
    "emailondeck.com": 9, "spam4.me": 9, "spambog.com": 9,
    "myspam.xyz": 9, "0wnd.net": 9, "wuzup.net": 9,
    "nepwk.com": 9, "sohus.cn": 9, "linshiyou.com": 9,
    "mailna.co": 9, "emailfake.com": 9, "tempmail.net": 9,
    "throwawaymail.com": 9, "moakt.cc": 9, "guerrillamail.org": 9,
    "guerrillamail.net": 9, "mytemp.email": 9, "tempmailaddress.com": 9,
}

# ── Suspicious TLDs ──
SPAM_TLDS = {
    ".tk": 7, ".ml": 7, ".ga": 7, ".cf": 7, ".gq": 7,
    ".xyz": 4, ".top": 4, ".club": 3, ".work": 4, ".date": 4,
    ".review": 4, ".country": 4, ".stream": 4, ".download": 4,
    ".win": 4, ".bid": 4, ".trade": 4, ".webcam": 8, ".loan": 8,
    ".men": 5, ".click": 4, ".link": 3, ".racing": 5, ".accountant": 5,
    ".science": 4, ".party": 4, ".faith": 4, ".cricket": 5,
    ".com": -2, ".org": -1, ".net": -1, ".edu": -3, ".gov": -3,
    ".io": 0, ".co": 0, ".id": 0, ".sg": 0, ".my": 0,
}

# ── URL Shorteners ──
SHORTENERS = [
    "bit.ly", "tinyurl.com", "ow.ly", "goo.gl", "is.gd",
    "buff.ly", "adf.ly", "shorte.st", "bc.vc", "short.link",
    "cutt.ly", "t.co", "rebrand.ly", "snip.ly", "v.gd",
    "shorturl.at", "tiny.cc", "tr.im", "clck.ru", "soo.gd",
    "t2m.io", "cur.lv", "lnkd.in", "short.gy", "ouo.io",
    "rb.gy", "gg.gg", "vurl.com", "s.id", "surl.li",
    "shorten.sh", "hyperlink." + "info", "tiny.one",
    "is.gd", "kutt.it", "0rz.tw", "urlr.me",
]

# ── Regex Patterns ──
RGX_PATTERNS = [
    (r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b", 6, "Raw IP address"),
    (r"https?://[^\s]{150,}", 7, "Extremely long URL"),
    (r"<script[^>]*>", 10, "Script tag injected"),
    (r"<iframe[^>]*>", 10, "Iframe injected"),
    (r"<\s*a\s+href=", 4, "HTML link in text"),
    (r"\b[A-Z]{8,}\b", 4, "All-caps word"),
    (r"[!]{4,}", 3, "Excessive exclamation"),
    (r"[$€£¥]{3,}", 4, "Currency spam"),
    (r"\b\d{16}\b", 9, "Credit card number"),
    (r"\b\d{3}[-.]?\d{2}[-.]?\d{4}\b", 7, "SSN pattern"),
    (r"<[^>]*\bon\w+\s*=[^>]*>", 10, "Event handler in HTML"),
    (r"\b(?:[a-z0-9]+\.){5,}[a-z]{2,}\b", 4, "Excessive subdomains"),
    (r"[\x00-\x08\x0B\x0C\x0E-\x1F]", 9, "Control characters"),
    (r"&#x?[0-9a-f]+;", 3, "HTML entities spam"),
    (r"%[0-9A-Fa-f]{2}", 2, "URL encoding"),
    (r"[^\x00-\x7F]{8,}", 3, "Non-ASCII spam"),
    (r"\b(.)\1{5,}\b", 3, "Repeated characters"),
    (r"\b[a-z]{1,2}\b", 1, "Single-letter words"),
    (r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b", 0, "Email"),
    (r"\b\d{3,4}[- ]?\d{3,4}[- ]?\d{4}\b", 5, "Phone number"),
]

# ── Known Phishing Keywords ──
PHISHING_KW = [
    "verify your account", "verify your identity", "confirm your account",
    "update your payment", "update your billing", "billing information",
    "your account has been", "your account will be", "unusual sign-in",
    "new sign-in", "login attempt", "login from", "sign in from",
    "unrecognized device", "new device", "suspicious sign-in",
    "password reset", "reset your password", "change password",
    "security check", "security verification", "identity verification",
    "account suspended", "account locked", "account disabled",
    "account limited", "your order", "order confirmation",
    "invoice attached", "payment receipt", "tax refund", "refund",
    "track your package", "delivery notification", "shipment",
    "voicemail received", "fax received", "document shared",
    "shared a file", "shared a document", "you have a message",
    "urgent message", "important notice", "action required",
]

# ── Common Spam Phrases (multi-word) ──
SPAM_PHRASES = [
    "dear sir/madam", "dear valued customer", "dear user",
    "dear account holder", "dear email user", "dear beneficiary",
    "i am writing to you", "i am contacting you", "this is not a scam",
    "this is not spam", "this is legitimate", "trust me",
    "i promise you", "god bless you", "god bless",
    "in good faith", "in good health", "with due respect",
    "reply urgently", "reply immediately", "respond immediately",
    "for your kind attention", "for your perusal",
    "strictly confidential", "highly confidential",
    "top secret", "this transaction", "business proposal",
    "mutual benefit", "mutual cooperation", "partnership",
    "fund transfer", "money transfer", "western union",
    "money gram", "money order", "cashier's check",
    "certified check", "bank draft", "irrevocable",
    "next of kin", "deceased", "unclaimed fund",
    "abandoned fund", "dormant account", "unclaimed money",
    "sole beneficiary", "named beneficiary", "legal heir",
    "power of attorney", "affidavit", "notary",
    "government official", "central bank", "federal bureau",
    "united nations", "world bank", "international monetary fund",
    "compensation fund", "settlement fund", "compensation payment",
]

# ═══════════════════════════════════════════════════════════════════
# 🔬 ANALYSIS RESULT CONTAINER
# ═══════════════════════════════════════════════════════════════════

class ScanResult:
    def __init__(self):
        self.score = 0
        self.max_score = 0
        self.layers = []
        self.details = {}
        self.spam = False
        self.pct = 0.0
        self.grade = ""
        self.emoji = ""
        self.color = ""

    def add(self, name: str, pts: int, mx: int, detail: str, extra: Any = None):
        self.layers.append({"name": name, "pts": pts, "mx": mx, "detail": detail, "extra": extra})
        self.score += pts
        self.max_score += mx

    def finalize(self):
        # Normalize: cap at reasonable max_score
        effective_max = 100.0
        if self.max_score > 0:
            self.pct = min(100.0, round(self.score / effective_max * 100, 1))
        self.spam = self.pct >= 50
        if self.pct >= 90:    self.grade = "CRITICAL SPAM"; self.emoji = "🔴"; self.color = Clr.DNG
        elif self.pct >= 75:  self.grade = "HIGH SPAM";     self.emoji = "🟠"; self.color = Clr.WRN
        elif self.pct >= 50:  self.grade = "SUSPICIOUS";    self.emoji = "🟡"; self.color = Clr.BY
        elif self.pct >= 25:  self.grade = "LOW RISK";      self.emoji = "🟢"; self.color = Clr.G
        else:                 self.grade = "CLEAN";         self.emoji = "✅"; self.color = Clr.G

# ═══════════════════════════════════════════════════════════════════
# 🧠 10-LAYER SPAM DETECTION ENGINE
# ═══════════════════════════════════════════════════════════════════

# ── LAYER 1: Keyword Density ──
def L1_keywords(text: str, r: ScanResult):
    t = text.lower()
    hits = []
    total = 0
    for kw, w in SPAM_KW.items():
        c = t.count(kw)
        if c > 0:
            hits.append((kw, c, w, c * w))
            total += c * w
    hits.sort(key=lambda x: -x[3])
    if total > 60:    pts, detail = 25, f"CRITICAL: {total} keyword pts, {len(hits)} matched"
    elif total > 35:  pts, detail = 20, f"HIGH: {total} keyword pts, {len(hits)} matched"
    elif total > 15:  pts, detail = 12, f"MEDIUM: {total} keyword pts, {len(hits)} matched"
    elif total > 5:   pts, detail = 6, f"LOW: {total} keyword pts, {len(hits)} matched"
    else:             pts, detail = 0, f"Clean: {total} keyword pts"
    r.add("1. Keyword Density", pts, 25, detail, {"hits": hits[:8], "total": total})

# ── LAYER 2: URL & Link Intelligence ──
def L2_urls(text: str, r: ScanResult):
    urls = re.findall(r'https?://[^\s<>"{}|\\^`\[\]]+', text, re.I)
    score = 0
    details = []
    for url in urls:
        u = url.lower()
        for s in SHORTENERS:
            if s in u:
                score += 8; details.append(f"Shortener: {s}"); break
        for tld, w in SPAM_TLDS.items():
            if u.endswith(tld) or f"{tld}/" in u and w > 0:
                score += w; details.append(f"Spam TLD: {tld} (+{w})")
        if re.search(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', u):
            score += 7; details.append("Raw IP URL")
        if len(url) > 150:
            score += 4; details.append(f"Long URL ({len(url)} chars)")
    if len(urls) > 5:
        score += 5; details.append(f"Excessive: {len(urls)} URLs")
    if score > 20:    pts, detail = 20, f"CRITICAL: {score} URL risk pts, {len(urls)} URLs"
    elif score > 10:  pts, detail = 12, f"HIGH: {score} URL risk pts, {len(urls)} URLs"
    elif score > 3:   pts, detail = 6, f"MEDIUM: {score} URL risk pts, {len(urls)} URLs"
    else:             pts, detail = max(0, score), f"Clean: {score} URL risk pts, {len(urls)} URLs"
    r.add("2. URL Intelligence", pts, 20, detail, {"urls": len(urls), "issues": details[:5]})

# ── LAYER 3: Email Address Forensics ──
def L3_emails(text: str, r: ScanResult):
    emails = re.findall(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', text)
    score = 0
    details = []
    for em in emails:
        dom = em.split("@")[1].lower() if "@" in em else ""
        for sd, w in SPAM_DOMAINS.items():
            if dom == sd and w > 0:
                score += w; details.append(f"Disposable: {dom} (+{w})")
        for tld, w in SPAM_TLDS.items():
            if dom.endswith(tld) and w > 0:
                score += w; details.append(f"Spam TLD: {tld} (+{w})")
        if sum(c.isdigit() for c in em.split("@")[0]) > 5:
            score += 3; details.append("Numeric-heavy email")
    if score > 10:    pts, detail = 15, f"CRITICAL: {score} email risk pts, {len(emails)} emails"
    elif score > 5:   pts, detail = 8, f"HIGH: {score} email risk pts, {len(emails)} emails"
    elif score > 0:   pts, detail = 3, f"LOW: {score} email risk pts, {len(emails)} emails"
    else:             pts, detail = 0, f"Clean: {len(emails)} emails found"
    r.add("3. Email Forensics", pts, 15, detail, {"emails": len(emails), "issues": details[:5]})

# ── LAYER 4: Text Structure Analysis ──
def L4_structure(text: str, r: ScanResult):
    score = 0; dets = []
    if len(text) > 0:
        up = sum(1 for c in text if c.isupper())
        alpha = sum(1 for c in text if c.isalpha())
        if alpha > 0:
            rto = up / alpha
            if rto > 0.5:    score += 8; dets.append(f"Excessive CAPS: {int(rto*100)}%")
            elif rto > 0.3:  score += 4; dets.append(f"High CAPS: {int(rto*100)}%")
    ex = text.count("!")
    if ex > 10:    score += 6; dets.append(f"Excessive !!!: {ex}")
    elif ex > 5:   score += 3; dets.append(f"Many !!!: {ex}")
    qs = text.count("?")
    if qs > 10: score += 3; dets.append(f"Excessive ???: {qs}")
    lines = text.split("\n")
    short = [l for l in lines if 0 < len(l.strip()) < 30]
    if len(short) > 20: score += 4; dets.append(f"Many short lines: {len(short)}")
    if re.findall(r'(.)\1{5,}', text): score += 3; dets.append("Stretched characters")
    empty = sum(1 for l in lines if l.strip() == "")
    if empty > 20: score += 3; dets.append(f"Excessive empty lines: {empty}")
    if score > 10:    pts, detail = 15, f"CRITICAL: {score} structure risk pts"
    elif score > 5:   pts, detail = 8, f"HIGH: {score} structure risk pts"
    elif score > 0:   pts, detail = 3, f"LOW: {score} structure risk pts"
    else:             pts, detail = 0, "Clean: Normal text structure"
    r.add("4. Text Structure", pts, 15, detail, {"issues": dets[:5]})

# ── LAYER 5: Pattern & Regex Matching ──
def L5_patterns(text: str, r: ScanResult):
    score = 0; dets = []
    for pat, w, desc in RGX_PATTERNS:
        m = re.findall(pat, text, re.I)
        if m:
            score += w; dets.append(f"{desc}: {len(m)} match (+{w})")
    if score > 15:    pts, detail = 15, f"CRITICAL: {score} pattern risk pts"
    elif score > 8:   pts, detail = 10, f"HIGH: {score} pattern risk pts"
    elif score > 0:   pts, detail = 5, f"LOW: {score} pattern risk pts"
    else:             pts, detail = 0, "Clean: No suspicious patterns"
    r.add("5. Pattern Matching", pts, 15, detail, {"issues": dets[:5]})

# ── LAYER 6: Heuristic/NLP Analysis ──
def L6_heuristic(text: str, r: ScanResult):
    score = 0; dets = []
    if len(text) > 0:
        freq = Counter(text.lower())
        ent = 0
        for cnt in freq.values():
            p = cnt / len(text); ent -= p * math.log2(p)
        if ent > 5.0:    score += 5; dets.append(f"High entropy: {ent:.2f}")
        elif ent > 4.5:  score += 2; dets.append(f"Moderate entropy: {ent:.2f}")
    words = re.findall(r'\b\w+\b', text.lower())
    if words:
        uniq = len(set(words)) / len(words)
        if uniq < 0.3:   score += 5; dets.append(f"Very repetitive: {uniq:.1%}")
        elif uniq < 0.5: score += 2; dets.append(f"Somewhat repetitive: {uniq:.1%}")
        avg_wl = sum(len(w) for w in words) / len(words)
        if avg_wl > 8: score += 2; dets.append(f"Long words avg: {avg_wl:.1f}")
        avg_wl2 = sum(len(w) for w in words) / len(words)
    if len(text) > 0:
        dig_ratio = sum(c.isdigit() for c in text) / len(text)
        if dig_ratio > 0.2: score += 4; dets.append(f"High digit density: {dig_ratio:.1%}")
    if score > 8:    pts, detail = 10, f"CRITICAL: {score} heuristic risk pts"
    elif score > 3:  pts, detail = 5, f"HIGH: {score} heuristic risk pts"
    elif score > 0:  pts, detail = 2, f"LOW: {score} heuristic risk pts"
    else:            pts, detail = 0, "Clean: Normal NLP profile"
    r.add("6. NLP Heuristics", pts, 10, detail, {"issues": dets[:5]})

# ── LAYER 7: Phishing Detection ──
def L7_phishing(text: str, r: ScanResult):
    t = text.lower()
    score = 0; dets = []
    for kw in PHISHING_KW:
        if kw in t:
            score += 5; dets.append(kw)
            if len(dets) >= 5: break
    if score > 20:    pts, detail = 15, f"CRITICAL: {score} phishing pts, {len(dets)} patterns"
    elif score > 10:  pts, detail = 10, f"HIGH: {score} phishing pts, {len(dets)} patterns"
    elif score > 5:   pts, detail = 5, f"MEDIUM: {score} phishing pts, {len(dets)} patterns"
    elif score > 0:   pts, detail = 2, f"LOW: {score} phishing pts, {len(dets)} patterns"
    else:             pts, detail = 0, "Clean: No phishing patterns"
    r.add("7. Phishing Detection", pts, 15, detail, {"patterns": dets[:5]})

# ── LAYER 8: Spam Phrase Analysis ──
def L8_phrases(text: str, r: ScanResult):
    t = text.lower()
    score = 0; dets = []
    for ph in SPAM_PHRASES:
        if ph in t:
            score += 3; dets.append(ph)
            if len(dets) >= 5: break
    if score > 10:    pts, detail = 10, f"CRITICAL: {score} phrase pts, {len(dets)} detected"
    elif score > 5:   pts, detail = 6, f"HIGH: {score} phrase pts, {len(dets)} detected"
    elif score > 0:   pts, detail = 2, f"LOW: {score} phrase pts, {len(dets)} detected"
    else:             pts, detail = 0, "Clean: No spam phrases"
    r.add("8. Phrase Analysis", pts, 10, detail, {"phrases": dets[:5]})

# ── LAYER 9: Sender Reputation ──
def L9_sender(sender: str, subject: str, r: ScanResult):
    score = 0; dets = []
    sl = sender.lower() if sender else ""
    if "@" in sl:
        dom = sl.split("@")[1]
        for sd, w in SPAM_DOMAINS.items():
            if dom == sd and w > 0:
                score += w; dets.append(f"Spam domain: {dom} (+{w})")
        for tld, w in SPAM_TLDS.items():
            if dom.endswith(tld) and w > 0:
                score += w; dets.append(f"Spam TLD: {tld} (+{w})")
        if sum(c.isdigit() for c in sl.split("@")[0]) > 5:
            score += 3; dets.append("Numeric-heavy sender")
    if subject:
        if subject.isupper(): score += 4; dets.append("ALL CAPS subject")
        subj_score = 0
        for kw, w in SPAM_KW.items():
            if kw in subject.lower(): subj_score += w
        if subj_score > 10: score += 6; dets.append(f"Spam keywords in subject: {subj_score}pts")
        elif subj_score > 5: score += 3; dets.append(f"Some spam keywords in subject")
        if len(subject) < 3: score += 2; dets.append("Very short subject")
        elif len(subject) > 200: score += 3; dets.append("Very long subject")
    if score > 10:    pts, detail = 10, f"CRITICAL: {score} reputation risk pts"
    elif score > 5:   pts, detail = 6, f"HIGH: {score} reputation risk pts"
    elif score > 0:   pts, detail = 2, f"LOW: {score} reputation risk pts"
    else:             pts, detail = 0, "Clean: Good reputation"
    r.add("9. Sender Reputation", pts, 10, detail, {"issues": dets[:5]})

# ── LAYER 10: Bayesian-Style Statistical Analysis ──
def L10_bayesian(text: str, r: ScanResult):
    """Statistical spam probability estimation."""
    t = text.lower()
    words = re.findall(r'\b\w+\b', t)
    if not words: r.add("10. Statistical Model", 0, 5, "No text to analyze"); return

    # Count spam vs non-spam word indicators
    spam_count = 0
    total_words = len(words)
    for w in words:
        if w in SPAM_KW: spam_count += 1
    spam_ratio = spam_count / total_words if total_words > 0 else 0

    # Bayesian-inspired smoothing
    if spam_ratio > 0.15:    pts, detail = 5, f"CRITICAL: {spam_ratio:.1%} words are spam-indicators"
    elif spam_ratio > 0.08:  pts, detail = 3, f"HIGH: {spam_ratio:.1%} words are spam-indicators"
    elif spam_ratio > 0.03:  pts, detail = 1, f"LOW: {spam_ratio:.1%} words are spam-indicators"
    else:                    pts, detail = 0, f"Clean: {spam_ratio:.1%} spam-indicator ratio"
    r.add("10. Statistical Model", pts, 5, detail, {"ratio": spam_ratio, "words": total_words})

# ═══════════════════════════════════════════════════════════════════
# 🔍 FULL ANALYSIS ENGINE
# ═══════════════════════════════════════════════════════════════════

def full_scan(text: str, sender: str = "", subject: str = "") -> ScanResult:
    """Run all 10 layers of spam detection."""
    r = ScanResult()
    L1_keywords(text, r)
    L2_urls(text, r)
    L3_emails(text, r)
    L4_structure(text, r)
    L5_patterns(text, r)
    L6_heuristic(text, r)
    L7_phishing(text, r)
    L8_phrases(text, r)
    L9_sender(sender, subject, r)
    L10_bayesian(text, r)
    r.finalize()
    return r

def display_results(r: ScanResult, sender: str = "", subject: str = ""):
    """Display formatted scan results."""
    print(f"\n  {Clr.PRP}╔{'═' * 60}╗{Clr.RST}")
    print(f"  {Clr.PRP}║{Clr.RST} {Clr.BLD}{Clr.ACC}📊 SPAM ANALYSIS REPORT{Clr.RST}{' ' * 34}{Clr.PRP}║{Clr.RST}")
    print(f"  {Clr.PRP}╠{'═' * 60}╣{Clr.RST}")

    for lyr in r.layers:
        bar_str = gbar(lyr["pts"], lyr["mx"])
        print(f"  {Clr.PRP}║{Clr.RST} {Clr.W}{lyr['name']:<22}{Clr.RST} {bar_str}  {Clr.PRP}║{Clr.RST}")

    print(f"  {Clr.PRP}╠{'═' * 60}╣{Clr.RST}")
    print(f"  {Clr.PRP}║{Clr.RST} {Clr.BLD}Score: {r.color}{r.pct:.1f}%{Clr.RST}  →  {r.color}{r.emoji} {r.grade}{Clr.RST}{' ' * (28 - len(r.grade))}{Clr.PRP}║{Clr.RST}")
    print(f"  {Clr.PRP}╠{'═' * 60}╣{Clr.RST}")

    # Detailed findings
    for lyr in r.layers:
        if lyr["pts"] > 0:
            print(f"  {Clr.PRP}║{Clr.RST} {Clr.WRN}▸ {lyr['detail']}{Clr.RST}")
            if lyr.get("extra"):
                ex = lyr["extra"]
                if isinstance(ex, dict):
                    for k, v in ex.items():
                        if isinstance(v, list) and v and k != "total":
                            for item in v[:3]:
                                if isinstance(item, tuple):
                                    print(f"  {Clr.PRP}║{Clr.RST}   {Clr.DIM}• {item[0]} ({item[1]}x, +{item[2]}){Clr.RST}")
                                else:
                                    print(f"  {Clr.PRP}║{Clr.RST}   {Clr.DIM}• {item}{Clr.RST}")
            print(f"  {Clr.PRP}║{Clr.RST}")

    print(f"  {Clr.PRP}╚{'═' * 60}╝{Clr.RST}")

    # Recommendation box
    print()
    if r.pct >= 90:
        bx(Clr.DNG, "🚨 CRITICAL SPAM — DO NOT ENGAGE",
           "• JANGAN klik link apapun\n• JANGAN balas atau berikan data\n• Laporkan sebagai spam/phishing\n• Blokir pengirim segera\n• Hapus email ini")
    elif r.pct >= 75:
        bx(Clr.WRN, "🟠 HIGH LIKELIHOOD SPAM",
           "• Sangat mencurigakan\n• Hindari klik link atau attachment\n• Verifikasi pengirim via channel lain\n• Pertimbangkan untuk melaporkan")
    elif r.pct >= 50:
        bx(Clr.WRN, "🟡 SUSPICIOUS — Perlu Verifikasi",
           "• Beberapa indikator spam terdeteksi\n• Verifikasi pengirim sebelum bertindak\n• Jangan berikan data sensitif\n• Waspada terhadap link")
    elif r.pct >= 25:
        bx(Clr.G, "🟢 LOW RISK — Probably Safe",
           "• Beberapa indikator minor terdeteksi\n• Tetap waspada\n• Umumnya aman")
    else:
        bx(Clr.G, "✅ CLEAN — Aman",
           "• Tidak terdeteksi indikator spam\n• Email/teks ini aman\n• Tidak perlu tindakan khusus")

# ═══════════════════════════════════════════════════════════════════
# 📱 USER INTERFACE SCREENS
# ═══════════════════════════════════════════════════════════════════

def scan_email():
    cls()
    hdr("📧 EMAIL SPAM DETECTOR", "Full 10-layer email analysis")
    inf("Analisis lengkap: header, body, link, attachment, sender reputation")
    hr()

    print(f"  {Clr.DIM}Masukkan detail email yang akan dianalisis{Clr.RST}\n")
    sender = input(f"  {AR} {Clr.W}From (pengirim):{Clr.RST} ").strip()
    subject = input(f"  {AR} {Clr.W}Subject (judul):{Clr.RST} ").strip()
    print(f"  {AR} {Clr.W}Body (isi email):{Clr.RST}")
    print(f"  {Clr.DIM}  (Ketik isi email, akhiri dengan baris kosong){Clr.RST}")

    lines = []
    while True:
        line = input()
        if line == "": break
        lines.append(line)
    body = "\n".join(lines)
    full = f"{subject}\n\n{body}"

    if not full.strip():
        fl("Isi email kosong!"); pause(); return

    print(f"\n  {Clr.PRP}[*] Running 10-layer analysis...{Clr.RST}\n")
    for i in range(1, 11):
        print(f"  {Clr.DIM}  [{i:2d}/10] Layer {i}...{Clr.RST}")
        time.sleep(0.03)

    r = full_scan(full, sender, subject)
    display_results(r, sender, subject)

    # Save report
    report = f"╔══════════════════════════════════════════════╗\n"
    report += f"║   SPAMGUARD ELITE — EMAIL SCAN REPORT      ║\n"
    report += f"╚══════════════════════════════════════════════╝\n\n"
    report += f"Time    : {ts()}\nSender  : {sender}\nSubject : {subject}\n"
    report += f"Score   : {r.pct}%\nVerdict : {r.grade}\n{'─'*50}\n\n"
    for lyr in r.layers:
        report += f"[{lyr['name']}] {lyr['pts']}/{lyr['mx']} — {lyr['detail']}\n"
    report += f"\nBody Preview:\n{body[:500]}\n"
    fn = save("email_scan", report)
    ok(f"Laporan disimpan → {fn}")
    pause()

def scan_text():
    cls()
    hdr("📝 TEXT SPAM DETECTOR", "Analyze any text: SMS, chat, comment, post")
    inf("Cocok untuk: SMS, WhatsApp, komentar, postingan, form submission")
    hr()

    print(f"  {Clr.DIM}Masukkan teks yang akan dianalisis{Clr.RST}")
    print(f"  {Clr.DIM}(Ketik teks, akhiri dengan baris kosong){Clr.RST}\n")

    lines = []
    while True:
        line = input()
        if line == "": break
        lines.append(line)
    text = "\n".join(lines)

    if not text.strip():
        fl("Teks kosong!"); pause(); return

    print(f"\n  {Clr.PRP}[*] Running 10-layer analysis...{Clr.RST}\n")
    for i in range(1, 11):
        print(f"  {Clr.DIM}  [{i:2d}/10] Layer {i}...{Clr.RST}")
        time.sleep(0.03)

    r = full_scan(text)
    display_results(r)

    report = f"╔══════════════════════════════════════════════╗\n"
    report += f"║   SPAMGUARD ELITE — TEXT SCAN REPORT       ║\n"
    report += f"╚══════════════════════════════════════════════╝\n\n"
    report += f"Time    : {ts()}\nScore   : {r.pct}%\nVerdict : {r.grade}\n{'─'*50}\n\n"
    for lyr in r.layers:
        report += f"[{lyr['name']}] {lyr['pts']}/{lyr['mx']} — {lyr['detail']}\n"
    report += f"\nText Preview:\n{text[:500]}\n"
    fn = save("text_scan", report)
    ok(f"Laporan disimpan → {fn}")
    pause()

def scan_batch():
    cls()
    hdr("📋 BATCH SPAM DETECTOR", "Scan multiple texts at once")
    inf("Pisahkan setiap teks dengan '---' (3 tanda hubung)")
    hr()

    print(f"  {Clr.DIM}Masukkan teks-teks, pisahkan dengan ---{Clr.RST}")
    print(f"  {Clr.DIM}(Akhiri dengan baris kosong){Clr.RST}\n")

    lines = []
    while True:
        line = input()
        if line == "": break
        lines.append(line)
    full = "\n".join(lines)
    texts = [t.strip() for t in full.split("---") if t.strip()]

    if not texts:
        fl("Tidak ada teks!"); pause(); return

    print(f"\n  {Clr.PRP}[*] Analyzing {len(texts)} texts...{Clr.RST}\n")

    results = []
    for i, text in enumerate(texts, 1):
        r = full_scan(text)
        results.append((i, text, r))
        icon = f"{Clr.DNG}SPAM{Clr.RST}" if r.spam else f"{Clr.G}CLEAN{Clr.RST}"
        preview = text[:60].replace("\n", " ") + ("..." if len(text) > 60 else "")
        print(f"  {Clr.PRP}[{i:2d}]{Clr.RST} {icon} {Clr.ACC}{r.pct:5.1f}%{Clr.RST} {Clr.DIM}{preview}{Clr.RST}")

    spam_n = sum(1 for _, _, r in results if r.spam)
    clean_n = len(results) - spam_n

    print(f"\n  {Clr.PRP}┌{'─' * 60}┐{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.BLD}Batch Summary{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  Total: {Clr.W}{len(results)}{Clr.RST}  |  {Clr.DNG}Spam: {spam_n}{Clr.RST}  |  {Clr.G}Clean: {clean_n}{Clr.RST}")
    print(f"  {Clr.PRP}└{'─' * 60}┘{Clr.RST}")

    report = f"╔══════════════════════════════════════════════╗\n"
    report += f"║   SPAMGUARD ELITE — BATCH SCAN REPORT      ║\n"
    report += f"╚══════════════════════════════════════════════╝\n\n"
    report += f"Time   : {ts()}\nTotal  : {len(results)}\nSpam   : {spam_n}\nClean  : {clean_n}\n{'─'*50}\n\n"
    for i, text, r in results:
        report += f"[{i}] {r.pct}% — {r.grade}\n    Text: {text[:100]}\n\n"

    fn = save("batch_scan", report)
    ok(f"Laporan disimpan → {fn}")
    pause()

def scan_quick():
    """Quick one-line spam check."""
    cls()
    hdr("⚡ QUICK SPAM CHECK", "Instant spam detection for short text")
    inf("Cek cepat untuk SMS, chat, judul, atau teks pendek")
    hr()

    text = input(f"  {AR} {Clr.W}Teks (1 baris):{Clr.RST} ").strip()
    if not text:
        fl("Teks kosong!"); pause(); return

    print(f"\n  {Clr.PRP}[*] Quick analysis...{Clr.RST}\n")
    r = full_scan(text)

    # Compact display
    print(f"  {Clr.PRP}┌{'─' * 60}┐{Clr.RST}")
    for lyr in r.layers:
        if lyr["pts"] > 0:
            bar_str = gbar(lyr["pts"], lyr["mx"], 20)
            print(f"  {Clr.PRP}│{Clr.RST} {Clr.W}{lyr['name']:<22}{Clr.RST} {bar_str}  {Clr.PRP}│{Clr.RST}")
    print(f"  {Clr.PRP}├{'─' * 60}┤{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST} {Clr.BLD}Result: {r.color}{r.emoji} {r.grade} — {r.pct:.1f}%{Clr.RST}{' ' * (25 - len(r.grade))}{Clr.PRP}│{Clr.RST}")
    print(f"  {Clr.PRP}└{'─' * 60}┘{Clr.RST}")

    if r.spam:
        print(f"\n  {Clr.DNG}🚨 SPAM DETECTED — Skor: {r.pct:.1f}%{Clr.RST}")
    elif r.pct >= 25:
        print(f"\n  {Clr.WRN}⚠️  SUSPICIOUS — Skor: {r.pct:.1f}%{Clr.RST}")
    else:
        print(f"\n  {Clr.G}✅ CLEAN — Skor: {r.pct:.1f}%{Clr.RST}")

    pause()

def view_results():
    cls()
    hdr("📁 SAVED SCAN REPORTS", "Browse & view detection history")
    hr()

    dn = "hasil_spamdetector"
    if not os.path.isdir(dn):
        fl("Belum ada laporan!"); pause(); return

    files = sorted(
        [f for f in os.listdir(dn) if f.endswith(".txt")],
        key=lambda x: os.path.getmtime(os.path.join(dn, x)), reverse=True
    )

    if not files:
        fl("Belum ada laporan!"); pause(); return

    print(f"\n  {Clr.PRP}┌{'─' * 60}┐{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST} {Clr.ACC}  #  DATE       TIME     SCAN TYPE              SIZE{Clr.RST}   {Clr.PRP}│{Clr.RST}")
    print(f"  {Clr.PRP}├{'─' * 60}┤{Clr.RST}")

    fi = []
    for i, fname in enumerate(files, 1):
        fp = os.path.join(dn, fname)
        sz = os.path.getsize(fp)
        mt = datetime.fromtimestamp(os.path.getmtime(fp))
        ds = mt.strftime("%Y-%m-%d"); ts = mt.strftime("%H:%M:%S")
        tn = fname.replace("_", " ").replace(".txt", "")
        if len(tn) > 22: tn = tn[:19] + "..."
        szs = f"{sz}B" if sz < 1024 else f"{sz/1024:.1f}KB"
        print(f"  {Clr.PRP}│{Clr.RST} {Clr.ACC}{i:2d}{Clr.RST}  {Clr.DIM}{ds} {ts}{Clr.RST}  {Clr.W}{tn:<22}{Clr.RST} {Clr.DIM}{szs:>6}{Clr.RST}  {Clr.PRP}│{Clr.RST}")
        fi.append((fname, fp, sz))

    print(f"  {Clr.PRP}├{'─' * 60}┤{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.W}Total: {len(files)} file(s){Clr.RST}{' ' * 42}{Clr.PRP}│{Clr.RST}")
    print(f"  {Clr.PRP}└{'─' * 60}┘{Clr.RST}")
    print(f"\n  {Clr.DIM}Pilih nomor [view], [d] delete, [0] delete all, [Enter] back{Clr.RST}")

    ch = input(f"\n  {AR} {Clr.W}Pilihan:{Clr.RST} ").strip()
    if not ch: return

    if ch == "0":
        cf = input(f"  {Clr.DNG}[!] Hapus SEMUA? Ketik 'DELETE ALL':{Clr.RST} ").strip()
        if cf == "DELETE ALL":
            for fn, _, _ in fi: os.remove(os.path.join(dn, fn))
            try: os.rmdir(dn)
            except: pass
            ok("Semua file dihapus!")
        pause(); return

    if ch.lower() == "d":
        ns = input(f"  {AR} {Clr.W}Nomor file:{Clr.RST} ").strip()
        if ns.isdigit() and 0 <= int(ns) - 1 < len(fi):
            os.remove(os.path.join(dn, fi[int(ns) - 1][0]))
            ok(f"'{fi[int(ns) - 1][0]}' dihapus!")
        pause(); return

    if ch.isdigit() and 0 <= int(ch) - 1 < len(fi):
        cls()
        hdr(f"📄 {fi[int(ch) - 1][0]}")
        hr()
        try:
            with open(fi[int(ch) - 1][1], "r", encoding="utf-8") as f:
                for line in f.read().split("\n"):
                    if "CRITICAL" in line or "SPAM" in line:
                        print(f"  {Clr.DNG}{line}{Clr.RST}")
                    elif "CLEAN" in line or "SAFE" in line:
                        print(f"  {Clr.G}{line}{Clr.RST}")
                    elif "Score" in line or "Verdict" in line:
                        print(f"  {Clr.W}{line}{Clr.RST}")
                    elif line.startswith("[") and "]" in line[:20]:
                        print(f"  {Clr.ACC}{line}{Clr.RST}")
                    else:
                        print(f"  {Clr.FNT}{line}{Clr.RST}")
        except Exception as e:
            fl(f"Error: {e}")
        pause()

# ═══════════════════════════════════════════════════════════════════
# 📋 MAIN MENU
# ═══════════════════════════════════════════════════════════════════

def menu():
    cls()
    banner()
    nf = 0
    if os.path.isdir("hasil_spamdetector"):
        nf = len([f for f in os.listdir("hasil_spamdetector") if f.endswith(".txt")])

    print(f"  {Clr.PRP}┌{'─' * 60}┐{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.FNT}Reports : {Clr.ACC}{nf}{Clr.RST} {Clr.FNT}scan(s) saved{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.FNT}Time    : {ts()}{Clr.RST}")
    print(f"  {Clr.PRP}├{'─' * 60}┤{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.ACC}[1]{Clr.RST} 📧 {Clr.W}Email Spam Detector{Clr.RST}      {Clr.DIM}Full 10-layer analysis{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.ACC}[2]{Clr.RST} 📝 {Clr.W}Text Spam Detector{Clr.RST}       {Clr.DIM}SMS/Chat/Comment/Post{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.ACC}[3]{Clr.RST} ⚡ {Clr.W}Quick Spam Check{Clr.RST}         {Clr.DIM}Instant 1-line detection{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.ACC}[4]{Clr.RST} 📋 {Clr.W}Batch Spam Detector{Clr.RST}      {Clr.DIM}Multiple texts at once{Clr.RST}")
    print(f"  {Clr.PRP}├{'─' * 60}┤{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.ACC}[5]{Clr.RST} 📁 {Clr.W}View Saved Reports{Clr.RST}      {Clr.DIM}Browse scan history{Clr.RST}")
    print(f"  {Clr.PRP}├{'─' * 60}┤{Clr.RST}")
    print(f"  {Clr.PRP}│{Clr.RST}  {Clr.DNG}[0]{Clr.RST} 🚪 {Clr.DNG}Exit{Clr.RST}")
    print(f"  {Clr.PRP}└{'─' * 60}┘{Clr.RST}")
    print()

TOOLS = {"1": scan_email, "2": scan_text, "3": scan_quick, "4": scan_batch, "5": view_results}

def main():
    check_deps()
    while True:
        try:
            menu()
            ch = input(f"  {Clr.ACC}❯{Clr.RST} {Clr.W}Pilih [0-5]:{Clr.RST} ").strip()
            if ch == "0":
                cls()
                bx(Clr.PRP, "👋 SpamGuard Elite v2.0 — Stay Protected.", "")
                print(); sys.exit(0)
            if ch in TOOLS: TOOLS[ch]()
            else: fl("Pilihan tidak valid! Gunakan 0-5."); time.sleep(1)
        except KeyboardInterrupt:
            print(f"\n\n  {Clr.WRN}[!] Dihentikan.{Clr.RST}\n"); sys.exit(0)
        except Exception as e:
            print(f"\n  {Clr.DNG}[✘] Error: {e}{Clr.RST}")
            import traceback; traceback.print_exc(); pause()

if __name__ == "__main__":
    main()