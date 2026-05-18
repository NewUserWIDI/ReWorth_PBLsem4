<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/app.php';

/*
|--------------------------------------------------------------------------
| Escape HTML
|--------------------------------------------------------------------------
*/

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

/*
|--------------------------------------------------------------------------
| URL Helper
|--------------------------------------------------------------------------
*/

function url(string $path): string
{
    return rtrim(APP_BASE_URL, '/') . '/' . ltrim($path, '/');
}

/*
|--------------------------------------------------------------------------
| Redirect Helper
|--------------------------------------------------------------------------
*/

function redirect(string $path): never
{
    header('Location: ' . url($path));
    exit;
}

/*
|--------------------------------------------------------------------------
| Flash Message
|--------------------------------------------------------------------------
*/

function set_flash(string $type, string $message): void
{
    $_SESSION['flash'] = [
        'type' => $type,
        'message' => $message,
    ];
}

function get_flash(): ?array
{
    $flash = $_SESSION['flash'] ?? null;

    unset($_SESSION['flash']);

    return $flash;
}

/*
|--------------------------------------------------------------------------
| Status Label
|--------------------------------------------------------------------------
*/

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

/*
|--------------------------------------------------------------------------
| Status Badge Class
|--------------------------------------------------------------------------
*/

function status_badge_class(string $status): string
{
    return match ($status) {

        'valid',
        'aktif',
        'selesai'
            => 'badge-success',

        'menunggu_verifikasi',
        'pending',
        'menunggu',
        'baru'
            => 'badge-warning',

        'ditolak',
        'gagal',
        'dibatalkan',
        'nonaktif'
            => 'badge-danger',

        'diproses',
        'dikirim'
            => 'badge-info',

        default
            => 'badge-neutral',

    };
}

/*
|--------------------------------------------------------------------------
| Badge Status Component
|--------------------------------------------------------------------------
*/

function badge_status(string $status): void
{
    ?>
        <span class="status-badge <?= e(status_badge_class($status)) ?>">
            <?= e(status_label($status)) ?>
        </span>
    <?php
}