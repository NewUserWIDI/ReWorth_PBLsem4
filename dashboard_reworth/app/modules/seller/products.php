<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Produk', function (): void {
    $products = mock_products();
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Produk</h2>
                <p>Kelola semua produk toko Anda.</p>
            </div>
            <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php')) ?>">Tambah Produk</a>
        </div>
        <div class="toolbar" style="margin-bottom: 18px;">
            <div class="toolbar-left">
                <input class="input" style="width: 280px;" type="search" placeholder="Cari produk">
                <select class="select" style="width: 190px;">
                    <option>Semua kategori</option>
                    <option>Kerajinan</option>
                    <option>Kompos</option>
                    <option>Eco Living</option>
                </select>
            </div>
        </div>
        <div class="product-grid">
            <?php foreach ($products as $product): ?>
                <article class="product-card">
                    <div class="product-card-media"><?= e(substr($product['nama'], 0, 2)) ?></div>
                    <div class="product-card-body">
                        <div class="panel-header" style="margin-bottom: 10px;">
                            <div>
                                <h3><?= e($product['nama']) ?></h3>
                                <p><?= e($product['seller']) ?></p>
                            </div>
                            <?php badge_status($product['status']); ?>
                        </div>
                        <div class="product-meta">
                            <span>Harga<br><strong>Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong></span>
                            <span>Stok<br><strong><?= e((string) $product['stok']) ?></strong></span>
                        </div>
                        <div class="card-actions">
                            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/product_detail.php?id=' . urlencode($product['id']))) ?>">Detail</a>
                            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode($product['id']))) ?>">Edit</a>
                            <a class="btn btn-danger" href="<?= e(url('app/modules/seller/products.php?delete=' . urlencode($product['id']))) ?>" data-confirm="Hapus produk ini?">Hapus</a>
                        </div>
                    </div>
                </article>
            <?php endforeach; ?>
        </div>
    </section>
    <?php
});

