<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';
require_once __DIR__ . '/../../components/market_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$product = admin_market_product_by_id($id);
if ($product === null) {
    set_flash('warning', 'Produk tidak ditemukan.');
    redirect('app/modules/admin/mini_market.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    set_flash('success', 'Status produk #' . $id . ' diperbarui (' . $action . ') (mock).');
    redirect('app/modules/admin/mini_market.php');
}

render_layout('Detail Produk', function () use ($product): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Produk <?= e((string) $product['id_produk']) ?></h2>
                <p>Audit produk mini market lintas seller.</p>
            </div>
            <?php badge_status((string) $product['status_produk']); ?>
        </div>
        <div class="split-grid">
            <article class="form-card">
                <?php $photo = (string) ($product['foto'] ?? ''); ?>
                <img
                    src="<?= e(filter_var($photo, FILTER_VALIDATE_URL) ? $photo : url($photo !== '' ? $photo : 'assets/logo_reworth.jpeg')) ?>"
                    alt="foto produk"
                    style="width:100%;border-radius:14px;max-height:280px;object-fit:cover;"
                >
            </article>
            <article class="form-card">
                <p><strong>Nama Produk:</strong> <?= e((string) $product['nama_produk']) ?></p>
                <p><strong>Seller:</strong> <?= e((string) $product['seller']) ?></p>
                <p><strong>Kategori:</strong> <?= e((string) $product['kategori']) ?></p>
                <p><strong>Harga:</strong> Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></p>
                <p><strong>Stok:</strong> <?= e((string) $product['stok']) ?></p>
                <p><strong>Tanggal Dibuat:</strong> <?= e((string) $product['tanggal_dibuat']) ?></p>
                <p><strong>Deskripsi:</strong> <?= e((string) ($product['deskripsi'] ?? '-')) ?></p>
                <div class="card-actions">
                    <form method="post"><input type="hidden" name="action" value="hide"><button class="btn btn-danger" type="submit">Sembunyikan</button></form>
                    <form method="post"><input type="hidden" name="action" value="activate"><button class="btn btn-primary" type="submit">Aktifkan</button></form>
                    <form method="post"><input type="hidden" name="action" value="disable"><button class="btn btn-secondary" type="submit">Nonaktifkan</button></form>
                </div>
            </article>
        </div>
    </section>
    <?php
});
