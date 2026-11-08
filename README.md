# CyberShield — Sistem Pemantauan Keamanan Jaringan

Aplikasi web untuk **memantau aktivitas jaringan, mengelola aturan firewall, dan
menampilkan simulasi ancaman keamanan jaringan**.
Dibuat untuk UTS Keamanan Jaringan (Teknik Informatika, Kelas 3TI01).

## Tautan Aplikasi (Live)
Aplikasi dapat langsung dibuka di browser melalui GitHub Pages:

**https://fiant2.github.io/cybershield/**

## Fitur Utama
1. **Dashboard Monitoring** — total paket diperiksa, koneksi diizinkan, ancaman
   diblokir, jumlah aturan firewall aktif, grafik volume traffic waktu nyata,
   port paling sering diblokir, dan peringatan keamanan terkini.
2. **Manajemen Aturan Firewall** — tambah aturan (IP, port, protokol, tindakan),
   aktif/nonaktifkan aturan dengan tombol geser, dan hapus aturan.
3. **Simulasi Traffic dan Serangan** — pembangkit traffic jaringan otomatis,
   uji koneksi manual (diizinkan/diblokir beserta alasannya), serta simulasi
   serangan DDoS Flood, Port Scanning, Brute Force SSH, dan Malware C2.
4. **Log Keamanan** — mencatat waktu, IP sumber, port tujuan, jenis aktivitas,
   dan tindakan sistem; dilengkapi filter, ekspor CSV, dan hapus log.
5. **Blacklist IP** — daftar IP terblokir; tambah dan lepas IP. IP blacklist
   selalu diblokir mendahului semua aturan firewall.

## Cara Menjalankan

### Mode A — Langsung (tanpa server)
Cukup buka file **`index.html`** di browser (Chrome/Edge/Firefox).
Seluruh fitur berfungsi penuh; data (aturan, log, blacklist) tersimpan di
penyimpanan lokal browser (localStorage), dan `database.sql` menjadi rancangan
basis data resminya.

### Mode B — XAMPP (PHP + MySQL)
1. Salin folder ini ke `htdocs` XAMPP, lalu nyalakan **Apache** dan **MySQL**.
2. Buka **phpMyAdmin**, lalu impor file **`database.sql`**
   (membuat database `cybershield` beserta tabel `firewall_rules`,
   `security_logs`, dan `blacklist_ips` lengkap dengan data awal).
3. Backend tersedia di **`api.php`** (JSON API, lihat komentar di dalam file)
   dengan konfigurasi koneksi pada **`config.php`**.
4. Buka `http://localhost/cybershield/` untuk menjalankan aplikasi.

## Struktur File
| File | Keterangan |
|---|---|
| `index.html` | Aplikasi utama (HTML, CSS, JavaScript) — seluruh antarmuka & logika |
| `database.sql` | Skema dan data awal database MySQL |
| `config.php` | Konfigurasi koneksi database (PDO) |
| `api.php` | Backend API CRUD untuk mode server |
| `README.md` | Dokumen ini |

## Alur Pemeriksaan Paket
Setiap paket/koneksi yang masuk dievaluasi dengan urutan:
1. **Blacklist** — jika IP sumber terdaftar, langsung **DIBLOKIR**.
2. **Aturan firewall aktif** — aturan pertama yang cocok (IP, port, protokol)
   menentukan tindakan **IZINKAN** atau **BLOKIR**.
3. **Kebijakan default** — jika tidak ada aturan yang cocok, koneksi **DIIZINKAN**
   dan dicatat alasannya di log.
4. Khusus simulasi DDoS berlaku **batas laju (rate limiting)**: satu IP yang
   mengirim paket berlebih ke port yang sama akan diblokir otomatis.

## Pengujian yang Dilakukan
- Koneksi yang diizinkan: SSH dari 192.168.1.10:22 → **DIIZINKAN**
  (aturan "Izinkan SSH Admin").
- Koneksi yang diblokir: SSH dari IP eksternal :22 → **DIBLOKIR**
  (aturan "Blokir SSH Eksternal"); Telnet :23 → **DIBLOKIR**.
- IP blacklist (185.220.101.4) ke semua port → **DIBLOKIR**.
- Simulasi serangan DDoS, port scanning, brute force, dan malware C2 —
  hasil dan pencatatan log terverifikasi di halaman Log Keamanan.
