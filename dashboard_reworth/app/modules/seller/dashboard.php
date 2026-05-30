<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Dashboard Seller', function (): void {
    $orders = mock_orders();
    $products = mock_products();
    $newOrders = array_values(array_filter($orders, fn ($item) => $item['status'] === 'baru'));
    $sales = array_sum(array_map(fn ($item) => (int) $item['total'], array_filter($orders, fn ($item) => $item['status'] === 'selesai')));
    $lowStock = array_values(array_filter($products, fn ($item) => (int) $item['stok'] <= 5));
    ?>
    <section class="seller-hero">
        <div class="seller-hero-content">
            <h2>Toko Anda Aktif</h2>
            <p>Teruslah menginspirasi perubahan positif bagi lingkungan lewat produk daur ulang yang rapi, relevan, dan mudah ditemukan pembeli.</p>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/store_profile.php')) ?>">Lihat Profil Toko</a>
        </div>
        <div class="seller-hero-ellipse seller-hero-ellipse-fill" aria-hidden="true"></div>
        <div class="seller-hero-ellipse seller-hero-ellipse-ring" aria-hidden="true"></div>
        <img class="seller-hero-illustration" src="<?= e(url('assets/ilustrasi.png')) ?>" alt="Ilustrasi seller ReWorth">
    </section>

    <div class="stat-grid">
        <?php stat_card('Total Penjualan', 'Rp ' . number_format($sales, 0, ',', '.'), 'Pesanan selesai'); ?>
        <?php stat_card('Pesanan Baru', count($newOrders), 'Perlu diproses'); ?>
        <?php stat_card('Produk Aktif', count(array_filter($products, fn ($item) => $item['status'] === 'aktif')), 'Tayang di market'); ?>
        <?php stat_card('Saldo Tersedia', 'Rp ' . number_format(max($sales - 12500, 0), 0, ',', '.'), 'Siap ditarik'); ?>
    </div>

    <div class="content-grid">
        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Grafik Penjualan 30 Hari Terakhir</h2>
                    <p>Ringkasan akan terisi otomatis ketika transaksi masuk.</p>
                </div>
            </div>
            <div class="chart-placeholder">
                <div>
                    <strong>Belum cukup data penjualan</strong>
                    <p class="panel-subtitle">Data chart akan muncul setelah toko memiliki transaksi rutin.</p>
                </div>
            </div>
        </section>

        <section class="panel">
            <div class="panel-header"><h2>Produk Perlu Perhatian</h2></div>
            <div class="attention-list">
                <?php if ($lowStock === []): ?>
                    <div class="empty-state">Semua produk aman.</div>
                <?php else: ?>
                    <?php foreach ($lowStock as $product): ?>
                        <div class="attention-item">
                            <div>
                                <strong><?= e($product['nama']) ?></strong>
                                <p class="panel-subtitle">Stok tersisa <?= e((string) $product['stok']) ?></p>
                            </div>
                            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/products.php')) ?>">Cek</a>
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
                <thead><tr><th>ID Pesanan</th><th>Pembeli</th><th>Status</th><th>Total</th><th>Aksi</th></tr></thead>
                <tbody>
                    <?php foreach (array_slice($orders, 0, 5) as $order): ?>
                        <tr>
                            <td><?= e($order['id']) ?></td>
                            <td><?= e($order['pembeli']) ?></td>
                            <td><?php badge_status($order['status']); ?></td>
                            <td>Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?></td>
                            <td><a class="btn btn-secondary" href="<?= e(url('app/modules/seller/order_detail.php?id=' . urlencode($order['id']))) ?>">Detail</a></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});

