#!/usr/bin/env python3
"""Cari alamat IP yang terhubung dengan sebuah domain/subdomain secara detail."""

from __future__ import annotations

import re
import socket
import sys
from datetime import datetime
from pathlib import Path

import requests


TIMEOUT = 15
GOOGLE_DOH_API = "https://dns.google/resolve"
HACKERTARGET_API = "https://api.hackertarget.com/hostsearch/"
OUTPUT_DIR = Path("hasil_host_to_ip")

# Kode jenis record DNS
TYPE_A = 1
TYPE_CNAME = 5
TYPE_AAAA = 28
TYPE_NAMES = {TYPE_A: "A", TYPE_CNAME: "CNAME", TYPE_AAAA: "AAAA"}

# Validasi nama domain: label alfanumerik, TLD minimal 2 huruf
DOMAIN_RE = re.compile(
    r"^(?=.{1,253}$)"
    r"(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+"
    r"[a-zA-Z]{2,}$"
)


def clean_input(value: str) -> str:
	"""Bersihkan input: buang skema URL, jalur, port, dan spasi."""
	value = value.strip().lower()
	value = re.sub(r"^[a-z]+://", "", value)  # http://, https://
	value = value.split("/", 1)[0]  # buang jalur
	value = value.split(":", 1)[0]  # buang port
	return value.rstrip(".")


def validate_domain(value: str) -> str:
	"""Validasi input dan kembalikan nama domain yang bersih."""
	domain = clean_input(value)
	if not DOMAIN_RE.match(domain):
		raise ValueError("Input bukan nama domain/subdomain yang valid.")
	return domain


def is_base_domain(domain: str) -> bool:
	"""Perkirakan apakah input adalah domain utama (bukan subdomain).

	Contoh: google.com (ya), co.id (ya), example.co.id (ya), www.google.com (tidak).
	"""
	labels = domain.split(".")
	return len(labels) <= 2 or (len(labels) == 3 and len(labels[-1]) == 2)


def resolve_local(domain: str) -> set[tuple[str, int]]:
	"""Resolusi langsung via resolver sistem untuk record A dan AAAA."""
	results: set[tuple[str, int]] = set()
	for socktype, rtype in ((socket.AF_INET, TYPE_A), (socket.AF_INET6, TYPE_AAAA)):
		try:
			infos = socket.getaddrinfo(domain, None, socktype)
		except socket.gaierror:
			continue
		for info in infos:
			results.add((str(info[4][0]), rtype))
	return results


def doh_lookup(domain: str, rtype: int) -> list[dict]:
	"""Resolusi detail via Google DNS over HTTPS (format JSON)."""
	response = requests.get(
		GOOGLE_DOH_API,
		params={"name": domain, "type": rtype},
		timeout=TIMEOUT,
	)
	response.raise_for_status()
	data = response.json()
	if data.get("Status") != 0:
		return []
	return list(data.get("Answer", []))


def host_search(domain: str) -> list[tuple[str, str]]:
	"""Cari semua host/subdomain terkait beserta IP-nya via HackerTarget."""
	response = requests.get(HACKERTARGET_API, params={"q": domain}, timeout=TIMEOUT)
	response.raise_for_status()
	body = response.text.strip()
	if not body or body.lower().startswith(("error", "api count exceeded")):
		return []

	pairs: list[tuple[str, str]] = []
	for line in body.splitlines():
		if "," in line:
			host, ip = line.split(",", 1)
			host, ip = host.strip(), ip.strip()
			if host and ip:
				pairs.append((host, ip))
	return pairs


def save_results(domain: str, lines: list[str]) -> Path:
	"""Simpan hasil ke ./hasil_host_to_ip/<domain>.txt; buat direktori bila belum ada."""
	OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
	output_file = OUTPUT_DIR / f"{domain}.txt"
	output_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
	return output_file


