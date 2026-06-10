<?php

declare(strict_types=1);

function sidebar_items(string $role): array
{
    return match ($role) {
        'admin' => [
            ['type' => 'link', 'key' => 'dashboard', 'label' => 'Dashboard', 'path' => 'app/modules/admin/dashboard.php', 'icon' => 'home'],
            [
                'type' => 'group',
                'key' => 'data_petugas',
                'label' => 'Data Pengguna',
                'icon' => 'users',
                'children' => [
                    ['key' => 'data_masyarakat', 'label' => 'Data User', 'path' => 'app/modules/admin/users.php?role=user'],
                    ['key' => 'data_seller', 'label' => 'Data Seller', 'path' => 'app/modules/admin/sellers.php'],
                    ['key' => 'data_dlh', 'label' => 'Data DLH', 'path' => 'app/modules/admin/data_dlh.php'],
                ],
            ],
            [
                'type' => 'group',
                'key' => 'kelola_verifikasi',
                'label' => 'Kelola Verifikasi',
                'icon' => 'shield',
                'children' => [
                    ['key' => 'verifikasi_pembayaran', 'label' => 'Verifikasi Pembayaran', 'path' => 'app/modules/admin/payment_verifications.php'],
                    ['key' => 'verifikasi_seller', 'label' => 'Verifikasi Pengajuan Seller', 'path' => 'app/modules/admin/sellers.php?status=menunggu'],
                ],
            ],
            [
                'type' => 'group',
                'key' => 'data_transaksi',
                'label' => 'Data Transaksi',
                'icon' => 'credit',
                'children' => [
                    ['key' => 'laporan_sampah', 'label' => 'Laporan Sampah', 'path' => 'app/modules/admin/laporan_sampah.php'],
                    ['key' => 'transaksi_mini_market', 'label' => 'Transaksi Mini Market', 'path' => 'app/modules/admin/transaksi.php'],
                    ['key' => 'transaksi_poin', 'label' => 'Transaksi Tukar Poin', 'path' => 'app/modules/admin/transaksi_poin.php'],
                ],
            ],
            ['type' => 'link', 'key' => 'pengaturan_profile', 'label' => 'Pengaturan Profile', 'path' => 'app/modules/admin/pengaturan.php', 'icon' => 'settings'],
            ['type' => 'link', 'key' => 'kelola_reward', 'label' => 'Kelola Reward', 'path' => 'app/modules/admin/rewards.php', 'icon' => 'gift'],
        ],
        'dlh' => [
            ['type' => 'link', 'key' => 'dashboard', 'label' => 'Dashboard', 'path' => 'app/modules/dlh/dashboard.php', 'icon' => 'home'],
            ['type' => 'link', 'key' => 'laporan', 'label' => 'Laporan Sampah', 'path' => 'app/modules/dlh/laporan.php', 'icon' => 'orders'],
            ['type' => 'link', 'key' => 'peta', 'label' => 'Peta Lokasi', 'path' => 'app/modules/dlh/peta_lokasi.php', 'icon' => 'map'],
            ['type' => 'link', 'key' => 'riwayat', 'label' => 'Riwayat', 'path' => 'app/modules/dlh/riwayat.php', 'icon' => 'history'],
            ['type' => 'link', 'key' => 'pengaturan', 'label' => 'Pengaturan', 'path' => 'app/modules/dlh/pengaturan.php', 'icon' => 'settings'],
        ],
        'seller' => [
            ['type' => 'link', 'key' => 'beranda', 'label' => 'Beranda', 'path' => 'app/modules/seller/dashboard.php', 'icon' => 'home'],
            ['type' => 'link', 'key' => 'produk', 'label' => 'Produk', 'path' => 'app/modules/seller/products.php', 'icon' => 'box'],
            ['type' => 'link', 'key' => 'pesanan', 'label' => 'Pesanan', 'path' => 'app/modules/seller/orders.php', 'icon' => 'orders'],
            ['type' => 'link', 'key' => 'pelanggan', 'label' => 'Pelanggan', 'path' => 'app/modules/seller/customers.php', 'icon' => 'users'],
            ['type' => 'link', 'key' => 'saldo', 'label' => 'Riwayat Pesanan', 'path' => 'app/modules/seller/transactions.php', 'icon' => 'history'],
            ['type' => 'link', 'key' => 'pengaturan_toko', 'label' => 'Pengaturan Toko', 'path' => 'app/modules/seller/store_profile.php', 'icon' => 'settings'],
        ],
        default => [],
    };
}

function sidebar_logout_item(): array
{
    return [
        'label' => 'Keluar',
        'path' => 'public/logout.php',
        'icon' => 'logout',
        'confirm' => 'Apakah Anda yakin ingin keluar dari halaman ini? Semua perubahan yang belum disimpan akan hilang.',
    ];
}

