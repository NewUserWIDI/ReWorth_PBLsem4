<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/severity_badge.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'status' => $_GET['status'] ?? '',
    'severity' => $_GET['severity'] ?? '',
    'kecamatan' => $_GET['kecamatan'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
];

$rows = dlh_reports($filters);
$page = max(1, (int) ($_GET['page'] ?? 1));
$pagination = admin_paginate($rows, $page, 10);
$kecamatanOptions = dlh_unique_kecamatan();

render_layout('Laporan Sampah', function () use ($filters, $pagination, $kecamatanOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Laporan Sampah</h2>
                <p>Monitoring dan audit laporan lintas sistem.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari ID/pelapor/lokasi...">
                <select class="select" name="status">
                    <option value="">Semua status</option>
                    <option value="menunggu" <?= $filters['status'] === 'menunggu' ? 'selected' : '' ?>>Menunggu</option>
                    <option value="diproses" <?= $filters['status'] === 'diproses' ? 'selected' : '' ?>>Diproses</option>
                    <option value="selesai" <?= $filters['status'] === 'selesai' ? 'selected' : '' ?>>Selesai</option>
                    <option value="ditolak" <?= $filters['status'] === 'ditolak' ? 'selected' : '' ?>>Ditolak</option>
                </select>
                <select class="select" name="severity">
                    <option value="">Semua tingkat</option>
                    <option value="ringan" <?= $filters['severity'] === 'ringan' ? 'selected' : '' ?>>Ringan</option>
                    <option value="sedang" <?= $filters['severity'] === 'sedang' ? 'selected' : '' ?>>Sedang</option>
                    <option value="parah" <?= $filters['severity'] === 'parah' ? 'selected' : '' ?>>Parah</option>
                </select>
                <select class="select" name="kecamatan">
                    <option value="">Semua kecamatan</option>
                    <?php foreach ($kecamatanOptions as $kecamatan): ?>
                        <option value="<?= e($kecamatan) ?>" <?= $filters['kecamatan'] === $kecamatan ? 'selected' : '' ?>><?= e($kecamatan) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="toolbar-right">
                <input class="input" type="date" name="date_from" value="<?= e((string) $filters['date_from']) ?>">
                <input class="input" type="date" name="date_to" value="<?= e((string) $filters['date_to']) ?>">
                <button class="btn btn-primary" type="submit">Filter</button>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Laporan</th>
                        <th>Pelapor</th>
                        <th>Lokasi</th>
                        <th>Kecamatan</th>
                        <th>Tingkat</th>
                        <th>Status</th>
                        <th>Tanggal</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="8" style="text-align:center;color:#6b7280;">Belum ada laporan.</td></tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $report): ?>
                            <tr>
                                <td>#<?= e((string) $report['id_laporan']) ?></td>
                                <td><?= e((string) $report['pelapor']) ?></td>
                                <td><?= e((string) $report['jalan']) ?></td>
                                <td><?= e((string) $report['kecamatan']) ?></td>
                                <td><?php severity_badge((string) $report['tingkat_keparahan']); ?></td>
                                <td><?php badge_status((string) $report['status_laporan']); ?></td>
                                <td><?= e(substr((string) $report['waktu_lapor'], 0, 10)) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/laporan_detail.php?id=' . urlencode((string) $report['id_laporan']))) ?>">Detail</a></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        <div class="card-actions" style="justify-content:flex-end;">
            <?php if ($pagination['page'] > 1): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] - 1]))) ?>">Prev</a>
            <?php endif; ?>
            <span class="status-badge badge-neutral">Halaman <?= e((string) $pagination['page']) ?> / <?= e((string) $pagination['total_pages']) ?></span>
            <?php if ($pagination['page'] < $pagination['total_pages']): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] + 1]))) ?>">Next</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});
