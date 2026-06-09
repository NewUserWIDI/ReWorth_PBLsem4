<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'status' => $_GET['status'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
];

// Ambil data transaksi dari database (bukan mock)
$rows = admin_transactions($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 10);

// Hitung statistik dari data real
$totalValue = array_sum(array_map(fn (array $row): int => (int) ($row['total'] ?? 0), $rows));
$statusDone = count(array_filter($rows, fn (array $row): bool => in_array(($row['status'] ?? ''), ['selesai', 'completed'])));
$statusPending = count(array_filter($rows, fn (array $row): bool => in_array(($row['status'] ?? ''), ['pending', 'menunggu pembayaran', 'Menunggu Pembayaran', 'menunggu verifikasi'])));
$totalTransactions = count($rows);

render_layout('Transaksi', function () use ($filters, $pagination, $totalValue, $statusDone, $statusPending, $totalTransactions): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('Total Transaksi', (string) $totalTransactions, 'Global transaksi'); ?>
        <?php stat_card('Total Nilai Transaksi', 'Rp ' . number_format($totalValue, 0, ',', '.'), 'Akumulasi semua transaksi'); ?>
        <?php stat_card('Transaksi Selesai', (string) $statusDone, 'Status selesai'); ?>
        <?php stat_card('Transaksi Pending', (string) $statusPending, 'Perlu dipantau'); ?>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Transaksi</h2>
                <p>Monitoring transaksi mini market global.</p>
            </div>
        </div>
        <form method="get" style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 20px;">
            <div style="flex: 2; min-width: 200px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari invoice/pembeli/seller..." style="width: 100%;">
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="status" style="width: 100%;">
                    <option value="">Semua status</option>
                    <option value="pending" <?= ($filters['status'] ?? '') === 'pending' ? 'selected' : '' ?>>Pending</option>
                    <option value="diproses" <?= ($filters['status'] ?? '') === 'diproses' ? 'selected' : '' ?>>Diproses</option>
                    <option value="selesai" <?= ($filters['status'] ?? '') === 'selesai' ? 'selected' : '' ?>>Selesai</option>
                    <option value="dibatalkan" <?= ($filters['status'] ?? '') === 'dibatalkan' ? 'selected' : '' ?>>Dibatalkan</option>
                </select>
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <input class="input" type="date" name="date_from" value="<?= e((string) $filters['date_from']) ?>" style="width: 100%;">
            </div>
            <div class="date-separator">—</div>
            <div style="flex: 1; min-width: 150px;">
                <input class="input" type="date" name="date_to" value="<?= e((string) $filters['date_to']) ?>" style="width: 100%;">
            </div>
            
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a href="<?= e(url('app/modules/admin/transaksi.php')) ?>" class="btn btn-secondary" style="margin-left: 8px;">Reset</a>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Transaksi</th>
                        <th>Kode Pesanan</th>
                        <th>Pembeli</th>
                        <th>Seller</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Tanggal</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr>
                            <td colspan="8" style="text-align:center;color:#6b7280; padding: 40px;">
                                📭 Belum ada transaksi.
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $item): ?>
                            <tr>
                                <td><strong><?= e((string) $item['id_transaksi']) ?></strong></td>
                                <td><?= e((string) ($item['kode_pesanan'] ?? '-')) ?></td>
                                <td><?= e((string) $item['pembeli']) ?></td>
                                <td><?= e((string) $item['seller']) ?></td>
                                <td>Rp <?= e(number_format((int) $item['total'], 0, ',', '.')) ?></td>
                                <td><?php badge_status((string) $item['status']); ?></td>
                                <td><?= e((string) $item['tanggal']) ?></td>
                                <td>
                                    <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/transaksi_detail.php?id=' . urlencode((string) $item['id_transaksi']))) ?>" 
                                       style="padding: 6px 12px; font-size: 12px;">
                                        Detail
                                    </a>
                                </td>
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