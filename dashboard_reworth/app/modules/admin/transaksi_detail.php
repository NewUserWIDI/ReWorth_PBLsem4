<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$trx = admin_transaction_by_id($id);
if ($trx === null) {
    set_flash('warning', 'Transaksi tidak ditemukan.');
    redirect('app/modules/admin/transaksi.php');
}

render_layout('Detail Transaksi', function () use ($trx): void {
    $status = $trx['status'] ?? 'pending';
    ?>
    <style>
        .detail-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        .detail-card {
            background: #f9fafb;
            border-radius: 12px;
            padding: 20px;
        }
        .detail-card p {
            margin: 10px 0;
        }
        .detail-card strong {
            color: #374151;
            width: 140px;
            display: inline-block;
        }
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px;
        }
        .items-table th, .items-table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }
        .items-table th {
            background: #f3f4f6;
            font-weight: 600;
        }
        @media (max-width: 768px) {
            .detail-container {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Transaksi <?= e((string) $trx['id_transaksi']) ?></h2>
                <p>Audit transaksi marketplace.</p>
            </div>
            <?php badge_status($status); ?>
        </div>

        <div class="detail-container">
            <div class="detail-card">
                <p><strong>Kode Pesanan:</strong> <?= e((string) ($trx['kode_pesanan'] ?? '-')) ?></p>
                <p><strong>Pembeli:</strong> <?= e((string) ($trx['pembeli']['nama'] ?? $trx['pembeli'] ?? '-')) ?></p>
                <p><strong>Email Pembeli:</strong> <?= e((string) ($trx['pembeli']['email'] ?? '-')) ?></p>
                <p><strong>No. Telepon:</strong> <?= e((string) ($trx['pembeli']['no_telp'] ?? '-')) ?></p>
                <p><strong>Tanggal Pesanan:</strong> <?= e((string) $trx['tanggal_pesanan']) ?></p>
            </div>
            <div class="detail-card">
                <p><strong>Subtotal:</strong> Rp <?= e(number_format((int) ($trx['subtotal'] ?? 0), 0, ',', '.')) ?></p>
                <p><strong>Biaya Pengiriman:</strong> Rp <?= e(number_format((int) ($trx['biaya_pengiriman'] ?? 0), 0, ',', '.')) ?></p>
                <p><strong>Pajak:</strong> Rp <?= e(number_format((int) ($trx['pajak'] ?? 0), 0, ',', '.')) ?></p>
                <p><strong>Total Bayar:</strong> Rp <?= e(number_format((int) ($trx['total_bayar'] ?? $trx['total'] ?? 0), 0, ',', '.')) ?></p>
            </div>
        </div>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Alamat Pengiriman</h2>
            </div>
        </div>
        <div class="detail-card" style="background: #f9fafb; border-radius: 12px; padding: 20px;">
            <p><strong>Penerima:</strong> <?= e((string) ($trx['alamat']['penerima'] ?? '-')) ?></p>
            <p><strong>Alamat:</strong> <?= nl2br(e((string) ($trx['alamat']['jalan'] ?? ''))) ?></p>
            <p><strong>Kelurahan:</strong> <?= e((string) ($trx['alamat']['kelurahan'] ?? '-')) ?></p>
            <p><strong>Kecamatan:</strong> <?= e((string) ($trx['alamat']['kecamatan'] ?? '-')) ?></p>
            <p><strong>Kota:</strong> <?= e((string) ($trx['alamat']['kota'] ?? '-')) ?></p>
            <p><strong>Kode Pos:</strong> <?= e((string) ($trx['alamat']['kode_pos'] ?? '-')) ?></p>
        </div>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Item Pesanan</h2>
            </div>
        </div>
        <div class="table-wrap">
            <table class="items-table">
                <thead>
                    <tr>
                        <th>Produk</th>
                        <th>Seller</th>
                        <th>Jumlah</th>
                        <th>Harga Satuan</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($trx['items'])): ?>
                        <tr>
                            <td colspan="5" style="text-align:center; color:#6b7280;">Belum ada item pesanan</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($trx['items'] as $item): ?>
                            <tr>
                                <td><?= e((string) ($item['nama_produk'] ?? '-')) ?></td>
                                <td><?= e((string) ($item['seller'] ?? '-')) ?></td>
                                <td><?= e((string) ($item['jumlah'] ?? 0)) ?></td>
                                <td>Rp <?= e(number_format((int) ($item['harga_satuan'] ?? 0), 0, ',', '.')) ?></td>
                                <td>Rp <?= e(number_format((int) ($item['subtotal'] ?? 0), 0, ',', '.')) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Informasi Pembayaran</h2>
            </div>
        </div>
        <div class="detail-card" style="background: #f9fafb; border-radius: 12px; padding: 20px;">
            <p><strong>Status Pembayaran:</strong> <?php badge_status((string) ($trx['pembayaran']['status'] ?? 'Belum Upload')); ?></p>
            <p><strong>Metode Pembayaran:</strong> <?= e((string) ($trx['pembayaran']['metode'] ?? '-')) ?></p>
            <p><strong>Tanggal Bayar:</strong> <?= e((string) ($trx['pembayaran']['tanggal_bayar'] ?? '-')) ?></p>
            <?php if (!empty($trx['pembayaran']['bukti_url'])): ?>
                <p><strong>Bukti Pembayaran:</strong></p>
                <img src="<?= e($trx['pembayaran']['bukti_url']) ?>" alt="Bukti Pembayaran" style="max-width: 300px; border-radius: 8px; margin-top: 8px;">
            <?php endif; ?>
        </div>
    </section>
    <?php
});