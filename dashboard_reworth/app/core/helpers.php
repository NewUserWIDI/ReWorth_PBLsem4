<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/app.php';

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function url(string $path): string
{
    return rtrim(APP_BASE_URL, '/') . '/' . ltrim($path, '/');
}

function redirect(string $path): never
{
    header('Location: ' . url($path));
    exit;
}

function set_flash(string $type, string $message): void
{
    $_SESSION['flash'] = ['type' => $type, 'message' => $message];
}

function get_flash(): ?array
{
    $flash = $_SESSION['flash'] ?? null;
    unset($_SESSION['flash']);
    return $flash;
}

function status_label(string $status): string
{
    $normalized = strtolower(trim($status));

    return match ($normalized) {
        'menunggu_verifikasi' => 'Menunggu Verifikasi',
        'menunggu pembayaran' => 'Menunggu Pembayaran',
        'menunggu' => 'Menunggu',
        'valid' => 'Valid',
        'ditolak' => 'Ditolak',
        'diproses' => 'Diproses',
        'dikemas' => 'Dikemas',
        'dikirim' => 'Dikirim',
        'selesai' => 'Selesai',
        'pending' => 'Pending',
        'aktif' => 'Aktif',
        'nonaktif' => 'Nonaktif',
        'baru' => 'Baru',
        'dibatalkan' => 'Dibatalkan',
        'berhasil' => 'Berhasil',
        'belum upload' => 'Belum Upload',
        'belum dibayar' => 'Belum Dibayar',
        'kadaluarsa' => 'Kadaluarsa',
        'gagal' => 'Gagal',
        'terverifikasi' => 'Terverifikasi',
        'disembunyikan' => 'Disembunyikan',
        'suspend' => 'Suspend',
        'refund' => 'Refund',
        'tertahan' => 'Tertahan',
        'tersedia' => 'Tersedia',
        default => ucwords(str_replace('_', ' ', $status)),
    };
}

function status_badge_class(string $status): string
{
    $normalized = strtolower(trim($status));

    return match ($normalized) {
        'valid', 'aktif', 'selesai', 'terverifikasi', 'berhasil', 'tersedia' => 'badge-success',
        'menunggu_verifikasi', 'pending', 'menunggu', 'baru', 'dikemas', 'menunggu pembayaran', 'belum upload', 'belum dibayar' => 'badge-warning',
        'ditolak', 'gagal', 'dibatalkan', 'nonaktif', 'suspend', 'kadaluarsa' => 'badge-danger',
        'disembunyikan', 'refund' => 'badge-neutral',
        'diproses', 'dikirim', 'tertahan' => 'badge-info',
        default => 'badge-neutral',
    };
}

