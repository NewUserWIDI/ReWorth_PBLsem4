<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$orders = seller_fetch_order_summaries($sellerUserId, ['status' => 'riwayat']);
$completedOrders = array_values(array_filter($orders, static fn (array $order): bool => (string) ($order['status_pesanan'] ?? '') === 'selesai'));
$balance = array_sum(array_map(static fn (array $row): float => (float) ($row['total'] ?? 0), $completedOrders));

render_layout('Riwayat Pesanan', function () use ($orders, $balance): void {
    ?>
    <section class="balance-card seller-history-balance">
        <span>Pendapatan Bersih dari Pesanan Selesai</span>
        <strong>Rp <?= e(number_format((int) $balance, 0, ',', '.')) ?></strong>
        <p>Nilai ini berasal dari total net seller setelah fee platform pada pesanan selesai.</p>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Riwayat Pesanan</h2>
                <p>Pesanan yang selesai atau ditolak dipindahkan ke halaman ini.</p>
            </div>
        </div>
        <?php if ($orders === []): ?>
            <div class="empty-state">Belum ada riwayat pesanan.</div>
        <?php else: ?>
            <div class="table-wrap">
                <table class="data-table">
                    <thead><tr><th>ID Pesanan</th><th>Pembeli</th><th>Tanggal</th><th>Status</th><th>Net Seller</th><th>Aksi</th></tr></thead>
                    <tbody>
                        <?php foreach ($orders as $order): ?>
                            <tr>
                                <td><?= e((string) $order['kode_pesanan']) ?></td>
                                <td><?= e((string) $order['pembeli']) ?></td>
                                <td><?= e(substr((string) $order['tanggal'], 0, 10)) ?></td>
                                <td><?php badge_status((string) $order['status_pesanan']); ?></td>
                                <td>Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/seller/order_detail.php?id=' . urlencode((string) $order['id_pesanan']))) ?>">Detail</a></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>
    <?php
});
