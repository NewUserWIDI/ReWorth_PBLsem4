<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_active_seller();

render_layout('Detail Produk', function (): void {
    $id = $_GET['id'] ?? 'PRD-001';
    $products = mock_products();
    $product = array_values(array_filter($products, fn ($item) => $item['id'] === $id))[0] ?? $products[0];
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2><?= e($product['nama']) ?></h2>
                <p>Informasi lengkap produk toko.</p>
            </div>
            <div class="toolbar-right">
                <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/products.php')) ?>">Kembali</a>
                <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode($product['id']))) ?>">Edit Produk</a>
            </div>
        </div>
        <div class="content-grid">
            <div class="product-card-media" style="height: 330px; margin: 0;"><?= e(substr($product['nama'], 0, 2)) ?></div>
            <div class="form-stack">
                <section class="form-card">
                    <div class="stat-grid" style="grid-template-columns: repeat(3, minmax(0, 1fr));">
                        <div><span class="panel-subtitle">Jenis</span><strong>Kerajinan</strong></div>
                        <div><span class="panel-subtitle">Harga</span><strong>Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong></div>
                        <div><span class="panel-subtitle">Stok</span><strong><?= e((string) $product['stok']) ?></strong></div>
                    </div>
                </section>
                <section class="form-card">
                    <h2 class="panel-title">Detail Barang</h2>
                    <p class="panel-subtitle">Produk ini dibuat dari material daur ulang pilihan, cocok untuk pembeli yang ingin memakai barang fungsional sekaligus mendukung dampak lingkungan.</p>
                    <p><strong>Kategori:</strong> <?= e($product['seller']) ?></p>
                    <p><strong>Status:</strong> <?php badge_status($product['status']); ?></p>
                    <p><strong>Material:</strong> Plastik kemasan daur ulang</p>
                </section>
            </div>
        </div>
    </section>
    <?php
});
