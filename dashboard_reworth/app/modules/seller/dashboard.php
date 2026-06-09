<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$sellerProfile = seller_fetch_profile($sellerUserId);
$dashboard = seller_fetch_dashboard_data($sellerUserId);
$orders = $dashboard['orders'];
$products = $dashboard['products'];
$newOrders = $dashboard['new_orders'];
$sales = $dashboard['sales'];
$lowStock = $dashboard['low_stock'];
$salesChart = $dashboard['sales_chart'] ?? ['days' => [], 'max_amount' => 0, 'total_amount' => 0, 'total_orders' => 0];
$storeName = (string) ($sellerProfile['nama_toko'] ?? 'Toko ReWorth');

render_layout('Dashboard Seller', function () use ($orders, $products, $newOrders, $sales, $lowStock, $storeName, $salesChart): void {
    ?>
    <section class="seller-hero">
        <div class="seller-hero-content">
            <h2><?= e($storeName) ?></h2>
            <p>Kelola toko, produk, dan pesanan Anda langsung dari data Supabase yang sama dengan aplikasi mobile.</p>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/store_profile.php')) ?>">Lihat Profil Toko</a>
        </div>
        <div class="seller-hero-ellipse seller-hero-ellipse-fill" aria-hidden="true"></div>
        <div class="seller-hero-ellipse seller-hero-ellipse-ring" aria-hidden="true"></div>
        <img class="seller-hero-illustration" src="<?= e(url('assets/ilustrasi.png')) ?>" alt="Ilustrasi seller ReWorth">
    </section>

    <div class="stat-grid">
        <?php stat_card('Pendapatan Bersih', 'Rp ' . number_format((int) $sales, 0, ',', '.'), 'Setelah fee platform checkout'); ?>
        <?php stat_card('Pesanan Baru', count($newOrders), 'Perlu diproses'); ?>
        <?php stat_card('Produk Aktif', count(array_filter($products, fn ($item) => ($item['status_produk'] ?? '') === 'aktif')), 'Tayang di market'); ?>
        <?php stat_card('Produk Perhatian', count($lowStock), 'Stok tersisa 5 atau kurang'); ?>
    </div>

    <div class="content-grid">
        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Grafik Penjualan 30 Hari Terakhir</h2>
                    <p>Ringkasan akan bertambah seiring transaksi toko.</p>
                </div>
            </div>
            <div class="seller-chart">
                <?php $maxAmount = max(1, (float) ($salesChart['max_amount'] ?? 0)); ?>
                <?php foreach (($salesChart['days'] ?? []) as $index => $day): ?>
                    <?php
                        $amount = (float) ($day['amount'] ?? 0);
                        $height = $amount > 0 ? max(10, (int) round(($amount / $maxAmount) * 150)) : 6;
                        $showLabel = $index === 0 || $index === 9 || $index === 19 || $index === 29;
                    ?>
                    <div class="seller-chart-bar" title="<?= e((string) ($day['label'] ?? '')) ?> | Rp <?= e(number_format((int) $amount, 0, ',', '.')) ?> | <?= e((string) ($day['orders'] ?? 0)) ?> pesanan">
                        <span style="height: <?= e((string) $height) ?>px"></span>
                        <?php if ($showLabel): ?><small><?= e((string) ($day['label'] ?? '')) ?></small><?php endif; ?>
                    </div>
                <?php endforeach; ?>
            </div>
            <div class="chart-summary">
                <strong>Rp <?= e(number_format((int) ($salesChart['total_amount'] ?? 0), 0, ',', '.')) ?></strong>
                <span><?= e((string) ($salesChart['total_orders'] ?? 0)) ?> pesanan selesai dalam 30 hari terakhir</span>
            </div>
        </section>

        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Produk Perlu Perhatian</h2>
                </div>
            </div>
            <div class="attention-list">
                <?php if ($lowStock === []): ?>
                    <div class="empty-state">Semua produk aman.</div>
                <?php else: ?>
                    <?php foreach ($lowStock as $product): ?>
                        <div class="attention-item">
                            <div>
                                <strong><?= e((string) $product['nama_produk']) ?></strong>
                                <p class="panel-subtitle">Stok tersisa <?= e((string) $product['stok']) ?></p>
                            </div>
                            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/product_detail.php?id=' . urlencode((string) $product['id_produk']))) ?>">Cek</a>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </section>
    </div>

    <section class="panel">
        <div class="panel-header">
            <h2>Pesanan Terbaru</h2>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/orders.php')) ?>">Lihat Semua</a>
        </div>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>ID Pesanan</th><th>Pembeli</th><th>Status</th><th>Net Seller</th><th>Aksi</th></tr></thead>
                <tbody>
                    <?php if ($orders === []): ?>
                        <tr><td colspan="5" style="text-align:center;color:#6b7280;">Belum ada pesanan untuk toko ini.</td></tr>
                    <?php else: ?>
                        <?php foreach (array_slice($orders, 0, 5) as $order): ?>
                            <tr>
                                <td><?= e((string) $order['kode_pesanan']) ?></td>
                                <td><?= e((string) $order['pembeli']) ?></td>
                                <td><?php badge_status((string) $order['status_pesanan']); ?></td>
                                <td>Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/seller/order_detail.php?id=' . urlencode((string) $order['id_pesanan']))) ?>">Detail</a></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
