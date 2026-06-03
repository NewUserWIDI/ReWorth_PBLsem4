<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$customers = seller_fetch_customers($sellerUserId);
$totalOrders = array_sum(array_map(static fn (array $row): int => (int) ($row['orders'] ?? 0), $customers));
$totalSpend = array_sum(array_map(static fn (array $row): float => (float) ($row['total'] ?? 0), $customers));
$repeatCustomers = count(array_filter($customers, static fn (array $row): bool => (int) ($row['orders'] ?? 0) > 1));

render_layout('Pelanggan', function () use ($customers, $totalOrders, $totalSpend, $repeatCustomers): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('Total Pelanggan', count($customers), 'Dari pesanan toko', 'primary'); ?>
        <?php stat_card('Repeat Order', $repeatCustomers, 'Pelanggan dengan pesanan > 1'); ?>
        <?php stat_card('Total Pesanan', $totalOrders, 'Akumulasi semua order', 'lime'); ?>
        <?php stat_card('Total Belanja', 'Rp ' . number_format((int) $totalSpend, 0, ',', '.'), 'Akumulasi penjualan seller'); ?>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pelanggan</h2>
                <p>Pembeli yang pernah bertransaksi dengan toko Anda.</p>
            </div>
        </div>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>Nama Pelanggan</th><th>Email</th><th>Jumlah Pesanan</th><th>Total Belanja</th><th>Terakhir Belanja</th></tr></thead>
                <tbody>
                    <?php if ($customers === []): ?>
                        <tr><td colspan="5" style="text-align:center;color:#6b7280;">Belum ada pelanggan untuk toko ini.</td></tr>
                    <?php else: ?>
                        <?php foreach ($customers as $customer): ?>
                            <tr>
                                <td><?= e((string) $customer['nama']) ?></td>
                                <td><?= e((string) (($customer['email'] ?? '') !== '' ? $customer['email'] : '-')) ?></td>
                                <td><?= e((string) $customer['orders']) ?></td>
                                <td>Rp <?= e(number_format((int) $customer['total'], 0, ',', '.')) ?></td>
                                <td><?= e(substr((string) $customer['last'], 0, 10)) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
