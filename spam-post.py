import requests
import subprocess
import sys
from time import sleep

# Warna untuk tampilan modern
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

def print_banner():
    print(Colors.CYAN + """
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     🚀 FREEFIRE CHECKER TOOL - PYTHON REQUESTS             ║
║     Made with ❤️ for modern & clean experience             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
""" + Colors.RESET)

def safe_preview(text, max_length=400):
    """Membersihkan preview response"""
    try:
        # Hapus karakter aneh
        cleaned = ''.join(char for char in text if char.isprintable() or char in '\n\r\t')
        return cleaned[:max_length]
    except:
        return text[:max_length]

def main():
    print_banner()
    print(Colors.YELLOW + "🔄 Memulai proses request...\n" + Colors.RESET)
    
    session = requests.Session()
    
    # === HEADERS GET ===
    headers_get = {
        'Host': 'cdabfbwi.townnd.web.id',
        'Cookie': 'PHPSESSID=29d078daba0800b30ba6c11f82e5b12d',
        'Sec-Ch-Ua': '"Not-A.Brand";v="24", "Chromium";v="146"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"Windows"',
        'Accept-Language': 'en-US,en;q=0.9',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Sec-Fetch-Site': 'same-origin',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Dest': 'document',
        'Referer': 'https://cdabfbwi.townnd.web.id/',
        'Accept-Encoding': 'gzip, deflate, br',
        'Priority': 'u=0, i'
    }
    
    url = "https://cdabfbwi.townnd.web.id"
    
    try:
        print(Colors.CYAN + "🌐 Mengirim GET request ke halaman utama..." + Colors.RESET)
        response_get = session.get(url, headers=headers_get, timeout=15)
        print(Colors.YELLOW + f"   Status GET : {response_get.status_code}" + Colors.RESET)
        
        # === HEADERS POST ===
        headers_post = {
            'Host': 'cdabfbwi.townnd.web.id',
            'Cookie': 'PHPSESSID=29d078daba0800b30ba6c11f82e5b12d',
            'Sec-Ch-Ua-Platform': '"Windows"',
            'Accept-Language': 'en-US,en;q=0.9',
            'Sec-Ch-Ua': '"Not-A.Brand";v="24", "Chromium";v="146"',
            'Sec-Ch-Ua-Mobile': '?0',
            'X-Requested-With': 'XMLHttpRequest',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'Origin': 'https://cdabfbwi.townnd.web.id',
            'Sec-Fetch-Site': 'same-origin',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Dest': 'empty',
            'Referer': 'https://cdabfbwi.townnd.web.id/',
            'Accept-Encoding': 'gzip, deflate, br',
            'Priority': 'u=1, i',
            'Connection': 'keep-alive'
        }
        
        data = {
            'validateEmail': 'kontol@asu.crot',
            'validatePassword': 'kontol@asu.crot',
            'validateUserid': '53632653',
            'validateZoneid': '',
            'usernameFF': 'ytap',
            'phone': '9832863723278',
            'level': '100',
            'tier': 'Grand Master',
            'validateLogin': 'Google Play',
            'mailverif': 'kontol@cort.ah',
            'game': 'freefire'
        }
        
        print(Colors.CYAN + "📤 Mengirim POST request ke check.php..." + Colors.RESET)
        response_post = session.post(f"{url}/check.php", headers=headers_post, data=data, timeout=15)
        
        print(Colors.YELLOW + f"   Status POST: {response_post.status_code}" + Colors.RESET)
        
        if response_post.status_code == 200:
            print(Colors.GREEN + "\n✅ BERHASIL!" + Colors.RESET)
            print(Colors.GREEN + "   Request berhasil diproses dengan baik ✨\n" + Colors.RESET)
            
            # Preview response yang sudah dibersihkan
            preview = safe_preview(response_post.text)
            if preview.strip():
                print(Colors.CYAN + "📋 Response preview:" + Colors.RESET)
                print(Colors.YELLOW + "respon txt❌disable" + Colors.RESET)
                #print(preview)
            else:
                print(Colors.YELLOW + "📋 Response kosong atau hanya berisi data binary." + Colors.RESET)
        else:
            print(Colors.RED + "\n❌ GAGAL!" + Colors.RESET)
            print(Colors.RED + f"   Status code: {response_post.status_code}" + Colors.RESET)
            
    except Exception as e:
        print(Colors.RED + f"\n⚠️  Error: {str(e)}" + Colors.RESET)
    
    print(Colors.CYAN + "\n🏁 Program selesai. Terima kasih! 👋" + Colors.RESET)
    
# ================== AUTO INSTALL LIBRARY ==================
def install_package(package):
    try:
        __import__(package.replace("-", "_"))  # secure-smtplib → secure_smtplib
        #print(f"✅ {package} sudah terinstall")
        pass
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


if __name__ == "__main__":
    try:
        # Install library
        install_package("requests")
        main()
    except KeyboardInterrupt:
        print(Colors.YELLOW + "\n\n👋 Program dihentikan oleh user." + Colors.RESET)
        sys.exit(0)