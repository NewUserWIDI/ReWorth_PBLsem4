<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_helpers.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
];

$rows = admin_dlh_list($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 10);

render_layout('Data DLH', function () use ($filters, $pagination): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Data DLH</h2>
                <p>Kelola akun petugas DLH tanpa fitur hapus dan nonaktifkan.</p>
            </div>
            <a class="btn btn-primary" href="<?= e(url('app/modules/admin/data_dlh_form.php')) ?>">Tambah DLH</a>
        </div>

        <form method="get" style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;">
            <div style="flex:1;min-width:240px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari nama, email, telepon, atau username..." style="width:100%;">
            </div>
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/data_dlh.php')) ?>" style="margin-left:8px;">Reset</a>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Nama</th>
                        <th>Email</th>
                        <th>No. Telepon</th>
                        <th>Username</th>
                        <th>Tanggal Bergabung</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="6" style="text-align:center;color:#6b7280;">Belum ada data DLH.</td></tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $item): ?>
                            <tr>
                                <td><?= e((string) $item['nama']) ?></td>
                                <td><?= e((string) $item['email']) ?></td>
                                <td><?= e((string) $item['no_telp']) ?></td>
                                <td><?= e((string) $item['username']) ?></td>
                                <td><?= e((string) $item['tanggal_bergabung']) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/data_dlh_detail.php?id=' . urlencode((string) $item['id']))) ?>">Detail</a></td>
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
