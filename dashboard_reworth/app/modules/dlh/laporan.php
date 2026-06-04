<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/severity_badge.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';


require_role('dlh');

$tab = $_GET['tab'] ?? 'semua';

$tabStatus = match ($tab) {
    'menunggu' => 'pending',
    'diproses' => 'processing',
    'selesai' => 'completed',
    'ditolak' => 'rejected',
    default => '',
};

$filters = [
    'q' => $_GET['q'] ?? '',
    'status' => $_GET['status'] ?? $tabStatus,
    'severity' => $_GET['severity'] ?? '',
    'kecamatan' => $_GET['kecamatan'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
];

$reports = dlh_reports($filters);
$kecamatanOptions = dlh_unique_kecamatan();

render_layout('Laporan Sampah', function () use ($reports, $filters, $tab, $kecamatanOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Laporan Sampah</h2>
                <p>Kelola dan tindak lanjuti laporan masyarakat.</p>
            </div>
        </div>

        <form class="toolbar" method="get" style="margin-bottom:14px;">
            <input type="hidden" name="tab" value="<?= e($tab) ?>">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari ID, lokasi, pelapor..." style="min-width:260px;">
                <select class="select" name="status">
                    <option value="">Semua status</option>
                <option value="pending" <?= $filters['status'] === 'pending' ? 'selected' : '' ?>>Menunggu</option>
                <option value="processing" <?= $filters['status'] === 'processing' ? 'selected' : '' ?>>Diproses</option>
                <option value="completed" <?= $filters['status'] === 'completed' ? 'selected' : '' ?>>Selesai</option>
                <option value="rejected" <?= $filters['status'] === 'rejected' ? 'selected' : '' ?>>Ditolak</option>
                </select>
                <select class="select" name="severity">
                    <option value="">Semua tingkat</option>
                   <option value="">Semua tingkat</option>
                    <option value="Ringan" <?= $filters['severity'] === 'Ringan' ? 'selected' : '' ?>>Ringan</option>
                    <option value="Sedang" <?= $filters['severity'] === 'Sedang' ? 'selected' : '' ?>>Sedang</option>
                    <option value="Berat" <?= $filters['severity'] === 'Berat' ? 'selected' : '' ?>>Berat</option>
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

        <div class="tabs" style="margin-bottom:14px;">
            <a class="tab <?= $tab === 'semua' ? 'active' : '' ?>" href="?tab=semua">Semua</a>
            <a class="tab <?= $tab === 'menunggu' ? 'active' : '' ?>" href="?tab=menunggu">Menunggu</a>
            <a class="tab <?= $tab === 'diproses' ? 'active' : '' ?>" href="?tab=diproses">Diproses</a>
            <a class="tab <?= $tab === 'selesai' ? 'active' : '' ?>" href="?tab=selesai">Selesai</a>
            <a class="tab <?= $tab === 'ditolak' ? 'active' : '' ?>" href="?tab=ditolak">Ditolak</a>
        </div>

        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Laporan</th>
                        <th>Foto</th>
                        <th>Lokasi</th>
                        <th>Kecamatan</th>
                        <th>Jenis</th>
                        <th>Tingkat</th>
                        <th>Status</th>
                        <th>Waktu Lapor</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($reports === []): ?>
                        <tr><td colspan="9" style="text-align:center;color:#6b7280;">Tidak ada laporan sesuai filter.</td></tr>
                    <?php else: ?>
                        <?php foreach ($reports as $report): ?>
                            <tr>
                                <td>#<?= e((string) $report['id_laporan']) ?></td>
                                <td><img class="report-thumb" src="<?= e(url((string) $report['foto_sampah'])) ?>" alt="foto laporan" style="width:54px;height:54px;"></td>
                                <td><?= e((string) $report['jalan']) ?></td>
                                <td><?= e((string) $report['kecamatan']) ?></td>
                                <td><?= e(ucfirst((string) $report['jenis_sampah'])) ?></td>
                                <td><?php severity_badge((string) $report['tingkat_keparahan']); ?></td>
                                <td><?php badge_status((string) $report['status_laporan']); ?></td>
                                <td><?= e((string) $report['waktu_lapor']) ?></td>
                                <td>
                                    <div class="card-actions">
                                        <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/laporan_detail.php?id=' . urlencode((string) $report['id_laporan']))) ?>">Detail</a>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});

