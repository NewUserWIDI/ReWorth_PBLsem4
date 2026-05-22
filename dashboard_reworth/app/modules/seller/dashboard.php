<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Dashboard Toko', function (): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('Produk Aktif', 12, 'Toko sendiri'); ?>
        <?php stat_card('Pesanan Baru', 3, 'Perlu diproses'); ?>
        <?php stat_card('Diproses', 5, 'Sedang dikemas'); ?>
        <?php stat_card('Total Penjualan', 'Rp 2.450.000', 'Mock bulan ini'); ?>
    </div>
    <section class="panel">
        <div class="panel-header"><h2>Pesanan Masuk</h2></div>
        <?php simple_table(['ID', 'Pembeli', 'Total', 'Status', 'Tanggal'], array_map(fn ($item) => [$item['id'], $item['pembeli'], 'Rp ' . number_format($item['total'], 0, ',', '.'), $item['status'], $item['tanggal']], mock_orders()), [3]); ?>
    </section>
    <?php
});

