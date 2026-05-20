<?php

declare(strict_types=1);

function sidebar_items(string $role): array
{
    return match ($role) {
        'admin' => [
            ['Dashboard', 'dashboard.php?role=admin&page=dashboard'],
            ['Data User', 'dashboard.php?role=admin&page=users'],
            ['Laporan Sampah', 'dashboard.php?role=admin&page=reports'],
            ['Pengajuan Seller', 'dashboard.php?role=admin&page=seller_requests'],
            ['Data Seller', 'dashboard.php?role=admin&page=sellers'],
            ['Produk', 'dashboard.php?role=admin&page=products'],
            ['Pesanan', 'dashboard.php?role=admin&page=orders'],
            ['Reward', 'dashboard.php?role=admin&page=rewards'],
        ],
        'dlh' => [
            ['Dashboard DLH', 'dashboard.php?role=dlh&page=dashboard'],
            ['Laporan Sampah', 'dashboard.php?role=dlh&page=reports'],
        ],
        'seller' => [
            ['Dashboard Toko', 'dashboard.php?role=seller&page=dashboard'],
            ['Profil Toko', 'dashboard.php?role=seller&page=store_profile'],
            ['Produk Saya', 'dashboard.php?role=seller&page=products'],
            ['Pesanan Masuk', 'dashboard.php?role=seller&page=orders'],
            ['Riwayat Transaksi', 'dashboard.php?role=seller&page=transactions'],
        ],
        default => [],
    };
}

function render_sidebar(array $user): void
{
    $role = $user['role'] ?? '';
    $currentUrl = trim((string) ($_SERVER['REQUEST_URI'] ?? ''), '/');
    $brandTitle = $role === 'seller' ? 'Mini Market' : 'ReWorth';
    $brandSubtitle = match ($role) {
        'seller' => 'Seller Dashboard',
        'dlh' => 'DLH Dashboard',
        'admin' => 'Admin Dashboard',
        default => 'Dashboard',
    };
    $brandInitial = $role === 'seller' ? 'M' : 'R';
    ?>
    <aside class="sidebar">
        <div class="brand">
            <div class="brand-mark"><?= e($brandInitial) ?></div>
            <div>
                <strong><?= e($brandTitle) ?></strong>
                <span><?= e($brandSubtitle) ?></span>
            </div>
        </div>
        <nav class="sidebar-nav">
            <?php foreach (sidebar_items($role) as [$label, $path]): ?>
                <?php $active = str_contains($currentUrl, $path); ?>
                <a class="<?= $active ? 'active' : '' ?>" href="<?= e(url($path)) ?>"><?= e($label) ?></a>
            <?php endforeach; ?>
        </nav>
        <a class="sidebar-logout" href="<?= e(url('logout.php')) ?>">Keluar</a>
    </aside>
    <?php
}
