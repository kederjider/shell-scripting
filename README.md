# Shell Scripting Collection

Kumpulan shell script untuk automasi server Linux.

# 1️⃣ Generate SSH key (kalau belum punya)

**_Cek dulu:_**

<pre><code>ls ~/.ssh/id_ed25519.pub
</code></pre>

**_Kalau belum ada, buat::_**

<pre><code>ssh-keygen -t ed25519 -C "email_kamu@example.com"
</code></pre>

# 2️⃣ Tambahkan SSH key ke GitHub

**_Tampilkan public key:_**

<pre><code>cat ~/.ssh/id_ed25519.pub
</code></pre>

**_Copy semua isinya, lalu:_**
**_Buka GitHub_**
**_Settings → SSH and GPG keys_**
**_New SSH key_**
**_Paste → Save:_**

# 3️⃣ Test koneksi SSH ke GitHub

<pre><code>ssh -T git@github.com
</code></pre>

**_Kalau sukses:_**
**_Hi username! You've successfully authenticated..._**

# zerotier

**_jangan lupa jalankan di root_**
**_Install Script Di Bawa Ini untuk mempermudah penggunaan zerotier_**

<pre><code>apt update && apt upgrade -y && apt install -y wget curl sed && sleep 2 && wget -O /usr/local/bin/zerotier https://raw.githubusercontent.com/kederjider/shell-scripting/refs/heads/main/zerotier.sh && chmod +x /usr/local/bin/zerotier && zerotier

</code></pre>
