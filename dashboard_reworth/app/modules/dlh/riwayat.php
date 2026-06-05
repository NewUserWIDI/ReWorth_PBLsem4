<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/severity_badge.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';

require_role('dlh');

$filters = [
    'q' => $_GET['q'] ?? '',
    'status' => $_GET['status'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
];

$status = $filters['status'];
if ($status === '') {
    $reports = array_values(array_filter(
        dlh_reports($filters),
        fn (array $item): bool =>
            in_array(
                (string) ($item['status_laporan'] ?? ''),
                ['completed', 'rejected'],
                true
            )
    ));
} else {
    $reports = dlh_reports($filters);
}

$page = max(1, (int) ($_GET['page'] ?? 1));

$perPage = 5;

$totalPages = max(1, (int) ceil(count($reports) / $perPage));
$reportsPage = array_slice($reports, ($page - 1) * $perPage, $perPage);

render_layout('Riwayat', function () use ($filters, $reportsPage, $page, $totalPages): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Riwayat</h2>
                <p>Laporan selesai dan ditolak.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari laporan...">
                <select class="select" name="status">
                    <option value="">Selesai + Ditolak</option>
                    <option value="completed" <?= $filters['status'] === 'completed' ? 'selected' : '' ?>>Selesai</option>
                    <option value="rejected" <?= $filters['status'] === 'rejected' ? 'selected' : '' ?>>Ditolak</option>
                </select>
                <input class="input" type="date" name="date_from" value="<?= e((string) $filters['date_from']) ?>">
                <input class="input" type="date" name="date_to" value="<?= e((string) $filters['date_to']) ?>">
            </div>
            <button class="btn btn-primary" type="submit">Filter</button>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Laporan</th>
                        <th>Lokasi</th>
                        <th>Tingkat</th>
                        <th>Status Akhir</th>
                        <th>Alasan Ditolak</th>
                        <th>Updated</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($reportsPage === []): ?>
                        <tr><td colspan="7" style="text-align:center;color:#6b7280;">Data riwayat belum tersedia.</td></tr>
                    <?php else: ?>
                        <?php foreach ($reportsPage as $report): ?>
                            <tr>
                                <td>#<?= e((string) $report['id_laporan']) ?></td>
                                <td><?= e((string) $report['jalan']) ?>, <?= e((string) $report['kecamatan']) ?></td>
                                <td><?php severity_badge((string) $report['tingkat_keparahan']); ?></td>
                                <td><?php badge_status((string) $report['status_laporan']); ?></td>
                                <td><?= e((string) ($report['alasan_ditolak'] ?: '-')) ?></td>
                                <td><?= e((string) $report['waktu_lapor']) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/laporan_detail.php?id=' . urlencode((string) $report['id_laporan']))) ?>">Detail</a></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        <div class="card-actions" style="margin-top:14px;justify-content:flex-end;">
            <?php if ($page > 1): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $page - 1]))) ?>">Prev</a>
            <?php endif; ?>
            <span class="status-badge badge-neutral">Halaman <?= e((string) $page) ?> / <?= e((string) $totalPages) ?></span>
            <?php if ($page < $totalPages): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $page + 1]))) ?>">Next</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});

