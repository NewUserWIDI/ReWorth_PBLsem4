<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('admin');

$stats = mock_stats();

render_layout('Dashboard Admin', function () use ($stats): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('User Terdaftar', $stats['users'], 'Masyarakat mobile'); ?>
        <?php stat_card('Laporan Sampah', $stats['reports_total'], 'Total laporan'); ?>
        <?php stat_card('Seller Aktif', $stats['active_sellers'], 'Mini market'); ?>
        <?php stat_card('Reward', $stats['rewards'], 'Pulsa/kuota'); ?>
    </div>

    <section class="panel">
        <div class="panel-header">
            <h2>Laporan Terbaru</h2>
        </div>
        <?php simple_table(['ID', 'Pelapor', 'Alamat', 'Jenis', 'Keparahan', 'Status', 'Tanggal'], mock_reports(), ['status']); ?>
    </section>
    <?php
});

