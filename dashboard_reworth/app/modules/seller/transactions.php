<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Riwayat Transaksi', function (): void {
    $rows = array_map(fn ($item) => [
        $item['id'],
        $item['pembeli'],
        'Rp ' . number_format($item['total'], 0, ',', '.'),
        $item['status'],
        $item['tanggal'],
    ], array_filter(mock_orders(), fn ($item) => $item['status'] === 'selesai'));
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Transaksi Selesai</h2></div>
        <?php simple_table(['ID', 'Pembeli', 'Total', 'Status', 'Tanggal'], $rows, [3]); ?>
    </section>
    <?php
});