function sidebar_icon_svg(string $icon): string
{
    $icons = [
        'home' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 10.5 12 3l9 7.5V21a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1v-10.5Z" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'users' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" stroke-linecap="round"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" stroke-linecap="round"/></svg>',
        'shield' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 3 5 6v6c0 4.4 2.9 8.4 7 9.7 4.1-1.3 7-5.3 7-9.7V6l-7-3Z" stroke-linejoin="round"/><path d="m9.5 12 1.7 1.7 3.3-3.7" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'credit' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 10h18M7 15h3" stroke-linecap="round"/></svg>',
        'settings' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 15.5A3.5 3.5 0 1 0 12 8.5a3.5 3.5 0 0 0 0 7Z"/><path d="M19.4 15a1.1 1.1 0 0 0 .2 1.1l.1.1a1.8 1.8 0 0 1-2.5 2.5l-.1-.1a1.1 1.1 0 0 0-1.1-.2 1 1 0 0 0-.6.9V20a1.8 1.8 0 1 1-3.6 0v-.2a1 1 0 0 0-.6-.9 1.1 1.1 0 0 0-1.1.2l-.1.1a1.8 1.8 0 1 1-2.5-2.5l.1-.1a1.1 1.1 0 0 0 .2-1.1 1 1 0 0 0-.9-.6H4a1.8 1.8 0 1 1 0-3.6h.2a1 1 0 0 0 .9-.6 1.1 1.1 0 0 0-.2-1.1l-.1-.1a1.8 1.8 0 1 1 2.5-2.5l.1.1a1.1 1.1 0 0 0 1.1.2 1 1 0 0 0 .6-.9V4a1.8 1.8 0 1 1 3.6 0v.2a1 1 0 0 0 .6.9 1.1 1.1 0 0 0 1.1-.2l.1-.1a1.8 1.8 0 1 1 2.5 2.5l-.1.1a1.1 1.1 0 0 0-.2 1.1 1 1 0 0 0 .9.6H20a1.8 1.8 0 1 1 0 3.6h-.2a1 1 0 0 0-.9.6Z" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'gift' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 12v8a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-8M2 7h20v5H2V7Z" stroke-linejoin="round"/><path d="M12 7v14M12 7H8.5A2.5 2.5 0 1 1 11 4.5L12 7ZM12 7h3.5A2.5 2.5 0 1 0 13 4.5L12 7Z" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'logout' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" stroke-linecap="round"/><path d="M10 17 15 12 10 7M15 12H3" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'activity' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 12h4l2-4 4 8 2-4h6" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'map' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3V6Z" stroke-linejoin="round"/><path d="M9 3v15M15 6v15"/></svg>',
        'orders' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="3" width="14" height="18" rx="2"/><path d="M8 8h8M8 12h8M8 16h5" stroke-linecap="round"/></svg>',
        'history' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 12a9 9 0 1 0 3-6.7M3 4v4h4" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 7v5l3 2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'wallet' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v2H3V7Z"/><path d="M3 9h18v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9Z"/><path d="M16 14h4" stroke-linecap="round"/></svg>',
        'box' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 2 3 6.5 12 11l9-4.5L12 2Z" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 6.5V17.5L12 22l9-4.5V6.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 11V22" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'store' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 7h18l-1.2 5.4a2 2 0 0 1-2 1.6H6.2a2 2 0 0 1-2-1.6L3 7Z" stroke-linejoin="round"/><path d="M5 7V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v2M6 21h12v-7H6v7Z" stroke-linecap="round" stroke-linejoin="round"/></svg>',
        'file' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 2H7a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7l-5-5Z" stroke-linejoin="round"/><path d="M14 2v5h5M9 12h6M9 16h6" stroke-linecap="round"/></svg>',
        'shopping' => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M6 7h14l-1.5 10a2 2 0 0 1-2 1.7H9.4a2 2 0 0 1-2-1.7L6 7Z" stroke-linejoin="round"/><path d="M9 7V5a3 3 0 0 1 6 0v2" stroke-linecap="round"/></svg>',
    ];

    return $icons[$icon] ?? '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="8"/></svg>';
}

function sidebar_path_matches(string $currentPath, array $query, string $targetPath): bool
{
    $targetBasePath = trim(parse_url($targetPath, PHP_URL_PATH) ?? '', '/');
    if ($targetBasePath === '' || !str_ends_with($currentPath, $targetBasePath)) {
        return false;
    }

    parse_str((string) (parse_url($targetPath, PHP_URL_QUERY) ?? ''), $targetQuery);
    foreach ($targetQuery as $key => $value) {
        if (!array_key_exists($key, $query) || (string) $query[$key] !== (string) $value) {
            return false;
        }
    }

    return true;
}

