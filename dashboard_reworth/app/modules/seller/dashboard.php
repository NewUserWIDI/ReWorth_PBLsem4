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
$salesChartIsDemo = (float) ($salesChart['total_amount'] ?? 0) <= 0;
if ($salesChartIsDemo) {
    $salesChart = seller_build_demo_sales_chart(30);
}
$salesChartDays = array_values(is_array($salesChart['days'] ?? null) ? $salesChart['days'] : []);
$salesChartMax = max(1, (float) ($salesChart['max_amount'] ?? 0));
$salesChartWidth = max(960, count($salesChartDays) * 42);
$salesChartHeight = 236;
$salesChartPaddingX = 20;
$salesChartPaddingTop = 18;
$salesChartPaddingBottom = 42;
$salesChartPlotHeight = $salesChartHeight - $salesChartPaddingTop - $salesChartPaddingBottom;
$salesChartPlotWidth = $salesChartWidth - ($salesChartPaddingX * 2);
$salesChartBaseY = $salesChartHeight - $salesChartPaddingBottom;
$salesChartPoints = [];
foreach ($salesChartDays as $index => $day) {
    $amount = (float) ($day['amount'] ?? 0);
    $x = $salesChartPaddingX;
    if (count($salesChartDays) > 1) {
        $x += ($salesChartPlotWidth * $index) / (count($salesChartDays) - 1);
    }
    $y = $salesChartPaddingTop + $salesChartPlotHeight - ($amount / $salesChartMax) * $salesChartPlotHeight;
    $salesChartPoints[] = [
        'x' => $x,
        'y' => $y,
        'label' => (string) ($day['label'] ?? ''),
        'amount' => $amount,
        'orders' => (int) ($day['orders'] ?? 0),
        'show_label' => $index % 5 === 0 || $index === array_key_last($salesChartDays),
    ];
}

$salesChartLinePath = '';
$salesChartAreaPath = '';
if ($salesChartPoints !== []) {
    foreach ($salesChartPoints as $index => $point) {
        $command = $index === 0 ? 'M' : 'L';
        $salesChartLinePath .= $command . ' ' . round($point['x'], 2) . ' ' . round($point['y'], 2) . ' ';
    }
    $firstPoint = $salesChartPoints[0];
    $lastPoint = $salesChartPoints[array_key_last($salesChartPoints)];
    $salesChartAreaPath = $salesChartLinePath
        . 'L ' . round($lastPoint['x'], 2) . ' ' . round($salesChartBaseY, 2)
        . ' L ' . round($firstPoint['x'], 2) . ' ' . round($salesChartBaseY, 2)
        . ' Z';
}
$storeName = (string) ($sellerProfile['nama_toko'] ?? $user['nama_toko'] ?? $user['nama'] ?? 'Toko ReWorth');

render_layout('Dashboard Seller', function () use ($orders, $products, $newOrders, $sales, $lowStock, $storeName, $salesChart, $salesChartIsDemo, $salesChartDays, $salesChartPoints, $salesChartWidth, $salesChartHeight, $salesChartBaseY, $salesChartLinePath, $salesChartAreaPath, $salesChartPaddingTop, $salesChartPlotHeight): void {
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
        <section class="panel seller-sales-panel">
            <div class="panel-header seller-sales-header">
                <div>
                    <h2>Grafik Penjualan 30 Hari Terakhir</h2>
                    <p><?= $salesChartIsDemo ? 'Data demo aktif untuk verifikasi tampilan chart.' : 'Ringkasan akan bertambah seiring transaksi toko.' ?></p>
                </div>
                <?php if ($salesChartIsDemo): ?>
                    <span class="seller-sales-demo-badge">Demo</span>
                <?php endif; ?>
            </div>

            <div class="seller-sales-chart" aria-label="Grafik penjualan 30 hari terakhir">
                <svg
                    class="seller-sales-chart-svg"
                    viewBox="0 0 <?= e((string) $salesChartWidth) ?> <?= e((string) $salesChartHeight) ?>"
                    role="img"
                    aria-label="Grafik penjualan 30 hari terakhir"
                    preserveAspectRatio="none"
                >
                    <rect x="0" y="0" width="<?= e((string) $salesChartWidth) ?>" height="<?= e((string) $salesChartHeight) ?>" fill="#ffffff"></rect>
                    <?php for ($i = 0; $i <= 4; $i++): ?>
                        <?php $gridY = $salesChartPaddingTop + (int) round(($salesChartPlotHeight / 4) * $i); ?>
                        <line x1="20" y1="<?= e((string) $gridY) ?>" x2="<?= e((string) ($salesChartWidth - 20)) ?>" y2="<?= e((string) $gridY) ?>" stroke="#E5E7EB" stroke-width="1"></line>
                    <?php endfor; ?>
                    <?php if ($salesChartAreaPath !== ''): ?>
                        <path d="<?= e($salesChartAreaPath) ?>" fill="#DCFCE7" opacity="0.55"></path>
                        <path d="<?= e($salesChartLinePath) ?>" fill="none" stroke="#15803D" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"></path>
                        <?php foreach ($salesChartPoints as $point): ?>
                            <circle cx="<?= e((string) round($point['x'], 2)) ?>" cy="<?= e((string) round($point['y'], 2)) ?>" r="5.5" fill="#15803D" stroke="#ffffff" stroke-width="2"></circle>
                        <?php endforeach; ?>
                    <?php endif; ?>
                    <?php foreach ($salesChartPoints as $point): ?>
                        <?php if ($point['show_label']): ?>
                            <text
                                x="<?= e((string) round($point['x'], 2)) ?>"
                                y="<?= e((string) ($salesChartHeight - 14)) ?>"
                                text-anchor="middle"
                                fill="#6B7280"
                                font-size="11"
                                font-family="Poppins, sans-serif"
                            ><?= e((string) $point['label']) ?></text>
                        <?php endif; ?>
                    <?php endforeach; ?>
                </svg>
            </div>

            <div class="seller-sales-summary">
                <div>
                    <strong>Rp <?= e(number_format((int) ($salesChart['total_amount'] ?? 0), 0, ',', '.')) ?></strong>
                    <span><?= e((string) ($salesChart['total_orders'] ?? 0)) ?> pesanan selesai dalam 30 hari terakhir</span>
                </div>
                <?php if ($salesChartIsDemo): ?>
                    <p>Dummy data ini hanya untuk memastikan garis chart bisa tampil saat data real belum ada.</p>
                <?php endif; ?>
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
