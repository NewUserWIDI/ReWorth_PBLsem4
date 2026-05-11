<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';

require_active_seller();

render_layout('Profil Toko', function (): void {
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Eco Craft</h2></div>
        <p><strong>Kategori:</strong> Kerajinan Daur Ulang</p>
        <p><strong>Deskripsi:</strong> Menjual produk ramah lingkungan dari material daur ulang.</p>
        <p><strong>Status:</strong> Aktif</p>
    </section>
    <?php
});

