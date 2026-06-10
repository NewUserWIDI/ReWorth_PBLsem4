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
        fn(array $item) =>
            $item['status_laporan'] !== 'pending'
            && $item['status_laporan'] !== 'processing'
    ));
}


else {
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
                <h2>Riwayat Laporan</h2>
               <p>Arsip laporan yang telah selesai diproses atau ditolak oleh DLH.</p>
            </div>
        </div>
                <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input
                    class="input"
                    type="search"
                    name="q"
                    value="<?= e((string) $filters['q']) ?>"
                    placeholder="Cari laporan..."
                >
            </div>

            <button class="btn btn-primary" type="submit">
                Filter
            </button>
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
                    <th>Status</th>
                    <th>Tanggal Selesai</th>
                    <th>Detail</th>
                </tr>
                </thead>

                <tbody>
                <?php if ($reportsPage === []): ?>
                <tr>
                    <td colspan="6" style="text-align:center;color:#6b7280;">
                        Belum ada riwayat laporan.
                    </td>
                </tr>
                <?php else: ?>

                <?php foreach ($reportsPage as $report): ?>

                <tr>

                    <td>
                        #<?= e((string)$report['id_laporan']) ?>
                    </td>

                    <td>
                        <?= e((string)$report['jalan']) ?>,
                        <?= e((string)$report['kecamatan']) ?>
                    </td>

                    <td>
                        <?php severity_badge((string)$report['tingkat_keparahan']); ?>
                    </td>

                    <td>
                        <?php if (($report['status_laporan'] ?? '') === 'rejected'): ?>
                            <span class="status-badge badge-danger">Ditolak</span>
                        <?php else: ?>
                            <span class="status-badge badge-success">Selesai</span>
                        <?php endif; ?>
                        </td>

                    <td>
                        <?= e((string)$report['waktu_lapor']) ?>
                    </td>

                    <td>
                        <a
                            class="btn btn-secondary"
                            href="<?= e(url('app/modules/dlh/laporan_detail.php?id=' . urlencode((string)$report['id_laporan']))) ?>"
                        >
                            Detail
                        </a>
                    </td>

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
            <span class="status-badge badge-success">Selesai</span>
            <?php if ($page < $totalPages): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $page + 1]))) ?>">Next</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});