function sidebar_item_active(string $role, string $key, string $currentPath, array $query): bool
{
    if ($role === 'admin') {
        $sellerId = (string) ($query['id'] ?? '');
        $isPengajuan = str_starts_with($sellerId, 'PEN-');
        $sellerSource = (string) ($query['source'] ?? '');
        $isSellerDetail = str_ends_with($currentPath, 'app/modules/admin/seller_detail.php');

        return match ($key) {
            'dashboard' => str_ends_with($currentPath, 'app/modules/admin/dashboard.php'),
            'data_masyarakat' => sidebar_path_matches($currentPath, $query, 'app/modules/admin/users.php?role=user')
                || str_ends_with($currentPath, 'app/modules/admin/user_detail.php'),
            'data_seller' => (sidebar_path_matches($currentPath, $query, 'app/modules/admin/sellers.php') && !isset($query['status']))
                || str_ends_with($currentPath, 'app/modules/admin/seller_requests.php')
                || ($isSellerDetail && !$isPengajuan && $sellerSource !== 'verification'),
            'data_dlh' => str_ends_with($currentPath, 'app/modules/admin/data_dlh.php'),
            'verifikasi_pembayaran' => str_ends_with($currentPath, 'app/modules/admin/payment_verifications.php')
                || str_ends_with($currentPath, 'app/modules/admin/payment_verification_detail.php'),
            'verifikasi_seller' => sidebar_path_matches($currentPath, $query, 'app/modules/admin/sellers.php?status=menunggu')
                || ($isSellerDetail && ($sellerSource === 'verification' || $isPengajuan)),
            'laporan_sampah' => str_ends_with($currentPath, 'app/modules/admin/laporan_sampah.php')
                || str_ends_with($currentPath, 'app/modules/admin/laporan_detail.php')
                || str_ends_with($currentPath, 'app/modules/admin/reports.php'),
            'transaksi_mini_market' => str_ends_with($currentPath, 'app/modules/admin/transaksi.php')
                || str_ends_with($currentPath, 'app/modules/admin/transaksi_detail.php')
                || str_ends_with($currentPath, 'app/modules/admin/orders.php'),
            'transaksi_poin' => str_ends_with($currentPath, 'app/modules/admin/transaksi_poin.php'),
            'pengaturan_profile' => str_ends_with($currentPath, 'app/modules/admin/pengaturan.php'),
            'kelola_reward' => str_ends_with($currentPath, 'app/modules/admin/rewards.php'),
            default => false,
        };
    }

    if ($role === 'dlh') {
        return match ($key) {
            'dashboard' => str_ends_with($currentPath, 'app/modules/dlh/dashboard.php'),
            'monitoring' => str_ends_with($currentPath, 'app/modules/dlh/monitoring.php'),
            'laporan' => str_ends_with($currentPath, 'app/modules/dlh/laporan.php')
                || str_ends_with($currentPath, 'app/modules/dlh/laporan_detail.php'),
            'peta' => str_ends_with($currentPath, 'app/modules/dlh/peta_lokasi.php'),
            'petugas' => str_ends_with($currentPath, 'app/modules/dlh/petugas.php'),
            'riwayat' => str_ends_with($currentPath, 'app/modules/dlh/riwayat.php'),
            'pengaturan' => str_ends_with($currentPath, 'app/modules/dlh/pengaturan.php'),
            default => false,
        };
    }

    if ($role === 'seller') {
        return match ($key) {
            'beranda' => str_ends_with($currentPath, 'app/modules/seller/dashboard.php'),
            'produk' => str_ends_with($currentPath, 'app/modules/seller/products.php')
                || str_ends_with($currentPath, 'app/modules/seller/product_detail.php')
                || str_ends_with($currentPath, 'app/modules/seller/product_form.php'),
            'pesanan' => str_ends_with($currentPath, 'app/modules/seller/orders.php')
                || str_ends_with($currentPath, 'app/modules/seller/order_detail.php'),
            'pelanggan' => str_ends_with($currentPath, 'app/modules/seller/customers.php'),
            'saldo' => str_ends_with($currentPath, 'app/modules/seller/transactions.php'),
            'pengaturan_toko' => str_ends_with($currentPath, 'app/modules/seller/store_profile.php'),
            default => false,
        };
    }

    return false;
}

