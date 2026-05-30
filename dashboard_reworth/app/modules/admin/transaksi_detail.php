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
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Transaksi <?= e((string) $trx['id_transaksi']) ?></h2>
                <p>Audit transaksi marketplace.</p>
            </div>
            <?php badge_status((string) $trx['status']); ?>
        </div>
        <div class="form-grid">
            <article class="form-card">
                <p><strong>Pembeli:</strong> <?= e((string) $trx['pembeli']) ?></p>
                <p><strong>Seller:</strong> <?= e((string) $trx['seller']) ?></p>
                <p><strong>Tanggal:</strong> <?= e((string) $trx['tanggal']) ?></p>
            </article>
            <article class="form-card">
                <p><strong>Total:</strong> Rp <?= e(number_format((int) $trx['total'], 0, ',', '.')) ?></p>
                <p><strong>Pembayaran:</strong> Dummy Payment Gateway (mock)</p>
                <p><strong>Produk Dibeli:</strong> Data item pesanan akan ditarik dari detail_pesanan (mock).</p>
            </article>
        </div>
    </section>
    <?php
});

