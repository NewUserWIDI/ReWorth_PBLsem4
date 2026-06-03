<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$orderId = (int) ($_GET['id'] ?? 0);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = seller_update_order_status($sellerUserId, $orderId, (string) ($_POST['status_pesanan'] ?? ''));
    set_flash((string) ($result['type'] ?? 'success'), (string) ($result['message'] ?? 'Status diperbarui.'));
    redirect('app/modules/seller/order_detail.php?id=' . $orderId);
}

$detail = seller_fetch_order_detail($sellerUserId, $orderId);
if ($detail === null) {
    set_flash('warning', 'Pesanan tidak ditemukan.');
    redirect('app/modules/seller/orders.php');
}

$order = $detail['order'];
$address = $detail['address'] ?? [];
$payment = $detail['payment'] ?? [];
$shippingAddress = trim(implode(', ', array_filter([
    (string) ($address['jalan'] ?? ''),
    (string) ($address['kelurahan'] ?? ''),
    (string) ($address['kecamatan'] ?? ''),
    (string) ($address['kota'] ?? ''),
    (string) ($address['provinsi'] ?? ''),
    (string) ($address['kode_pos'] ?? ''),
])));

render_layout('Detail Pesanan', function () use ($order, $address, $payment, $shippingAddress): void {
    ?>
    <section class="form-card">
        <div class="panel-header">
            <div>
                <h2>Status Pesanan: <?php badge_status((string) $order['status_pesanan']); ?></h2>
                <p>ID <?= e((string) $order['kode_pesanan']) ?> | <?= e(substr((string) $order['tanggal'], 0, 10)) ?></p>
            </div>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/orders.php')) ?>">Kembali</a>
        </div>
    </section>

    <div class="content-grid">
        <section class="form-card">
            <h2 class="panel-title">Data Pembeli</h2>
            <p><strong><?= e((string) $order['pembeli']) ?></strong></p>
            <p class="panel-subtitle"><?= e((string) (($order['buyer_email'] ?? '') !== '' ? $order['buyer_email'] : 'Email pembeli tidak tersedia')) ?></p>
        </section>
        <section class="form-card">
            <h2 class="panel-title">Alamat Pengiriman</h2>
            <p><?= e($shippingAddress !== '' ? $shippingAddress : 'Alamat belum tersedia') ?></p>
            <p class="panel-subtitle"><?= e((string) (($address['patokan'] ?? '') !== '' ? $address['patokan'] : 'Tidak ada patokan tambahan.')) ?></p>
        </section>
    </div>

    <section class="panel">
        <div class="panel-header"><h2>Produk Dibeli</h2></div>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>Produk</th><th>Harga</th><th>Qty</th><th>Subtotal</th><th>Fee</th><th>Net Seller</th></tr></thead>
                <tbody>
                    <?php foreach (($order['items'] ?? []) as $product): ?>
                        <tr>
                            <td><?= e((string) $product['nama_produk']) ?></td>
                            <td>Rp <?= e(number_format((int) $product['harga_satuan'], 0, ',', '.')) ?></td>
                            <td><?= e((string) $product['jumlah']) ?></td>
                            <td>Rp <?= e(number_format((int) $product['subtotal'], 0, ',', '.')) ?></td>
                            <td>Rp <?= e(number_format((int) ($product['fee_platform_item'] ?? 0), 0, ',', '.')) ?></td>
                            <td>Rp <?= e(number_format((int) ($product['pendapatan_seller'] ?? $product['subtotal']), 0, ',', '.')) ?></td>
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
                <p class="panel-subtitle">Net seller Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?> | Status pembayaran <?= e(status_label((string) (($payment['status_pembayaran'] ?? '') !== '' ? $payment['status_pembayaran'] : 'pending'))) ?></p>
            </div>
            <form method="post" class="toolbar-right" style="display:flex;gap:10px;align-items:center;">
                <select class="select" name="status_pesanan" required>
                    <?php foreach (['diproses', 'dikemas', 'dikirim', 'selesai', 'dibatalkan'] as $status): ?>
                        <option value="<?= e($status) ?>" <?= (string) ($order['status_pesanan'] ?? '') === $status ? 'selected' : '' ?>><?= e(status_label($status)) ?></option>
                    <?php endforeach; ?>
                </select>
                <button class="btn btn-primary" type="submit">Simpan Status</button>
            </form>
        </div>
        <div class="stat-grid" style="grid-template-columns: repeat(3, minmax(0, 1fr)); margin-top: 16px;">
            <div><span class="panel-subtitle">Subtotal Bruto</span><strong>Rp <?= e(number_format((int) ($order['subtotal_bruto_seller'] ?? 0), 0, ',', '.')) ?></strong></div>
            <div><span class="panel-subtitle">Fee Platform</span><strong>Rp <?= e(number_format((int) ($order['fee_platform_seller'] ?? 0), 0, ',', '.')) ?></strong></div>
            <div><span class="panel-subtitle">Pendapatan Bersih</span><strong>Rp <?= e(number_format((int) ($order['total'] ?? 0), 0, ',', '.')) ?></strong></div>
        </div>
    </section>
    <?php
});
