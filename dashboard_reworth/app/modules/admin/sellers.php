<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('admin');

render_layout('Data Seller', function (): void {
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Seller ReWorth</h2></div>
        <?php simple_table(['ID', 'Nama Toko', 'Jumlah Produk', 'Status'], mock_sellers(), ['status']); ?>
    </section>
    <?php
});

