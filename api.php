<?php
// ============================================================
//  CyberShield — API backend (PHP + MySQL)
//  Menyediakan operasi CRUD untuk tabel firewall_rules,
//  security_logs, dan blacklist_ips dalam format JSON.
//
//  Contoh pemanggilan:
//    api.php?action=rules_list
//    api.php?action=rules_add     (POST: nama, ip_sumber, port, protokol, aksi)
//    api.php?action=rules_toggle  (POST: id)
//    api.php?action=rules_delete  (POST: id)
//    api.php?action=logs_list
//    api.php?action=logs_add      (POST: ip_sumber, port_tujuan, jenis_aktivitas, tindakan, keterangan)
//    api.php?action=logs_clear
//    api.php?action=blacklist_list
//    api.php?action=blacklist_add    (POST: ip_address, alasan)
//    api.php?action=blacklist_delete (POST: ip_address)
//
//  Catatan: antarmuka utama (index.html) dapat berjalan mandiri
//  tanpa server (mode simulasi localStorage). API ini disediakan
//  untuk mode penyimpanan berbasis server sesuai petunjuk soal.
// ============================================================
require __DIR__ . '/config.php';
header('Content-Type: application/json');

$action = $_GET['action'] ?? '';
$in = array_merge($_GET, $_POST);

function out($data) { echo json_encode($data); exit; }

switch ($action) {

    /* ---------- Aturan Firewall ---------- */
    case 'rules_list':
        out($pdo->query("SELECT * FROM firewall_rules ORDER BY id")->fetchAll());

    case 'rules_add':
        $st = $pdo->prepare("INSERT INTO firewall_rules (nama, ip_sumber, port, protokol, aksi, aktif)
                             VALUES (:nama, :ip, :port, :proto, :aksi, 1)");
        $st->execute([
            ':nama'  => $in['nama'] ?? '',
            ':ip'    => $in['ip_sumber'] ?? 'Semua',
            ':port'  => $in['port'] ?? 'Semua',
            ':proto' => $in['protokol'] ?? 'TCP',
            ':aksi'  => $in['aksi'] ?? 'IZINKAN',
        ]);
        out(['ok' => true, 'id' => $pdo->lastInsertId()]);

    case 'rules_toggle':
        $st = $pdo->prepare("UPDATE firewall_rules SET aktif = 1 - aktif WHERE id = :id");
        $st->execute([':id' => (int)($in['id'] ?? 0)]);
        out(['ok' => true]);

    case 'rules_delete':
        $st = $pdo->prepare("DELETE FROM firewall_rules WHERE id = :id");
        $st->execute([':id' => (int)($in['id'] ?? 0)]);
        out(['ok' => true]);

    /* ---------- Log Keamanan ---------- */
    case 'logs_list':
        out($pdo->query("SELECT * FROM security_logs ORDER BY waktu DESC LIMIT 300")->fetchAll());

    case 'logs_add':
        $st = $pdo->prepare("INSERT INTO security_logs (waktu, ip_sumber, port_tujuan, jenis_aktivitas, tindakan, keterangan)
                             VALUES (NOW(), :ip, :port, :aktivitas, :tindakan, :keterangan)");
        $st->execute([
            ':ip'         => $in['ip_sumber'] ?? '',
            ':port'       => (int)($in['port_tujuan'] ?? 0),
            ':aktivitas'  => $in['jenis_aktivitas'] ?? '',
            ':tindakan'   => $in['tindakan'] ?? 'IZINKAN',
            ':keterangan' => $in['keterangan'] ?? '',
        ]);
        out(['ok' => true, 'id' => $pdo->lastInsertId()]);

    case 'logs_clear':
        $pdo->exec("DELETE FROM security_logs");
        out(['ok' => true]);

    /* ---------- Blacklist IP ---------- */
    case 'blacklist_list':
        out($pdo->query("SELECT * FROM blacklist_ips ORDER BY tanggal_diblokir DESC")->fetchAll());

    case 'blacklist_add':
        $st = $pdo->prepare("INSERT INTO blacklist_ips (ip_address, alasan, tanggal_diblokir)
                             VALUES (:ip, :alasan, CURDATE())
                             ON DUPLICATE KEY UPDATE alasan = VALUES(alasan)");
        $st->execute([
            ':ip'     => $in['ip_address'] ?? '',
            ':alasan' => $in['alasan'] ?? '',
        ]);
        out(['ok' => true]);

    case 'blacklist_delete':
        $st = $pdo->prepare("DELETE FROM blacklist_ips WHERE ip_address = :ip");
        $st->execute([':ip' => $in['ip_address'] ?? '']);
        out(['ok' => true]);

    default:
        http_response_code(400);
        out(['error' => 'Action tidak dikenal.']);
}
