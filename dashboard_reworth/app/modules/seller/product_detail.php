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
    $formatDate = static function (string $value): string {
        $timestamp = strtotime($value);
        return $timestamp !== false ? date('d M Y', $timestamp) : $value;
    };
    $formatDateTime = static function (string $value): string {
        $timestamp = strtotime($value);
        return $timestamp !== false ? date('d M Y H:i', $timestamp) : $value;
    };
    ?>
    <div class="page-heading">
        <div>
            <p>Produk &gt; <strong>Detail Produk</strong></p>
            <h2>Detail Produk</h2>
            <span>Informasi lengkap produk toko Anda.</span>
        </div>
        <div class="toolbar-right">
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/products.php')) ?>">Kembali</a>
            <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode((string) $product['id_produk']))) ?>">Edit Produk</a>
        </div>
    </div>

    <section class="panel seller-detail-overview">
        <div class="seller-product-detail-grid">
            <div class="seller-detail-gallery">
                <div class="product-detail-hero">
                    <span class="seller-detail-status"><?php badge_status((string) $product['status_produk']); ?></span>
                    <span class="seller-preview-icon" aria-hidden="true">↗</span>
                    <?php if (($product['foto'] ?? '') !== ''): ?>
                        <img src="<?= e((string) $product['foto']) ?>" alt="<?= e((string) $product['nama_produk']) ?>">
                    <?php else: ?>
                        <?= e(substr((string) $product['nama_produk'], 0, 2)) ?>
                    <?php endif; ?>
                </div>
                <?php if ($images !== []): ?>
                    <div class="product-thumb-strip">
                        <?php foreach ($images as $image): ?>
                            <article>
                                <img src="<?= e((string) ($image['public_url'] ?? '')) ?>" alt="gambar produk">
                            </article>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
            <div class="seller-detail-specs">
                <div><span>Kategori</span><strong><?= e((string) $product['kategori']) ?></strong></div>
                <div><span>Harga</span><strong class="money">Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong></div>
                <div><span>Stok</span><strong><?= e((string) $product['stok']) ?></strong></div>
                <div><span>SKU</span><strong><?= e((string) $product['sku']) ?></strong></div>
                <div><span>Tanggal Dibuat</span><strong><?= e($formatDate((string) $product['tanggal_dibuat'])) ?></strong></div>
                <div><span>Terakhir Diperbarui</span><strong><?= e($formatDateTime((string) $product['terakhir_diperbarui'])) ?></strong></div>
            </div>
        </div>
    </section>

    <section class="panel seller-detail-copy">
        <h2 class="panel-title">Detail Barang</h2>
        <p class="seller-detail-description"><?= e((string) ($product['deskripsi'] !== '' ? $product['deskripsi'] : 'Belum ada deskripsi produk.')) ?></p>
        <dl class="seller-detail-list">
            <div><dt>Status</dt><dd><?php badge_status((string) $product['status_produk']); ?></dd></div>
            <div><dt>Bahan</dt><dd><?= e((string) ($product['bahan'] !== '' ? $product['bahan'] : '-')) ?></dd></div>
            <div><dt>Manfaat</dt><dd><?= e((string) ($product['manfaat'] !== '' ? $product['manfaat'] : '-')) ?></dd></div>
            <div><dt>Cara Pakai</dt><dd><?= e((string) ($product['cara_pakai'] !== '' ? $product['cara_pakai'] : '-')) ?></dd></div>
            <div><dt>Eco Value</dt><dd><?= e((string) ($product['eco_value'] !== '' ? $product['eco_value'] : '-')) ?></dd></div>
            <div><dt>Berat</dt><dd><?= e((string) (($product['berat_gram'] ?? 0) > 0 ? $product['berat_gram'] . ' gram' : '-')) ?></dd></div>
            <div><dt>Tanggal Dibuat</dt><dd><?= e($formatDate((string) $product['tanggal_dibuat'])) ?></dd></div>
        </dl>
    </section>
    <?php
});
