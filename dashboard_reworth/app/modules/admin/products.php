<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('admin');

render_layout('Monitoring Produk', function (): void {
    $rows = array_map(fn ($item) => [
        $item['id'],
        $item['nama'],
        $item['seller'],
        'Rp ' . number_format($item['harga'], 0, ',', '.'),
        $item['stok'],
        $item['status'],
    ], mock_products());
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Produk Mini Market</h2></div>
        <?php simple_table(['ID', 'Produk', 'Seller', 'Harga', 'Stok', 'Status'], $rows, [5]); ?>
    </section>
    <?php
});

