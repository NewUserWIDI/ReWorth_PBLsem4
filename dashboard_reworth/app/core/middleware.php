<?php

declare(strict_types=1);

require_once __DIR__ . '/auth.php';

function require_login(): void
{
    if (!is_logged_in()) {
        redirect('public/login.php');
    }
}

function require_role(string $role): void
{
    require_login();

    $user = current_user();
    if (($user['role'] ?? '') !== $role) {
        set_flash('warning', 'Akses ditolak. Anda diarahkan ke dashboard sesuai role.');
        redirect_by_role($user['role'] ?? '');
    }
}

function require_active_seller(): void
{
    require_role('seller');

    $user = current_user();
    if (($user['status'] ?? '') !== 'aktif') {
        set_flash('warning', 'Akun seller belum aktif.');
        redirect('public/login.php');
    }
}

