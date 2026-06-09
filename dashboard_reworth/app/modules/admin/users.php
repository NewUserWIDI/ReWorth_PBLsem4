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

render_layout('Manajemen User', function () use ($filters, $pagination): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Manajemen User</h2>
                <p>Kelola semua pengguna platform ReWorth.</p>
            </div>
        </div>
        
        <!-- FILTER FORM - SAMA SEPERTI MANAJEMEN SELLER -->
        <form method="get" style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 20px;">
            <div style="flex: 2; min-width: 200px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari user..." style="width: 100%;">
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="role" style="width: 100%;">
                    <option value="">Semua role</option>
                    <option value="masyarakat" <?= ($filters['role'] ?? '') === 'masyarakat' ? 'selected' : '' ?>>Masyarakat</option>
                    <option value="seller" <?= ($filters['role'] ?? '') === 'seller' ? 'selected' : '' ?>>Seller</option>
                    <option value="admin" <?= ($filters['role'] ?? '') === 'admin' ? 'selected' : '' ?>>Admin</option>
                    <option value="dlh" <?= ($filters['role'] ?? '') === 'dlh' ? 'selected' : '' ?>>DLH</option>
                </select>
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="status" style="width: 100%;">
                    <option value="">Semua status</option>
                    <option value="aktif" <?= ($filters['status'] ?? '') === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                    <option value="suspend" <?= ($filters['status'] ?? '') === 'suspend' ? 'selected' : '' ?>>Suspend</option>
                </select>
            </div>
            
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a href="<?= e(url('app/modules/admin/users.php')) ?>" class="btn btn-secondary" style="margin-left: 8px;">Reset</a>
            </div>
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
                                <td><span class="status-badge badge-neutral"><?= e(ucfirst((string) $user['role'])) ?></span></td>
                                <td><?php badge_status((string) $user['status']); ?></td>
                                <td><?= e((string) $user['tanggal_bergabung']) ?></td>
                                <td>
                                    <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/user_detail.php?id=' . urlencode((string) $user['id_user']))) ?>">Detail</a>
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