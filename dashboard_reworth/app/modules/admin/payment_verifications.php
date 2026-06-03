<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';
require_once __DIR__ . '/../../components/admin_payment_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'status' => $_GET['status'] ?? '',
];

$rows = admin_payment_verifications($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 10);
$overview = admin_payment_overview();

render_layout('Verifikasi Pembayaran', function () use ($filters, $pagination, $overview): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('Total Bukti Bayar', (string) $overview['total'], 'Semua pembayaran masuk'); ?>
        <?php stat_card('Menunggu Verifikasi', (string) $overview['pending'], 'Perlu dicek admin'); ?>
        <?php stat_card('Terverifikasi', (string) $overview['verified'], 'Sudah diteruskan ke seller'); ?>
        <?php stat_card('Total Nilai', 'Rp ' . number_format((int) $overview['gross'], 0, ',', '.'), 'Akumulasi semua tagihan'); ?>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Verifikasi Pembayaran</h2>
                <p>Cek bukti bayar QRIS dari user sebelum pesanan masuk ke seller.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari ID pembayaran / pesanan / nama pembeli">
                <select class="select" name="status">
                    <option value="">Semua status</option>
                    <?php foreach (['Menunggu Verifikasi', 'Terverifikasi', 'Ditolak', 'Belum Upload'] as $status): ?>
                        <option value="<?= e(strtolower($status)) ?>" <?= strtolower((string) $filters['status']) === strtolower($status) ? 'selected' : '' ?>><?= e($status) ?></option>
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
                        <th>ID Pembayaran</th>
                        <th>Kode Pesanan</th>
                        <th>Pembeli</th>
                        <th>Total</th>
                        <th>Status Pembayaran</th>
                        <th>Status Pesanan</th>
                        <th>Upload Bukti</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="8" style="text-align:center;color:#6b7280;">Belum ada bukti pembayaran yang cocok.</td></tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $item): ?>
                            <tr>
                                <td><?= e((string) $item['id_pembayaran']) ?></td>
                                <td><?= e((string) $item['kode_pesanan']) ?></td>
                                <td><?= e((string) $item['buyer_name']) ?></td>
                                <td>Rp <?= e(number_format((int) $item['total_bayar'], 0, ',', '.')) ?></td>
                                <td><?php badge_status((string) $item['payment_status']); ?></td>
                                <td><?php badge_status((string) $item['order_status']); ?></td>
                                <td><?= e((string) ($item['tanggal_upload_bukti'] !== '' ? substr((string) $item['tanggal_upload_bukti'], 0, 16) : '-')) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/payment_verification_detail.php?id=' . urlencode((string) $item['id_pembayaran']))) ?>">Detail</a></td>
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
