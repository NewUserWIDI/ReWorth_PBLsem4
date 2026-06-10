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
    <section class="seller-catalog-page">
        <header class="seller-catalog-header">
            <div>
                <h2>Katalog Produk</h2>
                <p>Kelola produk yang dijual di mini market</p>
            </div>
            <a class="btn btn-primary seller-catalog-add-btn" href="<?= e(url('app/modules/seller/product_form.php')) ?>">+ Tambah Produk</a>
        </header>

        <div class="seller-catalog-summary-grid">
            <article class="seller-catalog-summary-card">
                <span>Total Produk</span>
                <strong><?= e((string) $summary['total']) ?></strong>
            </article>
            <article class="seller-catalog-summary-card">
                <span>Produk Aktif</span>
                <strong><?= e((string) $summary['aktif']) ?></strong>
            </article>
            <article class="seller-catalog-summary-card">
                <span>Stok Habis</span>
                <strong><?= e((string) $summary['stok_habis']) ?></strong>
            </article>
            <article class="seller-catalog-summary-card">
                <span>Produk Nonaktif</span>
                <strong><?= e((string) $summary['nonaktif']) ?></strong>
            </article>
        </div>

        <form class="seller-catalog-toolbar" method="get">
            <input class="input seller-catalog-search" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari nama produk, kategori, atau deskripsi">
            <select class="select seller-catalog-select" name="kategori">
                <option value="">Semua kategori</option>
                <?php foreach ($categories as $category): ?>
                    <?php $categoryName = (string) ($category['nama_kategori'] ?? ''); ?>
                    <option value="<?= e($categoryName) ?>" <?= $filters['kategori'] === $categoryName ? 'selected' : '' ?>><?= e($categoryName) ?></option>
                <?php endforeach; ?>
            </select>
            <select class="select seller-catalog-select" name="status">
                <option value="">Semua status</option>
                <option value="aktif" <?= $filters['status'] === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                <option value="nonaktif" <?= $filters['status'] === 'nonaktif' ? 'selected' : '' ?>>Nonaktif</option>
                <option value="stok_habis" <?= $filters['status'] === 'stok_habis' ? 'selected' : '' ?>>Stok Habis</option>
            </select>
            <select class="select seller-catalog-select" name="sort">
                <option value="terbaru" <?= $filters['sort'] === 'terbaru' ? 'selected' : '' ?>>Terbaru</option>
                <option value="harga_desc" <?= $filters['sort'] === 'harga_desc' ? 'selected' : '' ?>>Harga Tertinggi</option>
                <option value="harga_asc" <?= $filters['sort'] === 'harga_asc' ? 'selected' : '' ?>>Harga Terendah</option>
                <option value="stok" <?= $filters['sort'] === 'stok' ? 'selected' : '' ?>>Stok</option>
            </select>
            <button class="btn btn-secondary seller-catalog-filter-btn" type="submit">Filter</button>
        </form>

        <?php if ($products === []): ?>
            <div class="empty-state seller-catalog-empty">Belum ada produk yang cocok dengan filter.</div>
        <?php else: ?>
            <div class="seller-catalog-grid">
                <?php foreach ($products as $product): ?>
                    <?php
                        $status = strtolower((string) ($product['status_produk'] ?? ''));
                        $isOutOfStock = (int) ($product['stok'] ?? 0) <= 0;
                        $statusLabel = $isOutOfStock ? 'Stok Habis' : status_label($status);
                        $statusClass = $isOutOfStock ? 'seller-catalog-badge-stock' : ($status === 'nonaktif' ? 'seller-catalog-badge-inactive' : 'seller-catalog-badge-active');
                    ?>
                    <article class="seller-catalog-product-card">
                        <div class="seller-catalog-media">
                            <?php if (($product['foto'] ?? '') !== ''): ?>
                                <img src="<?= e((string) $product['foto']) ?>" alt="<?= e((string) $product['nama_produk']) ?>">
                            <?php else: ?>
                                <div class="seller-catalog-fallback"><?= e(substr((string) $product['nama_produk'], 0, 2)) ?></div>
                            <?php endif; ?>
                            <span class="seller-catalog-badge <?= e($statusClass) ?>"><?= e($statusLabel) ?></span>
                            <details class="seller-catalog-menu">
                                <summary aria-label="Aksi produk">⋯</summary>
                                <div class="seller-catalog-menu-sheet">
                                    <a href="<?= e(url('app/modules/seller/product_detail.php?id=' . urlencode((string) $product['id_produk']))) ?>">Detail</a>
                                    <a href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode((string) $product['id_produk']))) ?>">Edit</a>
                                    <form method="post" onsubmit="return confirm('Hapus produk ini?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id_produk" value="<?= e((string) $product['id_produk']) ?>">
                                        <button type="submit">Hapus</button>
                                    </form>
                                </div>
                            </details>
                        </div>
                        <div class="seller-catalog-card-body">
                            <h3><?= e((string) $product['nama_produk']) ?></h3>
                            <p class="seller-catalog-category"><?= e((string) $product['kategori']) ?></p>
                            <strong class="seller-catalog-price">Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong>
                            <span class="seller-catalog-stock">Stok: <?= e((string) $product['stok']) ?></span>
                            <div class="seller-catalog-actions">
                                <a class="btn btn-secondary seller-catalog-btn seller-catalog-btn-detail" href="<?= e(url('app/modules/seller/product_detail.php?id=' . urlencode((string) $product['id_produk']))) ?>">Detail</a>
                                <a class="btn btn-secondary seller-catalog-btn seller-catalog-btn-edit" href="<?= e(url('app/modules/seller/product_form.php?id=' . urlencode((string) $product['id_produk']))) ?>">Edit</a>
                                <form method="post" onsubmit="return confirm('Hapus produk ini?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id_produk" value="<?= e((string) $product['id_produk']) ?>">
                                    <button class="btn btn-danger seller-catalog-btn seller-catalog-btn-delete" type="submit">Hapus</button>
                                </form>
                            </div>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>

        <div class="seller-catalog-pagination" aria-label="Navigasi halaman katalog">
            <span>&lt;</span>
            <strong>1</strong>
            <span>2</span>
            <span>3</span>
            <span>&gt;</span>
        </div>
    </section>
    <?php
});