def main() -> int:
	print("=" * 58)
	print("                  HOST TO IP LOOKUP")
	print("=" * 58)

	try:
		domain = validate_domain(input("Masukkan domain/subdomain: "))
	except ValueError as exc:
		print(f"[ERROR] {exc}")
		return 1

	print(f"\n[INFO] Memindai koneksi IP untuk: {domain} ...")

	# --- 1) Pengumpulan data ---
	local = resolve_local(domain)

	doh_answers: list[dict] = []
	doh_error: str | None = None
	try:
		for rtype in (TYPE_A, TYPE_AAAA):
			doh_answers.extend(doh_lookup(domain, rtype))
	except requests.RequestException as exc:
		doh_error = f"Google DoH gagal: {exc}"

	pairs: list[tuple[str, str]] = []
	hostsearch_error: str | None = None
	if is_base_domain(domain):
		try:
			pairs = host_search(domain)
		except requests.RequestException as exc:
			hostsearch_error = f"HackerTarget gagal: {exc}"

	# --- 2) Susun laporan ---
	lines: list[str] = []
	lines.append("=" * 58)
	lines.append(f"  HASIL HOST-TO-IP: {domain}")
	lines.append("=" * 58)
	lines.append(f"Waktu pemindaian : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
	lines.append("")

	# 2a) Resolusi lokal
	lines.append("[1] Resolusi DNS lokal (A/AAAA)")
	lines.append("-" * 58)
	if local:
		for ip, rtype in sorted(local):
			kind = "IPv4 (A)" if rtype == TYPE_A else "IPv6 (AAAA)"
			lines.append(f"    {ip:<45} {kind}")
	else:
		lines.append("    (tidak ada hasil)")
	lines.append("")

	# 2b) Google DoH
	lines.append("[2] Google DNS over HTTPS (detail + CNAME)")
	lines.append("-" * 58)
	if doh_error:
		lines.append(f"    [PERINGATAN] {doh_error}")
	elif doh_answers:
		for answer in doh_answers:
			record_type = int(answer.get("type", 0) or 0)
			rtype_name = TYPE_NAMES.get(record_type, "?")
			name = str(answer.get("name", "")).rstrip(".")
			data = str(answer.get("data", "")).rstrip(".")
			ttl = answer.get("TTL", "?")
			lines.append(f"    {rtype_name:<6} {name:<45} -> {data}   (TTL {ttl})")
	else:
		lines.append("    (tidak ada hasil)")
	lines.append("")

	# 2c) HackerTarget hostsearch
	if is_base_domain(domain):
		lines.append(f"[3] HackerTarget hostsearch ({len(pairs)} host terkait)")
		lines.append("-" * 58)
		if hostsearch_error:
			lines.append(f"    [PERINGATAN] {hostsearch_error}")
		elif pairs:
			for host, ip in pairs:
				lines.append(f"    {host:<48} -> {ip}")
		else:
			lines.append("    (tidak ada hasil)")
		lines.append("")

	# 2d) Ringkasan IP unik
	all_ips: set[str] = set()
	for ip, _ in local:
		all_ips.add(ip)
	for answer in doh_answers:
		if answer.get("type") in (TYPE_A, TYPE_AAAA):
			all_ips.add(str(answer.get("data", "")).rstrip("."))
	for _, ip in pairs:
		all_ips.add(ip)
	all_ips.discard("")

	lines.append("=" * 58)
	lines.append(f"RINGKASAN: {len(all_ips)} IP unik terhubung dengan {domain}")
	for ip in sorted(all_ips):
		lines.append(f"    - {ip}")

	# --- 3) Tampilkan di terminal (batasi hostsearch agar tidak membanjiri layar) ---
	display = list(lines)
	if pairs and len(pairs) > 60:
		# potong bagian hostsearch pada tampilan, sisanya lengkap di file
		cut = display.index(f"[3] HackerTarget hostsearch ({len(pairs)} host terkait)")
		display = display[:cut + 2] + [
			f"    ... menampilkan 60 dari {len(pairs)} host (lengkap di file hasil)."
		] + display[-8:]

	print("\n" + "\n".join(display))

	output_file = save_results(domain, lines)
	print(f"\n[INFO] Hasil disimpan di: {output_file}")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except KeyboardInterrupt:
		print("\nDibatalkan oleh pengguna.")
		sys.exit(130)
