<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Saldo', function (): void {
    $completed = array_values(array_filter(mock_orders(), fn ($item) => $item['status'] === 'selesai'));
    $balance = array_sum(array_column($completed, 'total'));
    ?>
    <section class="balance-card">
        <span>Saldo Tersedia</span>
        <strong>Rp <?= e(number_format((int) $balance, 0, ',', '.')) ?></strong>
        <button class="btn btn-secondary" type="button">Tarik Saldo</button>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Riwayat Transaksi</h2>
                <p>Mutasi saldo dari pesanan selesai dan penarikan.</p>
            </div>
        </div>
        <?php if ($completed === []): ?>
            <div class="empty-state">Belum ada transaksi saldo.</div>
        <?php else: ?>
            <div class="table-wrap">
                <table class="data-table">
                    <thead><tr><th>Tanggal</th><th>Deskripsi</th><th>Tipe</th><th>Jumlah</th><th>Status</th></tr></thead>
                    <tbody>
                        <?php foreach ($completed as $order): ?>
                            <tr>
                                <td><?= e($order['tanggal']) ?></td>
                                <td>Penjualan <?= e($order['id']) ?></td>
                                <td>Masuk</td>
                                <td>Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?></td>
                                <td><?php badge_status('selesai'); ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>
    <?php
});
