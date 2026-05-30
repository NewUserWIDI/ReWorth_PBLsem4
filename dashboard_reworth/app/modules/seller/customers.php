<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Pelanggan', function (): void {
    $orders = mock_orders();
    $customers = [];
    foreach ($orders as $order) {
        $name = $order['pembeli'];
        $customers[$name]['orders'] = ($customers[$name]['orders'] ?? 0) + 1;
        $customers[$name]['total'] = ($customers[$name]['total'] ?? 0) + (int) $order['total'];
        $customers[$name]['last'] = $order['tanggal'];
    }
    ?>
    <div class="stat-grid">
        <?php stat_card('Total Pelanggan', count($customers), 'Dari pesanan toko', 'primary'); ?>
        <?php stat_card('Repeat Order', 0, 'Menunggu data transaksi'); ?>
        <?php stat_card('Pelanggan Baru', count($customers), 'Bulan ini', 'lime'); ?>
        <?php stat_card('Total Belanja', 'Rp ' . number_format(array_sum(array_column($orders, 'total')), 0, ',', '.'), 'Akumulasi pesanan'); ?>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pelanggan</h2>
                <p>Pembeli yang pernah bertransaksi dengan toko Anda.</p>
            </div>
            <input class="input" style="width: 280px;" type="search" placeholder="Cari pelanggan">
        </div>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>Nama Pelanggan</th><th>Jumlah Pesanan</th><th>Total Belanja</th><th>Terakhir Belanja</th><th>Aksi</th></tr></thead>
                <tbody>
                    <?php foreach ($customers as $name => $customer): ?>
                        <tr>
                            <td><?= e($name) ?></td>
                            <td><?= e((string) $customer['orders']) ?></td>
                            <td>Rp <?= e(number_format((int) $customer['total'], 0, ',', '.')) ?></td>
                            <td><?= e($customer['last']) ?></td>
                            <td><button class="btn btn-secondary" type="button">Detail</button></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
