<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'type' => $_GET['type'] ?? '',
    'role' => $_GET['role'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
    'period' => $_GET['period'] ?? 'selamanya',
];

$rows = admin_activities(array_merge($filters, ['limit' => 500]));
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 12);

$typeOptions = array_values(array_unique(array_map(
    static fn (array $row): string => (string) ($row['type_key'] ?? ''),
    $rows
)));
$typeOptions = array_values(array_filter($typeOptions, static fn (string $value): bool => $value !== ''));

$roleOptions = array_values(array_unique(array_map(
    static fn (array $row): string => (string) ($row['role'] ?? ''),
    $rows
)));
$roleOptions = array_values(array_filter($roleOptions, static fn (string $value): bool => $value !== ''));

$activityTypeLabels = [
    'registrasi' => 'Registrasi Akun',
    'transaksi' => 'Belanja Mini Market',
    'pengajuan_seller' => 'Pengajuan Seller',
    'tukar_poin' => 'Tukar Poin',
    'lapor_sampah' => 'Lapor Sampah',
    'lainnya' => 'Aktivitas Lainnya',
];

$summaryCounts = [
    'registrasi' => 0,
    'transaksi' => 0,
    'pengajuan_seller' => 0,
    'tukar_poin' => 0,
    'lapor_sampah' => 0,
];
foreach ($rows as $row) {
    $typeKey = (string) ($row['type_key'] ?? '');
    if (isset($summaryCounts[$typeKey])) {
        $summaryCounts[$typeKey]++;
    }
}

$periods = [
    'selamanya' => 'Selamanya',
    'harian' => 'Harian',
    'mingguan' => 'Mingguan',
    'bulanan' => 'Bulanan',
];

render_layout('Aktivitas Sistem', function () use ($filters, $pagination, $typeOptions, $roleOptions, $activityTypeLabels, $summaryCounts, $periods, $rows): void {
    ?>
    <section class="panel activity-page-hero">
        <div class="panel-header">
            <div>
                <h2>Aktivitas Sistem</h2>
                <p>Audit trail platform ReWorth dari registrasi akun, laporan sampah, transaksi mini market, pengajuan seller, dan tukar poin.</p>
            </div>
        </div>

        <div class="activity-filter-tabs">
            <?php foreach ($periods as $value => $label): ?>
                <?php $query = array_merge($_GET, ['period' => $value, 'page' => 1]); ?>
                <a class="activity-filter-tab <?= ($filters['period'] ?? 'selamanya') === $value ? 'active' : '' ?>" href="<?= e(url('app/modules/admin/aktivitas.php?' . http_build_query($query))) ?>">
                    <?= e($label) ?>
                </a>
            <?php endforeach; ?>
        </div>

        <div class="quick-cards activity-summary-grid">
            <div class="quick-card activity-summary-card">
                <strong><?= e((string) count($rows)) ?></strong>
                <span>Total aktivitas terfilter</span>
            </div>
            <div class="quick-card activity-summary-card">
                <strong><?= e((string) ($summaryCounts['registrasi'] ?? 0)) ?></strong>
                <span>Registrasi akun</span>
            </div>
            <div class="quick-card activity-summary-card">
                <strong><?= e((string) ($summaryCounts['transaksi'] ?? 0)) ?></strong>
                <span>Belanja mini market</span>
            </div>
            <div class="quick-card activity-summary-card">
                <strong><?= e((string) (($summaryCounts['pengajuan_seller'] ?? 0) + ($summaryCounts['tukar_poin'] ?? 0) + ($summaryCounts['lapor_sampah'] ?? 0))) ?></strong>
                <span>Aktivitas operasional lain</span>
            </div>
        </div>

        <form method="get" class="activity-filter-form">
            <input type="hidden" name="period" value="<?= e((string) ($filters['period'] ?? 'selamanya')) ?>">
            <div class="activity-filter-grid">
                <label class="form-field">
                    <span>Cari Aktivitas</span>
                    <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari aktor, aktivitas, modul, atau detail...">
                </label>
                <label class="form-field">
                    <span>Tipe</span>
                    <select class="select" name="type">
                        <option value="">Semua tipe</option>
                        <?php foreach ($typeOptions as $type): ?>
                            <option value="<?= e($type) ?>" <?= ($filters['type'] ?? '') === $type ? 'selected' : '' ?>><?= e($activityTypeLabels[$type] ?? ucfirst(str_replace('_', ' ', $type))) ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label class="form-field">
                    <span>Role</span>
                    <select class="select" name="role">
                        <option value="">Semua role</option>
                        <?php foreach ($roleOptions as $role): ?>
                            <option value="<?= e($role) ?>" <?= ($filters['role'] ?? '') === $role ? 'selected' : '' ?>><?= e($role) ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label class="form-field">
                    <span>Dari Tanggal</span>
                    <input class="input" type="date" name="date_from" value="<?= e((string) $filters['date_from']) ?>">
                </label>
                <label class="form-field">
                    <span>Sampai Tanggal</span>
                    <input class="input" type="date" name="date_to" value="<?= e((string) $filters['date_to']) ?>">
                </label>
                <div class="activity-filter-actions">
                    <button class="btn btn-primary" type="submit">Terapkan Filter</button>
                    <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/aktivitas.php')) ?>">Reset</a>
                </div>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Daftar Aktivitas</h2>
                <p><?= e((string) $pagination['total']) ?> aktivitas cocok dengan filter saat ini.</p>
            </div>
        </div>

        <?php if ($pagination['items'] === []): ?>
            <div class="empty-state">Belum ada aktivitas sistem yang cocok dengan filter.</div>
        <?php else: ?>
            <div class="activity-detail-grid">
                <?php foreach ($pagination['items'] as $activity): ?>
                    <?php $typeKey = (string) ($activity['type_key'] ?? 'lainnya'); ?>
                    <article class="activity-detail-card activity-accent-<?= e($typeKey) ?>">
                        <div class="activity-detail-header">
                            <div>
                                <span class="activity-type-pill activity-type-<?= e($typeKey) ?>"><?= e($activityTypeLabels[$typeKey] ?? 'Aktivitas') ?></span>
                                <h3><?= e((string) ($activity['aktivitas'] ?? '-')) ?></h3>
                            </div>
                            <time><?= e((string) ($activity['waktu'] ?? '-')) ?></time>
                        </div>
                        <p class="activity-detail-copy"><?= e((string) ($activity['detail'] ?? '-')) ?></p>
                        <div class="activity-detail-footer">
                            <span class="status-badge badge-info"><?= e((string) ($activity['role'] ?? 'Sistem')) ?></span>
                            <span class="status-badge badge-neutral"><?= e((string) ($activity['modul'] ?? '-')) ?></span>
                            <strong><?= e((string) ($activity['aktor'] ?? '-')) ?></strong>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>

        <div class="card-actions activity-pagination">
            <?php if ($pagination['page'] > 1): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] - 1]))) ?>">Sebelumnya</a>
            <?php endif; ?>

            <span class="status-badge badge-neutral">Halaman <?= e((string) $pagination['page']) ?> dari <?= e((string) $pagination['total_pages']) ?></span>

            <?php if ($pagination['page'] < $pagination['total_pages']): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] + 1]))) ?>">Berikutnya</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});
