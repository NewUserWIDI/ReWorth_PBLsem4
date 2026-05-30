<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'role' => $_GET['role'] ?? '',
    'status' => $_GET['status'] ?? '',
];
$rows = admin_users($filters);
$page = max(1, (int) ($_GET['page'] ?? 1));
$pagination = admin_paginate($rows, $page, 10);
$roleOptions = admin_unique_values(mock_admin_users(), 'role');

render_layout('Manajemen User', function () use ($filters, $pagination, $roleOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Manajemen User</h2>
                <p>Kelola semua pengguna platform ReWorth.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari nama/email user...">
                <select class="select" name="role">
                    <option value="">Semua role</option>
                    <?php foreach ($roleOptions as $role): ?>
                        <option value="<?= e($role) ?>" <?= $filters['role'] === $role ? 'selected' : '' ?>><?= e(ucfirst($role)) ?></option>
                    <?php endforeach; ?>
                </select>
                <select class="select" name="status">
                    <option value="">Semua status</option>
                    <option value="aktif" <?= $filters['status'] === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                    <option value="suspend" <?= $filters['status'] === 'suspend' ? 'selected' : '' ?>>Suspend</option>
                </select>
            </div>
            <button class="btn btn-primary" type="submit">Filter</button>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID User</th>
                        <th>Nama</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Tanggal Bergabung</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="7" style="text-align:center;color:#6b7280;">Belum ada user.</td></tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $user): ?>
                            <tr>
                                <td><?= e((string) $user['id_user']) ?></td>
                                <td><?= e((string) $user['nama']) ?></td>
                                <td><?= e((string) $user['email']) ?></td>
                                <td><span class="status-badge badge-neutral"><?= e((string) $user['role']) ?></span></td>
                                <td><?php badge_status((string) $user['status']); ?></td>
                                <td><?= e((string) $user['tanggal_bergabung']) ?></td>
                                <td>
                                    <div class="card-actions">
                                        <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/user_detail.php?id=' . urlencode((string) $user['id_user']))) ?>">Detail</a>
                                    </div>
                                </td>
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

