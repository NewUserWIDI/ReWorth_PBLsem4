<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('dlh');

$id = $_GET['id'] ?? 'LPR-001';
$report = array_values(array_filter(mock_reports(), fn ($item) => $item['id'] === $id))[0] ?? mock_reports()[0];

render_layout('Detail Laporan', function () use ($report): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <h2><?= e($report['id']) ?> - <?= e($report['pelapor']) ?></h2>
            <?php badge_status($report['status']); ?>
        </div>
        <p><strong>Alamat:</strong> <?= e($report['alamat']) ?></p>
        <p><strong>Jenis:</strong> <?= e(status_label($report['jenis'])) ?></p>
        <p><strong>Tingkat Keparahan:</strong> <?= e(status_label($report['keparahan'])) ?></p>
        <p><strong>Deskripsi:</strong> <?= e($report['deskripsi']) ?></p>
        <?php if ($report['alasan_penolakan'] !== ''): ?>
            <p><strong>Alasan Penolakan:</strong> <?= e($report['alasan_penolakan']) ?></p>
        <?php endif; ?>
    </section>

    <section class="panel">
        <div class="panel-header"><h2>Verifikasi Laporan</h2></div>
        <form method="post" action="<?= e(url('dashboard.php?role=dlh&page=verification_action')) ?>" class="action-row" data-confirm="Validasi laporan ini?">
            <input type="hidden" name="id" value="<?= e($report['id']) ?>">
            <input type="hidden" name="action" value="valid">
            <button class="btn btn-primary" type="submit">Validasi Laporan</button>
        </form>
        <hr>
        <form method="post" action="<?= e(url('dashboard.php?role=dlh&page=verification_action')) ?>" data-confirm="Tolak laporan ini?">
            <input type="hidden" name="id" value="<?= e($report['id']) ?>">
            <input type="hidden" name="action" value="reject">
            <label class="form-field">
                <span>Alasan Penolakan</span>
                <textarea name="reason" placeholder="Contoh: foto tidak jelas, lokasi tidak sesuai, atau laporan terlalu kecil."></textarea>
            </label>
            <button class="btn btn-danger" type="submit">Tolak Laporan</button>
        </form>
    </section>
    <?php
});
