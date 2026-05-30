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
];

$rows = admin_activities($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 12);
$typeOptions = admin_unique_values(mock_admin_system_activities(), 'aktivitas');
$roleOptions = admin_unique_values(mock_admin_system_activities(), 'role');

render_layout('Aktivitas Sistem', function () use ($filters, $pagination, $typeOptions, $roleOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Aktivitas Sistem</h2>
                <p>Audit trail aktivitas platform.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari aktivitas...">
                <select class="select" name="type">
                    <option value="">Semua tipe</option>
                    <?php foreach ($typeOptions as $type): ?>
                        <option value="<?= e($type) ?>" <?= $filters['type'] === $type ? 'selected' : '' ?>><?= e($type) ?></option>
                    <?php endforeach; ?>
                </select>
                <select class="select" name="role">
                    <option value="">Semua role</option>
                    <?php foreach ($roleOptions as $role): ?>
                        <option value="<?= e($role) ?>" <?= $filters['role'] === $role ? 'selected' : '' ?>><?= e(strtoupper($role)) ?></option>
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
                <thead><tr><th>Waktu</th><th>Aktor</th><th>Role</th><th>Aktivitas</th><th>Modul</th><th>Detail</th></tr></thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="6" style="text-align:center;color:#6b7280;">Belum ada aktivitas sistem.</td></tr>
                    <?php else: foreach ($pagination['items'] as $row): ?>
                        <tr>
                            <td><?= e((string) $row['waktu']) ?></td>
                            <td><?= e((string) $row['aktor']) ?></td>
                            <td><span class="status-badge badge-info"><?= e((string) $row['role']) ?></span></td>
                            <td><?= e((string) $row['aktivitas']) ?></td>
                            <td><?= e((string) $row['modul']) ?></td>
                            <td><?= e((string) $row['detail']) ?></td>
                        </tr>
                    <?php endforeach; endif; ?>
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
