<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_helpers.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/stat_card.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'status_proses' => $_GET['status_proses'] ?? '',
];

$rows = admin_point_redemptions_list($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 10);

$pending = count(array_filter($rows, static fn (array $item): bool => strcasecmp((string) $item['status_proses'], 'Pending') === 0));
$sukses = count(array_filter($rows, static fn (array $item): bool => strcasecmp((string) $item['status_proses'], 'Sukses') === 0));
$gagal = count(array_filter($rows, static fn (array $item): bool => strcasecmp((string) $item['status_proses'], 'Gagal') === 0));

render_layout('Transaksi Tukar Poin', function () use ($filters, $pagination, $rows, $pending, $sukses, $gagal): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('Total Penukaran', (string) count($rows), 'Semua transaksi penukaran'); ?>
        <?php stat_card('Pending', (string) $pending, 'Belum diproses admin'); ?>
        <?php stat_card('Sukses', (string) $sukses, 'Berhasil diproses'); ?>
        <?php stat_card('Gagal', (string) $gagal, 'Perlu tindak lanjut'); ?>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Transaksi Tukar Poin</h2>
                <p>Monitoring transaksi penukaran poin user untuk reward pulsa dan kuota.</p>
            </div>
        </div>

        <form method="get" style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;">
            <div style="flex:2;min-width:220px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari user, reward, nomor tujuan, atau kode referensi..." style="width:100%;">
            </div>
            <div style="flex:1;min-width:160px;">
                <select class="select" name="status_proses" style="width:100%;">
                    <option value="">Semua status</option>
                    <option value="Pending" <?= ($filters['status_proses'] ?? '') === 'Pending' ? 'selected' : '' ?>>Pending</option>
                    <option value="Sukses" <?= ($filters['status_proses'] ?? '') === 'Sukses' ? 'selected' : '' ?>>Sukses</option>
                    <option value="Gagal" <?= ($filters['status_proses'] ?? '') === 'Gagal' ? 'selected' : '' ?>>Gagal</option>
                </select>
            </div>
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/transaksi_poin.php')) ?>" style="margin-left:8px;">Reset</a>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User</th>
                        <th>Reward</th>
                        <th>No. Tujuan</th>
                        <th>Poin</th>
                        <th>Status</th>
                        <th>Tanggal Penukaran</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="8" style="text-align:center;color:#6b7280;">Belum ada transaksi tukar poin.</td></tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $item): ?>
                            <tr>
                                <td>#<?= e((string) $item['id_penukaran']) ?></td>
                                <td><?= e((string) $item['nama_user']) ?></td>
                                <td><?= e((string) $item['reward']) ?></td>
                                <td><?= e((string) $item['no_hp_tujuan']) ?></td>
                                <td><?= e((string) $item['poin_terpakai']) ?></td>
                                <td><?php badge_status((string) $item['status_proses']); ?></td>
                                <td><?= e((string) $item['tanggal_penukaran']) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/transaksi_poin_detail.php?id=' . urlencode((string) $item['id_penukaran']))) ?>">Detail</a></td>
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
