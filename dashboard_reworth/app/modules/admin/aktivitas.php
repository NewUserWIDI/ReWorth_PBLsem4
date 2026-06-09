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

// Ambil data aktivitas dari database
$rows = admin_activities($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 12);

// Opsi filter dari data real
$typeOptions = array_values(array_unique(array_column($rows, 'aktivitas')));
$roleOptions = array_values(array_unique(array_column($rows, 'role')));

render_layout('Aktivitas Sistem', function () use ($filters, $pagination, $typeOptions, $roleOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Aktivitas Sistem</h2>
                <p>Audit trail aktivitas platform.</p>
            </div>
        </div>
        
        <!-- FILTER FORM - SEPERTI MANAJEMEN USER -->
        <form method="get" style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 20px;">
            <div style="flex: 2; min-width: 200px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari aktivitas..." style="width: 100%;">
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="type" style="width: 100%;">
                    <option value="">Semua tipe</option>
                    <?php foreach ($typeOptions as $type): ?>
                        <option value="<?= e($type) ?>" <?= ($filters['type'] ?? '') === $type ? 'selected' : '' ?>><?= e($type) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="role" style="width: 100%;">
                    <option value="">Semua role</option>
                    <?php foreach ($roleOptions as $role): ?>
                        <option value="<?= e($role) ?>" <?= ($filters['role'] ?? '') === $role ? 'selected' : '' ?>><?= e(ucfirst($role)) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <input class="input" type="date" name="date_from" value="<?= e((string) $filters['date_from']) ?>" placeholder="Dari tanggal" style="width: 100%;">
            </div>
            <div class="date-separator">—</div>
            <div style="flex: 1; min-width: 150px;">
                <input class="input" type="date" name="date_to" value="<?= e((string) $filters['date_to']) ?>" placeholder="Sampai tanggal" style="width: 100%;">
            </div>
            
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a href="<?= e(url('app/modules/admin/aktivitas.php')) ?>" class="btn btn-secondary" style="margin-left: 8px;">Reset</a>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Waktu</th>
                        <th>Aktor</th>
                        <th>Role</th>
                        <th>Aktivitas</th>
                        <th>Modul</th>
                        <th>Detail</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr>
                            <td colspan="6" style="text-align:center;color:#6b7280; padding: 40px;">
                                📭 Belum ada aktivitas sistem.
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $row): ?>
                            <tr>
                                <td><?= e((string) $row['waktu']) ?></td>
                                <td><?= e((string) $row['aktor']) ?></td>
                                <td><span class="status-badge badge-info"><?= e(ucfirst((string) $row['role'])) ?></span></td>
                                <td><?= e((string) $row['aktivitas']) ?></td>
                                <td><?= e((string) $row['modul']) ?></td>
                                <td><?= e((string) $row['detail']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- PAGINATION -->
        <div class="card-actions" style="justify-content: flex-end; margin-top: 20px; gap: 12px;">
            <?php if ($pagination['page'] > 1): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] - 1]))) ?>">◀ Prev</a>
            <?php endif; ?>
            
            <span class="status-badge badge-neutral">
                Halaman <?= e((string) $pagination['page']) ?> dari <?= e((string) $pagination['total_pages']) ?>
            </span>
            
            <?php if ($pagination['page'] < $pagination['total_pages']): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] + 1]))) ?>">Next ▶</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});