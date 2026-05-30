<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Pesanan', function (): void {
    $orders = mock_orders();
    $tabs = ['Semua', 'Baru', 'Diproses', 'Dikemas', 'Dikirim', 'Selesai', 'Dibatalkan'];
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pesanan</h2>
                <p>Kelola semua pesanan toko Anda.</p>
            </div>
        </div>
        <div class="toolbar" style="margin-bottom: 18px;">
            <div class="tabs">
                <?php foreach ($tabs as $index => $tab): ?>
                    <button class="tab <?= $index === 0 ? 'active' : '' ?>" type="button"><?= e($tab) ?></button>
                <?php endforeach; ?>
            </div>
            <input class="input" style="width: 280px;" type="search" placeholder="Cari ID pesanan atau pembeli">
        </div>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>ID Pesanan</th><th>Pembeli</th><th>Tanggal</th><th>Status</th><th>Total</th><th>Aksi</th></tr></thead>
                <tbody>
                    <?php foreach ($orders as $order): ?>
                        <tr>
                            <td><?= e($order['id']) ?></td>
                            <td><?= e($order['pembeli']) ?></td>
                            <td><?= e($order['tanggal']) ?></td>
                            <td><?php badge_status($order['status']); ?></td>
                            <td>Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?></td>
                            <td><a class="btn btn-secondary" href="<?= e(url('app/modules/seller/order_detail.php?id=' . urlencode($order['id']))) ?>">Lihat Detail</a></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
