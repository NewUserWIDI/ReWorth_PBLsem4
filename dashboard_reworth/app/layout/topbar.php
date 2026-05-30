<?php

declare(strict_types=1);

function render_topbar(string $title, array $user): void
{
    $firstName = trim(explode(' ', $user['nama'] ?? 'Seller')[0] ?? 'Seller');
    $initials = strtoupper(substr($firstName, 0, 1));
    $role = (string) ($user['role'] ?? '');
    $roleSubtitle = match ($role) {
        'admin' => 'Kelola seluruh sistem ReWorth',
        'dlh' => 'Dinas Lingkungan Hidup',
        default => '',
    };
    $searchPlaceholder = match ($role) {
        'admin' => 'Cari user, seller, laporan, transaksi...',
        'dlh' => 'Cari laporan, lokasi, petugas...',
        default => 'Cari produk, pesanan, pelanggan...',
    };
    $hasNotification = in_array($role, ['admin', 'dlh'], true);
    ?>
    <header class="topbar">
        <div>
            <p>Welcome back, <?= e($firstName) ?></p>
            <h1><?= e($title) ?></h1>
            <?php if ($roleSubtitle !== ''): ?>
                <span class="topbar-subtitle"><?= e($roleSubtitle) ?></span>
            <?php endif; ?>
        </div>
        <div class="topbar-actions">
            <input class="dashboard-search" type="search" placeholder="<?= e($searchPlaceholder) ?>" aria-label="Cari dashboard">
            <button class="topbar-icon" type="button" aria-label="Notifikasi">
                <svg class="topbar-bell-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                    <path d="M14.5 18H5.5a1 1 0 0 1-.8-1.6l1.1-1.5V10a6.2 6.2 0 0 1 5.2-6.1 6 6 0 0 1 6.8 6v5l1.1 1.5a1 1 0 0 1-.8 1.6h-3.6" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M10 19a2 2 0 0 0 4 0" stroke="currentColor" stroke-linecap="round"/>
                </svg>
                <?php if ($hasNotification): ?><span class="topbar-alert-dot"></span><?php endif; ?>
            </button>
            <div class="topbar-user">
                <div class="topbar-avatar"><?= e($initials) ?></div>
                <div>
                    <strong><?= e($user['nama'] ?? '-') ?></strong>
                    <span><?= e($user['email'] ?? '-') ?></span>
                </div>
            </div>
        </div>
    </header>
    <?php
}

