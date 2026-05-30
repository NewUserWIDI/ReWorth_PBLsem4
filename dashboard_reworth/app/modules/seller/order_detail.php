<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    set_flash('success', 'Status pesanan berhasil diperbarui (mock).');
    redirect('app/modules/seller/orders.php');
}

render_layout('Detail Pesanan', function (): void {
    $id = $_GET['id'] ?? 'ORD-001';
    $orders = mock_orders();
    $order = array_values(array_filter($orders, fn ($item) => $item['id'] === $id))[0] ?? $orders[0];
    $products = array_slice(mock_products(), 0, 2);
    ?>
    <section class="form-card">
        <div class="panel-header">
            <div>
                <h2>Status Pesanan: <?php badge_status($order['status']); ?></h2>
                <p>ID <?= e($order['id']) ?> · <?= e($order['tanggal']) ?></p>
            </div>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/orders.php')) ?>">Kembali</a>
        </div>
    </section>

    <div class="content-grid">
        <section class="form-card">
            <h2 class="panel-title">Data Pembeli</h2>
            <p><strong><?= e($order['pembeli']) ?></strong></p>
            <p class="panel-subtitle">pembeli@reworth.app · 08xxxxxxxxxx</p>
        </section>
        <section class="form-card">
            <h2 class="panel-title">Alamat Pengiriman</h2>
            <p>Jl. Soekarno Hatta No.45, Lowokwaru, Kota Malang</p>
            <p class="panel-subtitle">Patokan: depan minimarket, pagar hijau.</p>
        </section>
    </div>

    <section class="panel">
        <div class="panel-header"><h2>Produk Dibeli</h2></div>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>Produk</th><th>Harga</th><th>Qty</th><th>Subtotal</th></tr></thead>
                <tbody>
                    <?php foreach ($products as $product): ?>
                        <tr>
                            <td><?= e($product['nama']) ?></td>
                            <td>Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></td>
                            <td>1</td>
                            <td>Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>

    <section class="form-card">
        <div class="panel-header">
            <div>
                <h2>Ringkasan Pembayaran</h2>
                <p class="panel-subtitle">Total pembayaran Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?> · Metode dummy marketplace</p>
            </div>
            <form method="post" class="toolbar-right">
                <button class="btn btn-primary" type="submit">Update Status Berikutnya</button>
            </form>
        </div>
    </section>
    <?php
});
