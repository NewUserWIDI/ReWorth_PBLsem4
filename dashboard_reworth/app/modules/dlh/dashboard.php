<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('dlh');

$stats = mock_stats();

render_layout('Dashboard DLH', function () use ($stats): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('Menunggu', $stats['reports_waiting'], 'Perlu verifikasi'); ?>
        <?php stat_card('Valid', $stats['reports_valid'], '+10 poin/user'); ?>
        <?php stat_card('Ditolak', $stats['reports_rejected'], 'Alasan wajib'); ?>
        <?php stat_card('Total Laporan', $stats['reports_total'], 'Semua status'); ?>
    </div>
    <section class="panel">
        <div class="panel-header"><h2>Laporan Terbaru</h2></div>
        <?php simple_table(['ID', 'Pelapor', 'Alamat', 'Jenis', 'Keparahan', 'Status', 'Tanggal'], mock_reports(), ['status']); ?>
    </section>
    <?php
});

