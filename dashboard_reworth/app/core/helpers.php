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

function asset_url(string $path): string
{
    $scriptName = (string) ($_SERVER['SCRIPT_NAME'] ?? '');
    $assetPath = str_contains($scriptName, '/public/') ? 'assets/' . ltrim($path, '/') : 'public/assets/' . ltrim($path, '/');

    return url($assetPath);
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
    return match ($status) {
        'menunggu_verifikasi' => 'Menunggu Verifikasi',
        'valid' => 'Valid',
        'ditolak' => 'Ditolak',
        'diproses' => 'Diproses',
        'selesai' => 'Selesai',
        'pending' => 'Pending',
        'aktif' => 'Aktif',
        'nonaktif' => 'Nonaktif',
        'baru' => 'Baru',
        'dikirim' => 'Dikirim',
        'dibatalkan' => 'Dibatalkan',
        'menunggu' => 'Menunggu',
        'gagal' => 'Gagal',
        default => ucwords(str_replace('_', ' ', $status)),
    };
}

function status_badge_class(string $status): string
{
    return match ($status) {
        'valid', 'aktif', 'selesai' => 'badge-success',
        'menunggu_verifikasi', 'pending', 'menunggu', 'baru' => 'badge-warning',
        'ditolak', 'gagal', 'dibatalkan', 'nonaktif' => 'badge-danger',
        'diproses', 'dikirim' => 'badge-info',
        default => 'badge-neutral',
    };
}
