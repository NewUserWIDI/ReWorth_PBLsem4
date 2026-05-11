<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('admin');

render_layout('Monitoring Pesanan', function (): void {
    $rows = array_map(fn ($item) => [
        $item['id'],
        $item['pembeli'],
        'Rp ' . number_format($item['total'], 0, ',', '.'),
        $item['status'],
        $item['tanggal'],
    ], mock_orders());
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Pesanan Mini Market</h2></div>
        <?php simple_table(['ID', 'Pembeli', 'Total', 'Status', 'Tanggal'], $rows, [3]); ?>
    </section>
    <?php
});

