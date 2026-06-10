<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
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
    $images = is_array($product['images'] ?? null) ? $product['images'] : [];
    $primaryImage = (string) ($product['foto'] ?? '');
    $status = strtolower((string) ($product['status_produk'] ?? 'aktif'));
    $isOutOfStock = (int) ($product['stok'] ?? 0) <= 0;
    $statusLabel = $isOutOfStock ? 'Stok Habis' : status_label($status);
    $formatDate = static function (string $value): string {
        $timestamp = strtotime($value);
        return $timestamp !== false ? date('d M Y', $timestamp) : $value;
    };
    $formatDateTime = static function (string $value): string {
        $timestamp = strtotime($value);
        return $timestamp !== false ? date('d M Y H:i', $timestamp) : $value;
    };
    ?>
    <section class="seller-product-detail-page">
        <div class="seller-product-detail-page-heading">
            <div>
                <p>Produk &gt; <strong>Detail Produk</strong></p>
                <h2><?= e((string) $product['nama_produk']) ?></h2>
            </div>
            <div class="seller-product-detail-header-actions">
                <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/products.php')) ?>">Kembali</a>
                <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode((string) $product['id_produk']))) ?>">Edit Produk</a>
            </div>
        </div>

        <section class="seller-product-detail-main-card">
            <div class="seller-product-detail-main-grid">
                <div class="seller-product-detail-gallery">
                    <div class="seller-product-detail-hero">
                        <span class="seller-product-detail-status"><?= e($statusLabel) ?></span>
                        <span class="seller-product-detail-preview" aria-hidden="true">↗</span>
                        <?php if ($primaryImage !== ''): ?>
                            <img src="<?= e($primaryImage) ?>" alt="<?= e((string) $product['nama_produk']) ?>">
                        <?php else: ?>
                            <div class="seller-product-detail-fallback"><?= e(substr((string) $product['nama_produk'], 0, 2)) ?></div>
                        <?php endif; ?>
                    </div>

                    <?php if ($images !== []): ?>
                        <div class="seller-product-detail-thumbs">
                            <?php foreach (array_slice($images, 0, 4) as $index => $image): ?>
                                <article class="<?= $index === 0 ? 'is-active' : '' ?>">
                                    <img src="<?= e((string) ($image['public_url'] ?? '')) ?>" alt="gambar produk">
                                </article>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>

                <div class="seller-product-detail-summary">
                    <div class="seller-product-detail-summary-item">
                        <div class="seller-product-detail-summary-icon">KT</div>
                        <div>
                            <span>Kategori</span>
                            <strong><?= e((string) $product['kategori']) ?></strong>
                        </div>
                    </div>
                    <div class="seller-product-detail-summary-item">
                        <div class="seller-product-detail-summary-icon">Rp</div>
                        <div>
                            <span>Harga</span>
                            <strong class="is-price">Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong>
                        </div>
                    </div>
                    <div class="seller-product-detail-summary-item">
                        <div class="seller-product-detail-summary-icon">#</div>
                        <div>
                            <span>Stok</span>
                            <strong><?= e((string) $product['stok']) ?></strong>
                        </div>
                    </div>
                    <div class="seller-product-detail-summary-item">
                        <div class="seller-product-detail-summary-icon">ID</div>
                        <div>
                            <span>SKU</span>
                            <strong><?= e((string) $product['sku']) ?></strong>
                        </div>
                    </div>
                    <div class="seller-product-detail-summary-item">
                        <div class="seller-product-detail-summary-icon">Dt</div>
                        <div>
                            <span>Tanggal Dibuat</span>
                            <strong><?= e($formatDate((string) $product['tanggal_dibuat'])) ?></strong>
                        </div>
                    </div>
                    <div class="seller-product-detail-summary-item">
                        <div class="seller-product-detail-summary-icon">Up</div>
                        <div>
                            <span>Terakhir Diperbarui</span>
                            <strong><?= e($formatDateTime((string) $product['terakhir_diperbarui'])) ?></strong>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="seller-product-detail-spec-card">
            <h2 class="panel-title">Detail Barang</h2>
            <dl class="seller-product-detail-spec-list">
                <div>
                    <dt>Status</dt>
                    <dd><span class="seller-product-detail-spec-badge"><?= e($statusLabel) ?></span></dd>
                </div>
                <div>
                    <dt>Bahan</dt>
                    <dd><?= e((string) ($product['bahan'] !== '' ? $product['bahan'] : '-')) ?></dd>
                </div>
                <div>
                    <dt>Manfaat</dt>
                    <dd><?= e((string) ($product['manfaat'] !== '' ? $product['manfaat'] : '-')) ?></dd>
                </div>
                <div>
                    <dt>Cara Pakai</dt>
                    <dd><?= e((string) ($product['cara_pakai'] !== '' ? $product['cara_pakai'] : '-')) ?></dd>
                </div>
                <div>
                    <dt>Eco Value</dt>
                    <dd><?= e((string) ($product['eco_value'] !== '' ? $product['eco_value'] : '-')) ?></dd>
                </div>
                <div>
                    <dt>Berat</dt>
                    <dd><?= e((string) (($product['berat_gram'] ?? 0) > 0 ? $product['berat_gram'] . ' gram' : '-')) ?></dd>
                </div>
                <div>
                    <dt>Tanggal Dibuat</dt>
                    <dd><?= e($formatDate((string) $product['tanggal_dibuat'])) ?></dd>
                </div>
            </dl>
        </section>
    </section>
    <?php
});
