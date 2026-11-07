-- ============================================================
--  CyberShield — Database Keamanan Jaringan
--  UTS Keamanan Jaringan | Teknik Informatika | Kelas 3TI01
--  Cara pakai: impor file ini melalui phpMyAdmin (XAMPP)
--  atau jalankan perintah: mysql -u root < database.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS cybershield
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cybershield;

-- ------------------------------------------------------------
-- 1) Tabel aturan firewall
--    port disimpan VARCHAR agar mendukung nilai 'Semua'
-- ------------------------------------------------------------
DROP TABLE IF EXISTS firewall_rules;
CREATE TABLE firewall_rules (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nama        VARCHAR(100) NOT NULL,
  ip_sumber   VARCHAR(45)  NOT NULL DEFAULT 'Semua',
  port        VARCHAR(10)  NOT NULL DEFAULT 'Semua',
  protokol    ENUM('TCP','UDP','Semua') NOT NULL DEFAULT 'TCP',
  aksi        ENUM('IZINKAN','BLOKIR')  NOT NULL,
  aktif       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO firewall_rules (nama, ip_sumber, port, protokol, aksi, aktif) VALUES
('Izinkan SSH Admin',        '192.168.1.10',  '22',   'TCP',   'IZINKAN', 1),
('Blokir SSH Eksternal',     'Semua',         '22',   'TCP',   'BLOKIR',  1),
('Izinkan HTTP',             'Semua',         '80',   'TCP',   'IZINKAN', 1),
('Izinkan HTTPS',            'Semua',         '443',  'TCP',   'IZINKAN', 1),
('Izinkan DNS',              'Semua',         '53',   'UDP',   'IZINKAN', 1),
('Blokir Telnet',            'Semua',         '23',   'TCP',   'BLOKIR',  1),
('Blokir Port Malware C2',   'Semua',         '4444', 'TCP',   'BLOKIR',  1),
('Blokir IP Mencurigakan',   '45.155.204.77', 'Semua','Semua', 'BLOKIR',  1),
('Izinkan Database Internal','192.168.1.25',  '3306', 'TCP',   'IZINKAN', 0);

-- ------------------------------------------------------------
-- 2) Tabel log keamanan
-- ------------------------------------------------------------
DROP TABLE IF EXISTS security_logs;
CREATE TABLE security_logs (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  waktu           DATETIME NOT NULL,
  ip_sumber       VARCHAR(45)  NOT NULL,
  port_tujuan     INT NOT NULL,
  jenis_aktivitas VARCHAR(100) NOT NULL,
  tindakan        ENUM('IZINKAN','BLOKIR') NOT NULL,
  keterangan      VARCHAR(255) DEFAULT NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO security_logs (waktu, ip_sumber, port_tujuan, jenis_aktivitas, tindakan, keterangan) VALUES
(NOW() - INTERVAL 1 MINUTE,  '192.168.1.14',  443,  'Akses Web Aman (HTTPS)',  'IZINKAN', 'Aturan: Izinkan HTTPS'),
(NOW() - INTERVAL 3 MINUTE,  '203.0.113.45',  80,   'DDoS Flood',              'BLOKIR',  'IP masuk blacklist'),
(NOW() - INTERVAL 5 MINUTE,  '192.168.1.10',  22,   'Koneksi SSH Admin',       'IZINKAN', 'Aturan: Izinkan SSH Admin'),
(NOW() - INTERVAL 8 MINUTE,  '77.83.21.150',  23,   'Percobaan Telnet',        'BLOKIR',  'Aturan: Blokir Telnet'),
(NOW() - INTERVAL 11 MINUTE, '192.168.1.31',  53,   'Permintaan DNS',          'IZINKAN', 'Aturan: Izinkan DNS'),
(NOW() - INTERVAL 14 MINUTE, '45.155.204.77', 8080, 'Akses Tidak Dikenal',     'BLOKIR',  'Aturan: Blokir IP Mencurigakan'),
(NOW() - INTERVAL 19 MINUTE, '185.220.101.4', 3389, 'Port Scanning',           'BLOKIR',  'IP masuk blacklist'),
(NOW() - INTERVAL 24 MINUTE, '103.147.9.88',  4444, 'Komunikasi Malware C2',   'BLOKIR',  'Aturan: Blokir Port Malware C2'),
(NOW() - INTERVAL 29 MINUTE, '192.168.1.22',  80,   'Akses Web (HTTP)',        'IZINKAN', 'Aturan: Izinkan HTTP');

-- ------------------------------------------------------------
-- 3) Tabel blacklist IP
-- ------------------------------------------------------------
DROP TABLE IF EXISTS blacklist_ips;
CREATE TABLE blacklist_ips (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  ip_address       VARCHAR(45) NOT NULL UNIQUE,
  alasan           VARCHAR(255) DEFAULT NULL,
  tanggal_diblokir DATE NOT NULL,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO blacklist_ips (ip_address, alasan, tanggal_diblokir) VALUES
('203.0.113.45',  'Serangan DDoS terdistribusi',    '2026-11-02'),
('198.51.100.23', 'Port scanning berulang',         '2026-11-04'),
('185.220.101.4', 'Percobaan brute force berulang', '2026-11-05');
