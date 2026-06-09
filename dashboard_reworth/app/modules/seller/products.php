<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'delete') {
    $result = seller_delete_product($sellerUserId, (int) ($_POST['id_produk'] ?? 0));
    set_flash((string) ($result['type'] ?? 'success'), (string) ($result['message'] ?? 'Aksi selesai.'));
    redirect('app/modules/seller/products.php');
}

$filters = [
    'q' => $_GET['q'] ?? '',
    'kategori' => $_GET['kategori'] ?? '',
    'status' => $_GET['status'] ?? '',
    'sort' => $_GET['sort'] ?? 'terbaru',
];

$queryFilters = $filters;
if (($queryFilters['status'] ?? '') === 'stok_habis') {
    $queryFilters['status'] = '';
}

$allProducts = seller_fetch_products($sellerUserId);
$products = seller_fetch_products($sellerUserId, $queryFilters);
if (($filters['status'] ?? '') === 'stok_habis') {
    $products = array_values(array_filter($products, static fn (array $product): bool => (int) ($product['stok'] ?? 0) <= 0));
}

usort($products, static function (array $a, array $b) use ($filters): int {
    return match ((string) ($filters['sort'] ?? 'terbaru')) {
        'harga_asc' => ((int) ($a['harga'] ?? 0)) <=> ((int) ($b['harga'] ?? 0)),
        'harga_desc' => ((int) ($b['harga'] ?? 0)) <=> ((int) ($a['harga'] ?? 0)),
        'stok' => ((int) ($a['stok'] ?? 0)) <=> ((int) ($b['stok'] ?? 0)),
        default => ((int) ($b['id_produk'] ?? 0)) <=> ((int) ($a['id_produk'] ?? 0)),
    };
});

$summary = [
    'total' => count($allProducts),
    'aktif' => count(array_filter($allProducts, static fn (array $product): bool => (string) ($product['status_produk'] ?? '') === 'aktif')),
    'stok_habis' => count(array_filter($allProducts, static fn (array $product): bool => (int) ($product['stok'] ?? 0) <= 0)),
    'nonaktif' => count(array_filter($allProducts, static fn (array $product): bool => (string) ($product['status_produk'] ?? '') === 'nonaktif')),
];
$categories = seller_fetch_categories();

render_layout('Produk', function () use ($products, $categories, $filters, $summary): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Katalog Produk</h2>
                <p>Kelola produk yang dijual di mini market.</p>
            </div>
            <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php')) ?>">Tambah Produk</a>
        </div>
        <div class="seller-product-summary">
            <article><span>Total Produk</span><strong><?= e((string) $summary['total']) ?></strong></article>
            <article><span>Produk Aktif</span><strong><?= e((string) $summary['aktif']) ?></strong></article>
            <article><span>Stok Habis</span><strong><?= e((string) $summary['stok_habis']) ?></strong></article>
            <article><span>Produk Nonaktif</span><strong><?= e((string) $summary['nonaktif']) ?></strong></article>
        </div>
        <form class="toolbar" method="get" style="margin-bottom: 18px;">
            <div class="toolbar-left">
                <input class="input" style="width: 280px;" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari produk">
                <select class="select" style="width: 190px;" name="kategori">
                    <option value="">Semua kategori</option>
                    <?php foreach ($categories as $category): ?>
                        <?php $categoryName = (string) ($category['nama_kategori'] ?? ''); ?>
                        <option value="<?= e($categoryName) ?>" <?= $filters['kategori'] === $categoryName ? 'selected' : '' ?>><?= e($categoryName) ?></option>
                    <?php endforeach; ?>
                </select>
                <select class="select" style="width: 180px;" name="status">
                    <option value="">Semua status</option>
                    <option value="aktif" <?= $filters['status'] === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                    <option value="nonaktif" <?= $filters['status'] === 'nonaktif' ? 'selected' : '' ?>>Nonaktif</option>
                    <option value="stok_habis" <?= $filters['status'] === 'stok_habis' ? 'selected' : '' ?>>Stok Habis</option>
                </select>
                <select class="select" style="width: 180px;" name="sort">
                    <option value="terbaru" <?= $filters['sort'] === 'terbaru' ? 'selected' : '' ?>>Terbaru</option>
                    <option value="harga_asc" <?= $filters['sort'] === 'harga_asc' ? 'selected' : '' ?>>Harga Terendah</option>
                    <option value="harga_desc" <?= $filters['sort'] === 'harga_desc' ? 'selected' : '' ?>>Harga Tertinggi</option>
                    <option value="stok" <?= $filters['sort'] === 'stok' ? 'selected' : '' ?>>Stok Terendah</option>
                </select>
            </div>
            <button class="btn btn-secondary" type="submit">Filter</button>
        </form>
        <div class="product-grid">
            <?php if ($products === []): ?>
                <div class="empty-state">Belum ada produk yang cocok dengan filter.</div>
            <?php else: ?>
                <?php foreach ($products as $product): ?>
                    <article class="product-card seller-catalog-card">
                        <div class="product-card-media seller-product-media">
                            <?php if (($product['foto'] ?? '') !== ''): ?>
                                <img src="<?= e((string) $product['foto']) ?>" alt="<?= e((string) $product['nama_produk']) ?>">
                            <?php else: ?>
                                <?= e(substr((string) $product['nama_produk'], 0, 2)) ?>
                            <?php endif; ?>
                            <span class="seller-card-status"><?php badge_status((string) $product['status_produk']); ?></span>
                        </div>
                        <div class="product-card-body">
                            <div class="seller-product-head">
                                <span><?= e((string) $product['kategori']) ?></span>
                                <small>Stok <?= e((string) $product['stok']) ?></small>
                            </div>
                            <h3><?= e((string) $product['nama_produk']) ?></h3>
                            <p><?= e((string) ($product['deskripsi'] !== '' ? $product['deskripsi'] : 'Belum ada deskripsi produk.')) ?></p>
                            <div class="product-meta">
                                <span><small>Harga</small><strong>Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong></span>
                            </div>
                            <div class="card-actions">
                                <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/product_detail.php?id=' . urlencode((string) $product['id_produk']))) ?>">Detail</a>
                                <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode((string) $product['id_produk']))) ?>">Edit</a>
                                <form method="post" onsubmit="return confirm('Hapus produk ini?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id_produk" value="<?= e((string) $product['id_produk']) ?>">
                                    <button class="btn btn-danger" type="submit">Hapus</button>
                                </form>
                            </div>
                        </div>
                    </article>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
        <div class="seller-pagination" aria-label="Navigasi halaman katalog">
            <span>&lt;</span><strong>1</strong><span>2</span><span>3</span><span>&gt;</span>
        </div>
    </section>
    <?php
});
