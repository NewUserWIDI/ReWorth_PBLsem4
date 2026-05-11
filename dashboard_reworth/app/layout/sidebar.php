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
            ['Dashboard DLH', 'app/modules/dlh/dashboard.php'],
            ['Laporan Sampah', 'app/modules/dlh/reports.php'],
        ],
        'seller' => [
            ['Dashboard Toko', 'app/modules/seller/dashboard.php'],
            ['Profil Toko', 'app/modules/seller/store_profile.php'],
            ['Produk Saya', 'app/modules/seller/products.php'],
            ['Pesanan Masuk', 'app/modules/seller/orders.php'],
            ['Riwayat Transaksi', 'app/modules/seller/transactions.php'],
        ],
        default => [],
    };
}

function render_sidebar(array $user): void
{
    $role = $user['role'] ?? '';
    $currentPath = trim(parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) ?? '', '/');
    ?>
    <aside class="sidebar">
        <div class="brand">
            <div class="brand-mark">R</div>
            <div>
                <strong>ReWorth</strong>
                <span>Dashboard</span>
            </div>
        </div>
        <nav class="sidebar-nav">
            <?php foreach (sidebar_items($role) as [$label, $path]): ?>
                <?php $active = str_ends_with($currentPath, $path); ?>
                <a class="<?= $active ? 'active' : '' ?>" href="<?= e(url($path)) ?>"><?= e($label) ?></a>
            <?php endforeach; ?>
        </nav>
    </aside>
    <?php
}

