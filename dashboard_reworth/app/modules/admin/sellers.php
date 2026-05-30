<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'status_verifikasi' => $_GET['status_verifikasi'] ?? '',
    'status_toko' => $_GET['status_toko'] ?? '',
];

$rows = admin_sellers($filters);
$page = max(1, (int) ($_GET['page'] ?? 1));
$pagination = admin_paginate($rows, $page, 10);
$statusVerificationOptions = admin_unique_values(mock_admin_sellers(), 'status_verifikasi');
$statusTokoOptions = admin_unique_values(mock_admin_sellers(), 'status_toko');

render_layout('Manajemen Seller', function () use ($filters, $pagination, $statusVerificationOptions, $statusTokoOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Manajemen Seller</h2>
                <p>Kelola semua seller dan verifikasi toko.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari seller...">
                <select class="select" name="status_verifikasi">
                    <option value="">Semua status verifikasi</option>
                    <?php foreach ($statusVerificationOptions as $status): ?>
                        <option value="<?= e($status) ?>" <?= $filters['status_verifikasi'] === $status ? 'selected' : '' ?>><?= e(status_label($status)) ?></option>
                    <?php endforeach; ?>
                </select>
                <select class="select" name="status_toko">
                    <option value="">Semua status toko</option>
                    <?php foreach ($statusTokoOptions as $status): ?>
                        <option value="<?= e($status) ?>" <?= $filters['status_toko'] === $status ? 'selected' : '' ?>><?= e(status_label($status)) ?></option>
                    <?php endforeach; ?>
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
                        <th>ID Seller</th>
                        <th>Nama Toko</th>
                        <th>Pemilik</th>
                        <th>Email</th>
                        <th>Jumlah Produk</th>
                        <th>Status Verifikasi</th>
                        <th>Tanggal Bergabung</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="8" style="text-align:center;color:#6b7280;">Belum ada seller.</td></tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $seller): ?>
                            <tr>
                                <td><?= e((string) $seller['id_seller']) ?></td>
                                <td><?= e((string) $seller['nama_toko']) ?></td>
                                <td><?= e((string) $seller['pemilik']) ?></td>
                                <td><?= e((string) $seller['email']) ?></td>
                                <td><?= e((string) $seller['jumlah_produk']) ?></td>
                                <td><?php badge_status((string) $seller['status_verifikasi']); ?></td>
                                <td><?= e((string) $seller['tanggal_bergabung']) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/seller_detail.php?id=' . urlencode((string) $seller['id_seller']))) ?>">Detail</a></td>
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
