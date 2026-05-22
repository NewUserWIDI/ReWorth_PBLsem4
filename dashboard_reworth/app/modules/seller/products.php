<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Produk Saya', function (): void {
    $rows = array_map(fn ($item) => [
        $item['id'],
        $item['nama'],
        'Rp ' . number_format($item['harga'], 0, ',', '.'),
        $item['stok'],
        $item['status'],
    ], mock_products());
    ?>
    <section class="panel">
        <div class="panel-header">
            <h2>Produk Toko</h2>
            <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php')) ?>">Tambah Produk</a>
        </div>
        <?php simple_table(['ID', 'Produk', 'Harga', 'Stok', 'Status'], $rows, [4]); ?>
    </section>
    <?php
});

