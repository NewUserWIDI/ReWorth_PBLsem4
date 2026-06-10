<?php

declare(strict_types=1);

function render_topbar(string $title, array $user): void
{
    $firstName = trim(explode(' ', $user['nama'] ?? 'Seller')[0] ?? 'Seller');
    $storeName = trim((string) ($user['nama_toko'] ?? ''));
    $initials = strtoupper(substr($firstName, 0, 1));
    $avatarUrl = trim((string) ($user['foto_toko'] ?? ''));
    $role = (string) ($user['role'] ?? '');

    if ($role === 'seller' && $avatarUrl === '' && function_exists('seller_fetch_profile')) {
        $profile = seller_fetch_profile((string) ($user['seller_user_id'] ?? $user['user_id'] ?? ''));
        if (is_array($profile)) {
            $avatarUrl = trim((string) ($profile['foto_toko'] ?? ''));
        }
    }

    $roleSubtitle = match ($role) {
        'admin' => 'Kelola seluruh sistem ReWorth',
        'dlh' => 'Dinas Lingkungan Hidup',
        default => '',
    };
    $eyebrow = $role === 'seller' ? 'Welcome back, Seller' : 'Welcome back, ' . $firstName;
    $heading = $role === 'seller' && $storeName !== '' ? $storeName : $title;
    $hasNotification = in_array($role, ['admin', 'dlh'], true);
    ?>
    <header class="topbar">
        <div>
            <p><?= e($eyebrow) ?></p>
            <h1><?= e($heading) ?></h1>
            <?php if ($roleSubtitle !== ''): ?>
                <span class="topbar-subtitle"><?= e($roleSubtitle) ?></span>
            <?php endif; ?>
        </div>
        <div class="topbar-actions<?= $role === 'seller' ? ' topbar-actions-seller' : '' ?>">
            <button class="sidebar-toggle" type="button" data-sidebar-toggle aria-label="Buka menu sidebar">
                <span class="sidebar-toggle-icon" aria-hidden="true"></span>
            </button>
            <!-- SEARCH BOX DIHAPUS -->
            <button class="topbar-icon" type="button" aria-label="Notifikasi">
                <svg class="topbar-bell-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                    <path d="M14.5 18H5.5a1 1 0 0 1-.8-1.6l1.1-1.5V10a6.2 6.2 0 0 1 5.2-6.1 6 6 0 0 1 6.8 6v5l1.1 1.5a1 1 0 0 1-.8 1.6h-3.6" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M10 19a2 2 0 0 0 4 0" stroke="currentColor" stroke-linecap="round"/>
                </svg>
                <?php if ($hasNotification): ?><span class="topbar-alert-dot"></span><?php endif; ?>
            </button>
            <?php if ($role === 'seller'): ?>
                <a class="topbar-seller-link" href="<?= e(url('app/modules/seller/store_profile.php?edit=1')) ?>">
                    Edit Profil
                </a>
                <a class="topbar-user topbar-user-seller" href="<?= e(url('app/modules/seller/store_profile.php')) ?>" aria-label="Buka profil toko">
                    <div class="topbar-avatar topbar-avatar-seller">
                        <?= e($initials) ?>
                    </div>
                </a>
            <?php else: ?>
                <div class="topbar-user">
                    <div class="topbar-avatar">
                        <?php if ($avatarUrl !== ''): ?>
                            <img src="<?= e($avatarUrl) ?>" alt="<?= e($storeName !== '' ? $storeName : $firstName) ?>">
                        <?php else: ?>
                            <?= e($initials) ?>
                        <?php endif; ?>
                    </div>
                    <div>
                        <strong><?= e($user['nama'] ?? '-') ?></strong>
                        <span><?= e($user['email'] ?? '-') ?></span>
                    </div>
                </div>
            <?php endif; ?>
        </div>
    </header>
    <?php
}
