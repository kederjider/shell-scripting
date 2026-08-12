#!/usr/bin/env python3

import subprocess
import sys
import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import getpass

# ================== AUTO INSTALL LIBRARY ==================
def install_package(package):
    try:
        __import__(package.replace("-", "_"))  # secure-smtplib → secure_smtplib
        print(f"✅ {package} sudah terinstall")
        return
    except ImportError:
        print(f"📦 {package} belum terinstall, sedang menginstall...")

    try:
        # Tambahkan opsi untuk menghindari warning root
        cmd = [sys.executable, "-m", "pip", "install", package, "--root-user-action=ignore"]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✅ {package} berhasil diinstall")
        else:
            print(f"❌ Gagal menginstall {package}")
            print(result.stderr)
            sys.exit(1)
            
    except Exception as e:
        print(f"❌ Error saat menginstall: {e}")
        sys.exit(1)

# Install library
install_package("secure-smtplib")

# ================== PROGRAM UTAMA ==================
def kirim_email():
    print("=== Program Pengirim Email HTML Cantik ===\n")
    
    # Login Gmail
    #sender_email = input("Masukkan email pengirim (Gmail): ").strip()
    #password = getpass.getpass("Masukkan App Password Gmail: ")
    sender_email = "berkelana.dimys@gmail.com"
    password = "vsyg wwyp hcon hfsr"
    
    # Input penerima
    receiver_email = input("\nMasukkan email penerima: ").strip()
    
    # Input subject
    subject = input("Masukkan subject email: ").strip()
    
    # Input isi pesan HTML
    print("\nMasukkan isi pesan HTML (bisa multi-line). Ketik 'SELESAI' di baris baru untuk selesai:")
    lines = []
    while True:
        line = input()
        if line.strip().upper() == "SELESAI":
            break
        lines.append(line)
    
    body_text = "\n".join(lines)

    # ================== TEMPLATE HTML CANTIK ==================
    html = f"""
    <!DOCTYPE html>
    <html lang="id">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{subject}</title>
        <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7fa; margin: 0; padding: 20px; }}
            .container {{ max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }}
            .header {{ background: linear-gradient(135deg, #1e3a8a, #3b82f6); color: white; padding: 30px 40px; text-align: center; }}
            .content {{ padding: 40px; line-height: 1.7; color: #333; }}
            .title {{ font-size: 28px; font-weight: bold; margin: 20px 0; color: #1e3a8a; }}
            .box {{ background-color: #f8fafc; border-left: 5px solid #3b82f6; padding: 20px; margin: 20px 0; border-radius: 8px; }}
            .button {{ display: inline-block; background-color: #2563eb; color: white; padding: 14px 32px; text-decoration: none; border-radius: 50px; font-weight: bold; margin: 20px 0; }}
            .footer {{ text-align: center; padding: 25px; color: #666; font-size: 14px; border-top: 1px solid #eee; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>✉️ Email Profesional</h1>
            </div>
            <div class="content">
                <h2 class="title">{subject}</h2>
                {body_text}
                
                <div style="text-align: center;">
                    <a href="https://t.me/tuan_mubot" class="button">Klik Disini</a>
                </div>
            </div>
            <div class="footer">
                Email ini dikirim secara otomatis, harap tidak membalas.
            </div>
        </div>
    </body>
    </html>
    """

    # ================== KIRIM EMAIL ==================
    msg = MIMEMultipart("alternative")
    msg["From"] = sender_email
    msg["To"] = receiver_email
    msg["Subject"] = subject
    msg.attach(MIMEText(html, "html"))

    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()
        print("\n✅ Email berhasil dikirim dengan sukses!")
        
    except Exception as e:
        print(f"\n❌ Gagal mengirim email: {e}")
        print("Tips: Pastikan Anda menggunakan App Password Gmail.")

if __name__ == "__main__":
    kirim_email()