function render_sidebar(array $user): void
{
    $role = (string) ($user['role'] ?? '');
    $currentPath = trim(parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) ?? '', '/');
    $query = $_GET;
    $logout = sidebar_logout_item();
    $items = sidebar_items($role);
    $brandTagline = match ($role) {
        'admin' => 'Bersama Jaga Bumi, Ciptakan Dampak.',
        default => 'Give ReWorth. Create Impact.',
    };
    $adminName = trim((string) (($user['nama_lengkap'] ?? $user['nama'] ?? '') ?: 'Admin ReWorth'));
    $adminEmail = trim((string) (($user['email'] ?? '') ?: 'dashboard@reworth.app'));
    $sellerName = trim((string) (($user['nama_toko'] ?? $user['nama'] ?? '') ?: 'Seller ReWorth'));
    ?>
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="brand">
                <img class="brand-logo" src="<?= e(url('assets/logo_reworth.jpeg')) ?>" alt="Logo ReWorth">
                <div class="brand-copy">
                    <strong>ReWorth</strong>
                    <span><?= e($brandTagline) ?></span>
                </div>
            </div>
        </div>
        <div class="sidebar-scroll">
            <nav class="sidebar-nav">
                <?php foreach ($items as $item): ?>
                    <?php if (($item['type'] ?? 'link') === 'group'): ?>
                        <?php
                        $children = $item['children'] ?? [];
                        $open = false;
                        foreach ($children as $child) {
                            if (sidebar_item_active($role, (string) ($child['key'] ?? ''), $currentPath, $query)) {
                                $open = true;
                                break;
                            }
                        }
                        ?>
                        <details class="sidebar-group" <?= $open ? 'open' : '' ?>>
                            <summary class="sidebar-link sidebar-group-summary <?= $open ? 'active' : '' ?>">
                                <span class="sidebar-group-main">
                                    <span class="sidebar-menu-icon" aria-hidden="true"><?= sidebar_icon_svg((string) ($item['icon'] ?? '')) ?></span>
                                    <span class="sidebar-label"><?= e((string) ($item['label'] ?? '')) ?></span>
                                </span>
                                <span class="sidebar-chevron" aria-hidden="true"></span>
                            </summary>
                            <div class="sidebar-submenu">
                                <?php foreach ($children as $child): ?>
                                    <a href="<?= e(url((string) ($child['path'] ?? ''))) ?>" class="<?= sidebar_item_active($role, (string) ($child['key'] ?? ''), $currentPath, $query) ? 'active' : '' ?>">
                                        <span class="sidebar-submenu-label"><?= e((string) ($child['label'] ?? '')) ?></span>
                                    </a>
                                <?php endforeach; ?>
                            </div>
                        </details>
                    <?php else: ?>
                        <a href="<?= e(url((string) ($item['path'] ?? ''))) ?>" class="sidebar-link <?= sidebar_item_active($role, (string) ($item['key'] ?? ''), $currentPath, $query) ? 'active' : '' ?>">
                            <span class="sidebar-group-main">
                                <span class="sidebar-menu-icon" aria-hidden="true"><?= sidebar_icon_svg((string) ($item['icon'] ?? '')) ?></span>
                                <span class="sidebar-label"><?= e((string) ($item['label'] ?? '')) ?></span>
                            </span>
                        </a>
                    <?php endif; ?>
                <?php endforeach; ?>
            </nav>
        </div>
        <div class="sidebar-footer">
            <a class="sidebar-link sidebar-logout-link" href="<?= e(url($logout['path'])) ?>" data-confirm="<?= e($logout['confirm']) ?>">
                <span class="sidebar-group-main">
                    <span class="sidebar-menu-icon" aria-hidden="true"><?= sidebar_icon_svg((string) $logout['icon']) ?></span>
                    <span class="sidebar-label"><?= e((string) $logout['label']) ?></span>
                </span>
            </a>
            <?php if ($role === 'admin'): ?>
                <section class="sidebar-profile">
                    <strong><?= e($adminName) ?></strong>
                    <span><?= e($adminEmail) ?></span>
                </section>
                <small class="sidebar-copyright">&copy; 2026 ReWorth Admin Dashboard</small>
            <?php elseif ($role === 'dlh'): ?>
                <section class="sidebar-profile">
                    <strong>DLH Kota Bandung</strong>
                    <span>monitoring@dlh.reworth.app</span>
                </section>
                <small class="sidebar-copyright">&copy; 2026 ReWorth DLH Dashboard</small>
            <?php elseif ($role === 'seller'): ?>
                <section class="sidebar-profile">
                    <strong><?= e($sellerName) ?></strong>
                    <span><i class="sidebar-status-dot"></i> Toko Aktif</span>
                </section>
                <small class="sidebar-copyright">&copy; 2026 ReWorth Seller Dashboard</small>
            <?php endif; ?>
        </div>
    </aside>
    <?php
}
