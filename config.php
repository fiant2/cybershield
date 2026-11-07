<?php
// ============================================================
//  CyberShield — Konfigurasi koneksi database (PDO MySQL)
//  Sesuaikan dengan pengaturan XAMPP/MySQL Anda.
// ============================================================
$DB_HOST = 'localhost';
$DB_NAME = 'cybershield';
$DB_USER = 'root';
$DB_PASS = '';          // default XAMPP: kosong

try {
    $pdo = new PDO(
        "mysql:host=$DB_HOST;dbname=$DB_NAME;charset=utf8mb4",
        $DB_USER,
        $DB_PASS,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
         PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
    );
} catch (PDOException $e) {
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Koneksi database gagal: ' . $e->getMessage()]);
    exit;
}
