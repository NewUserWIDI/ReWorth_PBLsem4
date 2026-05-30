<?php

declare(strict_types=1);

function sidebar_items(string $role): array
{
    return match ($role) {
        'admin' => [
            ['Dashboard', 'app/modules/admin/dashboard.php'],
            ['Data User', 'app/modules/admin/users.php'],
            ['Laporan Sampah', 'app/modules/admin/reports.php'],
            ['Pengajuan Seller', 'app/modules/admin/seller_requests.php'],
            ['Data Seller', 'app/modules/admin/sellers.php'],
            ['Produk', 'app/modules/admin/products.php'],
            ['Pesanan', 'app/modules/admin/orders.php'],
            ['Reward', 'app/modules/admin/rewards.php'],
        ],
        'dlh' => [
            ['Dashboard', 'app/modules/dlh/dashboard.php', 'home'],
            ['Monitoring', 'app/modules/dlh/monitoring.php', 'activity'],
            ['Laporan Sampah', 'app/modules/dlh/laporan.php', 'orders'],
            ['Peta Lokasi', 'app/modules/dlh/peta_lokasi.php', 'map'],
            ['Petugas', 'app/modules/dlh/petugas.php', 'users'],
            ['Riwayat', 'app/modules/dlh/riwayat.php', 'history'],
            ['Pengaturan', 'app/modules/dlh/pengaturan.php', 'settings'],
            ['Keluar', 'public/logout.php', 'logout'],
        ],
        'seller' => [
            ['Beranda', 'app/modules/seller/dashboard.php', 'home'],
            ['Produk', 'app/modules/seller/products.php', 'box'],
            ['Pesanan', 'app/modules/seller/orders.php', 'orders'],
            ['Pelanggan', 'app/modules/seller/customers.php', 'users'],
            ['Saldo', 'app/modules/seller/transactions.php', 'wallet'],
            ['Pengaturan Toko', 'app/modules/seller/store_profile.php', 'settings'],
            ['Keluar', 'public/logout.php', 'logout'],
        ],
        default => [],
    };
}

function sidebar_icon_svg(string $icon): string
{
    return match ($icon) {
        'home' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M3 10.5 12 3l9 7.5V21a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1v-10.5Z" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'box' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 2 3 6.5 12 11l9-4.5L12 2Z" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 6.5V17.5L12 22l9-4.5V6.5" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 11V22" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'orders' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="5" y="3" width="14" height="18" rx="2" stroke="currentColor"/><path d="M8 8h8M8 12h8M8 16h5" stroke="currentColor" stroke-linecap="round"/></svg>',
        'activity' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M3 12h4l2-4 4 8 2-4h6" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'map' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3V6Z" stroke="currentColor" stroke-linejoin="round"/><path d="M9 3v15M15 6v15" stroke="currentColor"/></svg>',
        'users' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" stroke="currentColor" stroke-linecap="round"/><circle cx="9" cy="7" r="4" stroke="currentColor"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" stroke="currentColor" stroke-linecap="round"/></svg>',
        'history' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M3 12a9 9 0 1 0 3-6.7M3 4v4h4" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 7v5l3 2" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'wallet' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M3 7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v2H3V7Z" stroke="currentColor"/><path d="M3 9h18v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9Z" stroke="currentColor"/><path d="M16 14h4" stroke="currentColor" stroke-linecap="round"/></svg>',
        'settings' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 15.5A3.5 3.5 0 1 0 12 8.5a3.5 3.5 0 0 0 0 7Z" stroke="currentColor"/><path d="M19.4 15a1 1 0 0 0 .2 1.1l.1.1a1.8 1.8 0 0 1-2.5 2.5l-.1-.1a1 1 0 0 0-1.1-.2 1 1 0 0 0-.6.9V20a1.8 1.8 0 1 1-3.6 0v-.2a1 1 0 0 0-.6-.9 1 1 0 0 0-1.1.2l-.1.1a1.8 1.8 0 1 1-2.5-2.5l.1-.1a1 1 0 0 0 .2-1.1 1 1 0 0 0-.9-.6H4a1.8 1.8 0 1 1 0-3.6h.2a1 1 0 0 0 .9-.6 1 1 0 0 0-.2-1.1l-.1-.1a1.8 1.8 0 1 1 2.5-2.5l.1.1a1 1 0 0 0 1.1.2 1 1 0 0 0 .6-.9V4a1.8 1.8 0 1 1 3.6 0v.2a1 1 0 0 0 .6.9 1 1 0 0 0 1.1-.2l.1-.1a1.8 1.8 0 1 1 2.5 2.5l-.1.1a1 1 0 0 0-.2 1.1 1 1 0 0 0 .9.6H20a1.8 1.8 0 1 1 0 3.6h-.2a1 1 0 0 0-.9.6Z" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'logout' => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" stroke="currentColor" stroke-linecap="round"/><path d="M10 17 15 12 10 7M15 12H3" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        default => '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="8" stroke="currentColor"/></svg>',
    };
}

function render_sidebar(array $user): void
{
    $role = $user['role'] ?? '';
    $currentPath = trim(parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) ?? '', '/');
    ?>
    <aside class="sidebar">
        <div class="brand">
            <img class="brand-logo" src="<?= e(url('assets/logo_reworth.jpeg')) ?>" alt="Logo ReWorth">
            <div class="brand-copy">
                <strong>ReWorth</strong>
                <span>Give Reworth. Create Impact.</span>
            </div>
        </div>
        <nav class="sidebar-nav">
            <?php foreach (sidebar_items($role) as $item): ?>
                <?php [$label, $path] = $item; $icon = $item[2] ?? 'dot'; ?>
                <?php $active = str_ends_with($currentPath, $path); ?>
                <a class="<?= $active ? 'active' : '' ?>" href="<?= e(url($path)) ?>">
                    <span class="sidebar-menu-icon" aria-hidden="true"><?= sidebar_icon_svg($icon) ?></span>
                    <span><?= e($label) ?></span>
                </a>
            <?php endforeach; ?>
        </nav>
        <?php if ($role === 'dlh'): ?>
            <section class="sidebar-profile">
                <strong>DLH Kota Bandung</strong>
                <span>monitoring@dlh.reworth.app</span>
            </section>
        <?php endif; ?>
        <?php if ($role === 'seller'): ?>
            <small class="sidebar-copyright">&copy; 2026 ReWorth Seller Dashboard</small>
        <?php elseif ($role === 'dlh'): ?>
            <small class="sidebar-copyright">&copy; 2026 ReWorth DLH Dashboard</small>
        <?php endif; ?>
    </aside>
    <?php
}

