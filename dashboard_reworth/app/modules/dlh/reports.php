<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('dlh');

render_layout('Laporan Sampah', function (): void {
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Daftar Laporan</h2></div>
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr><th>ID</th><th>Pelapor</th><th>Alamat</th><th>Keparahan</th><th>Status</th><th>Aksi</th></tr>
                </thead>
                <tbody>
                    <?php foreach (mock_reports() as $report): ?>
                        <tr>
                            <td><?= e($report['id']) ?></td>
                            <td><?= e($report['pelapor']) ?></td>
                            <td><?= e($report['alamat']) ?></td>
                            <td><?= e($report['keparahan']) ?></td>
                            <td><?php badge_status($report['status']); ?></td>
                            <td><a class="btn btn-secondary" href="<?= e(url('dashboard.php?role=dlh&page=report_detail&id=' . $report['id'])) ?>">Detail</a></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
