<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$transactions = seller_fetch_transactions($sellerUserId);
$balance = array_sum(array_map(static fn (array $row): float => (float) ($row['jumlah'] ?? 0), $transactions));

render_layout('Saldo', function () use ($transactions, $balance): void {
    ?>
    <section class="balance-card">
        <span>Saldo Tersedia</span>
        <strong>Rp <?= e(number_format((int) $balance, 0, ',', '.')) ?></strong>
        <button class="btn btn-secondary" type="button" disabled>Tarik Saldo</button>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Riwayat Transaksi</h2>
                <p>Mutasi saldo dari pesanan selesai.</p>
            </div>
        </div>
        <?php if ($transactions === []): ?>
            <div class="empty-state">Belum ada transaksi saldo.</div>
        <?php else: ?>
            <div class="table-wrap">
                <table class="data-table">
                    <thead><tr><th>Tanggal</th><th>Deskripsi</th><th>Tipe</th><th>Jumlah</th><th>Status</th></tr></thead>
                    <tbody>
                        <?php foreach ($transactions as $trx): ?>
                            <tr>
                                <td><?= e(substr((string) $trx['tanggal'], 0, 10)) ?></td>
                                <td><?= e((string) $trx['deskripsi']) ?></td>
                                <td><?= e((string) $trx['tipe']) ?></td>
                                <td>Rp <?= e(number_format((int) $trx['jumlah'], 0, ',', '.')) ?></td>
                                <td><?php badge_status((string) $trx['status']); ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>
    <?php
});
