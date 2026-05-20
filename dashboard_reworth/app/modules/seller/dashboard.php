<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

function rupiah(int $value): string
{
    return 'Rp ' . number_format($value, 0, ',', '.');
}

render_layout('Dashboard Seller', function (): void {
    $weeklyRevenue = mock_seller_weekly_revenue();
    $maxRevenue = max(array_column($weeklyRevenue, 'value'));
    $recentOrders = mock_seller_recent_orders();
    $lowStock = mock_seller_low_stock();
    ?>
    <section class="seller-hero">
        <div class="seller-hero-copy">
            <span class="eyebrow">Ringkasan hari ini</span>
            <h2>Penjualan naik 28% dari minggu lalu.</h2>
            <p>Prioritaskan pesanan baru, update stok menipis, dan jaga produk aktif tetap siap dibeli.</p>
            <div class="hero-actions">
                <a class="btn btn-primary" href="<?= e(url('dashboard.php?role=seller&page=product_form')) ?>">Tambah Produk</a>
                <a class="btn btn-secondary" href="<?= e(url('dashboard.php?role=seller&page=orders')) ?>">Cek Pesanan</a>
            </div>
        </div>
        <div class="hero-illustration" aria-hidden="true">
            <div class="hero-card mini-card-one">
                <span>Order</span>
                <strong>276</strong>
                <i></i>
            </div>
            <div class="hero-card mini-card-two">
                <span>Sales</span>
                <strong><?= e(rupiah(834000)) ?></strong>
                <small>+28.14%</small>
            </div>
            <div class="hero-person">
                <div class="person-head"></div>
                <div class="person-body"></div>
                <div class="person-laptop"></div>
            </div>
        </div>
    </section>

    <div class="seller-metric-grid">
        <article class="seller-metric-card">
            <div>
                <span>Total Produk</span>
                <strong>16</strong>
                <small>Produk aktif di toko Anda</small>
            </div>
            <i class="metric-icon icon-product">P</i>
        </article>
        <article class="seller-metric-card">
            <div>
                <span>Pesanan Pending</span>
                <strong>3</strong>
                <small>Menunggu konfirmasi Anda</small>
            </div>
            <i class="metric-icon icon-warning">!</i>
        </article>
        <article class="seller-metric-card">
            <div>
                <span>Sedang Diproses</span>
                <strong>2</strong>
                <small>Dikemas dan dikirim</small>
            </div>
            <i class="metric-icon icon-process">C</i>
        </article>
        <article class="seller-metric-card">
            <div>
                <span>Total Pendapatan</span>
                <strong><?= e(rupiah(834000)) ?></strong>
                <small>8 pesanan selesai</small>
            </div>
            <i class="metric-icon icon-money">+</i>
        </article>
    </div>

    <div class="seller-dashboard-grid">
        <section class="panel seller-chart-panel">
            <div class="panel-header">
                <div>
                    <h2>Pendapatan 7 Hari Terakhir</h2>
                    <p>Grafik pendapatan dari pesanan yang telah selesai.</p>
                </div>
                <span class="status-badge badge-success">Aktif</span>
            </div>
            <div class="bar-chart">
                <?php foreach ($weeklyRevenue as $item): ?>
                    <?php $height = (int) max(18, round(($item['value'] / $maxRevenue) * 190)); ?>
                    <div class="bar-item">
                        <span><?= e(rupiah($item['value'])) ?></span>
                        <div class="bar-track">
                            <div class="bar-fill" style="height: <?= e($height) ?>px;"></div>
                        </div>
                        <strong><?= e($item['label']) ?></strong>
                    </div>
                <?php endforeach; ?>
            </div>
        </section>

        <aside class="seller-side-stack">
            <section class="panel quick-panel">
                <div class="panel-header">
                    <div>
                        <h2>Aksi Cepat</h2>
                        <p>Pintasan tugas harian.</p>
                    </div>
                </div>
                <div class="quick-actions">
                    <a class="quick-action primary" href="<?= e(url('dashboard.php?role=seller&page=product_form')) ?>">Tambah Produk <span>-></span></a>
                    <a class="quick-action" href="<?= e(url('dashboard.php?role=seller&page=orders')) ?>">Kelola Pesanan <span>-></span></a>
                    <a class="quick-action" href="<?= e(url('dashboard.php?role=seller&page=transactions')) ?>">Lihat Riwayat <span>-></span></a>
                </div>
                <div class="seller-tip">
                    <strong>Tips Seller</strong>
                    <p>Perbarui stok produk secara berkala agar pembeli tidak kecewa ketika memesan.</p>
                </div>
            </section>

            <section class="panel low-stock-panel">
                <div class="panel-header">
                    <div>
                        <h2>Stok Menipis</h2>
                        <p>Produk yang perlu segera direstok.</p>
                    </div>
                </div>
                <div class="low-stock-list">
                    <?php foreach ($lowStock as $item): ?>
                        <div class="low-stock-item">
                            <div>
                                <strong><?= e($item['nama']) ?></strong>
                                <span>Sisa <?= e($item['stok']) ?> unit</span>
                            </div>
                            <a href="<?= e(url('dashboard.php?role=seller&page=products')) ?>">Kelola</a>
                        </div>
                    <?php endforeach; ?>
                </div>
            </section>
        </aside>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pesanan Terbaru</h2>
                <p>5 pesanan terakhir dari pembeli Anda. Klik untuk melihat detail.</p>
            </div>
            <a class="btn btn-secondary" href="<?= e(url('dashboard.php?role=seller&page=orders')) ?>">Lihat Semua</a>
        </div>
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Pesanan</th>
                        <th>Nama Pembeli</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Tanggal</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($recentOrders as $order): ?>
                        <tr>
                            <td><?= e($order['id']) ?></td>
                            <td><?= e($order['pembeli']) ?></td>
                            <td><?= e(rupiah($order['total'])) ?></td>
                            <td><?php badge_status($order['status']); ?></td>
                            <td><?= e($order['tanggal']) ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
