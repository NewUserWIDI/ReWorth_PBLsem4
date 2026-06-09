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
        
        <!-- FILTER FORM - SAMA PERSIS DENGAN USERS.PHP -->
        <form method="get" style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 20px;">
            <div style="flex: 2; min-width: 200px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari ID / pelapor / lokasi..." style="width: 100%;">
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="status" style="width: 100%;">
                    <option value="">Semua status</option>
                    <option value="menunggu" <?= ($filters['status'] ?? '') === 'menunggu' ? 'selected' : '' ?>>Menunggu</option>
                    <option value="diproses" <?= ($filters['status'] ?? '') === 'diproses' ? 'selected' : '' ?>>Diproses</option>
                    <option value="selesai" <?= ($filters['status'] ?? '') === 'selesai' ? 'selected' : '' ?>>Selesai</option>
                    <option value="ditolak" <?= ($filters['status'] ?? '') === 'ditolak' ? 'selected' : '' ?>>Ditolak</option>
                    <option value="completed" <?= ($filters['status'] ?? '') === 'completed' ? 'selected' : '' ?>>Completed</option>
                    <option value="rejected" <?= ($filters['status'] ?? '') === 'rejected' ? 'selected' : '' ?>>Rejected</option>
                </select>
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="severity" style="width: 100%;">
                    <option value="">Semua tingkat</option>
                    <option value="ringan" <?= ($filters['severity'] ?? '') === 'ringan' ? 'selected' : '' ?>>Ringan</option>
                    <option value="sedang" <?= ($filters['severity'] ?? '') === 'sedang' ? 'selected' : '' ?>>Sedang</option>
                    <option value="parah" <?= ($filters['severity'] ?? '') === 'parah' ? 'selected' : '' ?>>Parah</option>
                    <option value="berat" <?= ($filters['severity'] ?? '') === 'berat' ? 'selected' : '' ?>>Berat</option>
                </select>
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="kecamatan" style="width: 100%;">
                    <option value="">Semua kecamatan</option>
                    <?php foreach ($kecamatanOptions as $kecamatan): ?>
                        <option value="<?= e($kecamatan) ?>" <?= ($filters['kecamatan'] ?? '') === $kecamatan ? 'selected' : '' ?>><?= e($kecamatan) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a href="<?= e(url('app/modules/admin/laporan_sampah.php')) ?>" class="btn btn-secondary" style="margin-left: 8px;">Reset</a>
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
                                <td><?= e((string) $report['id_laporan']) ?></td>
                                <td><?= e((string) ($report['nama_pelapor'] ?? '-')) ?></td>
                                <td><?= e((string) ($report['jalan'] ?? '-')) ?></td>
                                <td><?= e((string) ($report['kecamatan'] ?? '-')) ?></td>
                                <td><?php severity_badge((string) ($report['tingkat_keparahan'] ?? '')); ?></td>
                                <td><?php badge_status((string) ($report['status_laporan'] ?? '')); ?></td>
                                <td><?= e(substr((string) ($report['waktu_lapor'] ?? ''), 0, 10)) ?></td>
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