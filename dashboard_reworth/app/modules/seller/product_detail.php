<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$productId = (int) ($_GET['id'] ?? 0);
$product = seller_fetch_product_by_id($sellerUserId, $productId);

if ($product === null) {
    set_flash('warning', 'Produk tidak ditemukan.');
    redirect('app/modules/seller/products.php');
}

render_layout('Detail Produk', function () use ($product): void {
    $images = $product['images'] ?? [];
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2><?= e((string) $product['nama_produk']) ?></h2>
                <p>Informasi lengkap produk toko.</p>
            </div>
            <div class="toolbar-right">
                <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/products.php')) ?>">Kembali</a>
                <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode((string) $product['id_produk']))) ?>">Edit Produk</a>
            </div>
        </div>
        <div class="content-grid">
            <div class="form-stack">
                <div class="product-card-media" style="height: 330px; margin: 0; padding:0; overflow:hidden;">
                    <?php if (($product['foto'] ?? '') !== ''): ?>
                        <img src="<?= e((string) $product['foto']) ?>" alt="<?= e((string) $product['nama_produk']) ?>" style="width:100%;height:100%;object-fit:cover;">
                    <?php else: ?>
                        <?= e(substr((string) $product['nama_produk'], 0, 2)) ?>
                    <?php endif; ?>
                </div>
                <?php if ($images !== []): ?>
                    <div class="quick-cards">
                        <?php foreach ($images as $image): ?>
                            <article class="quick-card" style="padding:0;overflow:hidden;">
                                <img src="<?= e((string) ($image['public_url'] ?? '')) ?>" alt="gambar produk" style="width:100%;height:100px;object-fit:cover;border-radius:16px;">
                            </article>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
            <div class="form-stack">
                <section class="form-card">
                    <div class="stat-grid" style="grid-template-columns: repeat(3, minmax(0, 1fr));">
                        <div><span class="panel-subtitle">Kategori</span><strong><?= e((string) $product['kategori']) ?></strong></div>
                        <div><span class="panel-subtitle">Harga</span><strong>Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong></div>
                        <div><span class="panel-subtitle">Stok</span><strong><?= e((string) $product['stok']) ?></strong></div>
                    </div>
                </section>
                <section class="form-card">
                    <h2 class="panel-title">Detail Barang</h2>
                    <p class="panel-subtitle"><?= e((string) $product['deskripsi']) ?></p>
                    <p><strong>Status:</strong> <?php badge_status((string) $product['status_produk']); ?></p>
                    <p><strong>Bahan:</strong> <?= e((string) ($product['bahan'] !== '' ? $product['bahan'] : '-')) ?></p>
                    <p><strong>Manfaat:</strong> <?= e((string) ($product['manfaat'] !== '' ? $product['manfaat'] : '-')) ?></p>
                    <p><strong>Cara Pakai:</strong> <?= e((string) ($product['cara_pakai'] !== '' ? $product['cara_pakai'] : '-')) ?></p>
                    <p><strong>Eco Value:</strong> <?= e((string) ($product['eco_value'] !== '' ? $product['eco_value'] : '-')) ?></p>
                    <p><strong>Berat:</strong> <?= e((string) (($product['berat_gram'] ?? 0) > 0 ? $product['berat_gram'] . ' gram' : '-')) ?></p>
                    <p><strong>Tanggal Dibuat:</strong> <?= e((string) $product['tanggal_dibuat']) ?></p>
                </section>
            </div>
        </div>
    </section>
    <?php
});
