<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('admin');

render_layout('Monitoring Laporan Sampah', function (): void {
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Semua Laporan</h2></div>
        <?php simple_table(['ID', 'Pelapor', 'Alamat', 'Jenis', 'Keparahan', 'Status', 'Tanggal'], mock_reports(), ['status']); ?>
    </section>
    <?php
});

