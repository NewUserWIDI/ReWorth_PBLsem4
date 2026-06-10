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
    'include_pending' => false,
];

$modeStatus = (string) ($_GET['status'] ?? '');
if ($modeStatus === 'menunggu') {
    $filters['status_verifikasi'] = 'menunggu';
    $filters['include_pending'] = true;
} else {
    $filters['status_verifikasi'] = '';
}

$rows = admin_sellers($filters);
$page = max(1, (int) ($_GET['page'] ?? 1));
$pagination = admin_paginate($rows, $page, 10);

render_layout($modeStatus === 'menunggu' ? 'Verifikasi Pengajuan Seller' : 'Data Seller', function () use ($filters, $pagination, $modeStatus): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2><?= e($modeStatus === 'menunggu' ? 'Verifikasi Pengajuan Seller' : 'Data Seller') ?></h2>
                <p><?= e($modeStatus === 'menunggu' ? 'Lihat detail informasi pengajuan seller, lalu setujui atau tolak dengan alasan penolakan.' : 'Lihat data seller yang sudah disetujui dan tersimpan pada tabel seller.') ?></p>
            </div>
        </div>
        
        <form method="get" style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 20px;">
            <?php if ($modeStatus !== ''): ?>
                <input type="hidden" name="status" value="<?= e($modeStatus) ?>">
            <?php endif; ?>
            <div style="flex: 2; min-width: 200px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari seller..." style="width: 100%;">
            </div>
            
            <?php if ($modeStatus === 'menunggu'): ?>
                <div style="flex: 1; min-width: 150px;">
                    <input class="input" type="text" value="Menunggu Verifikasi" readonly style="width: 100%;">
                </div>
            <?php else: ?>
                <div style="flex: 1; min-width: 150px;">
                    <select class="select" name="status_toko" style="width: 100%;">
                        <option value="">Semua status toko</option>
                        <option value="aktif" <?= ($filters['status_toko'] ?? '') === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                        <option value="nonaktif" <?= ($filters['status_toko'] ?? '') === 'nonaktif' ? 'selected' : '' ?>>Nonaktif</option>
                    </select>
                </div>
            <?php endif; ?>
            
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a href="<?= e(url('app/modules/admin/sellers.php' . ($modeStatus !== '' ? '?status=' . urlencode($modeStatus) : ''))) ?>" class="btn btn-secondary" style="margin-left: 8px;">Reset</a>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th><?= e($modeStatus === 'menunggu' ? 'ID Pengajuan' : 'ID Seller') ?></th>
                        <th>Nama Toko</th>
                        <th>Pemilik</th>
                        <th>Email</th>
                        <th>No. Telepon</th>
                        <th><?= e($modeStatus === 'menunggu' ? 'Status Pengajuan' : 'Status Toko') ?></th>
                        <th><?= e($modeStatus === 'menunggu' ? 'Tanggal Pengajuan' : 'Tanggal Disetujui') ?></th>
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
                                <td><?= e((string) ($seller['no_telp'] ?? '-')) ?></td>
                                <td><?php badge_status((string) ($modeStatus === 'menunggu' ? $seller['status_verifikasi'] : $seller['status_toko'])); ?></td>
                                <td><?= e((string) $seller['tanggal_bergabung']) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/seller_detail.php?id=' . urlencode((string) $seller['id_seller']) . '&source=' . urlencode($modeStatus === 'menunggu' ? 'verification' : 'data'))) ?>"><?= e('Detail') ?></a></td>
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
