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
];

$products = seller_fetch_products($sellerUserId, $filters);
$categories = seller_fetch_categories();

render_layout('Produk', function () use ($products, $categories, $filters): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Produk</h2>
                <p>Kelola semua produk toko Anda.</p>
            </div>
            <a class="btn btn-primary" href="<?= e(url('app/modules/seller/product_form.php')) ?>">Tambah Produk</a>
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
                    <?php foreach (['aktif', 'nonaktif', 'pending', 'disembunyikan'] as $status): ?>
                        <option value="<?= e($status) ?>" <?= $filters['status'] === $status ? 'selected' : '' ?>><?= e(status_label($status)) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <button class="btn btn-secondary" type="submit">Filter</button>
        </form>
        <div class="product-grid">
            <?php if ($products === []): ?>
                <div class="empty-state">Belum ada produk yang cocok dengan filter.</div>
            <?php else: ?>
                <?php foreach ($products as $product): ?>
                    <article class="product-card">
                        <div class="product-card-media" style="padding:0;overflow:hidden;">
                            <?php if (($product['foto'] ?? '') !== ''): ?>
                                <img src="<?= e((string) $product['foto']) ?>" alt="<?= e((string) $product['nama_produk']) ?>" style="width:100%;height:100%;object-fit:cover;">
                            <?php else: ?>
                                <?= e(substr((string) $product['nama_produk'], 0, 2)) ?>
                            <?php endif; ?>
                        </div>
                        <div class="product-card-body">
                            <div class="panel-header" style="margin-bottom: 10px;">
                                <div>
                                    <h3><?= e((string) $product['nama_produk']) ?></h3>
                                    <p><?= e((string) $product['kategori']) ?></p>
                                </div>
                                <?php badge_status((string) $product['status_produk']); ?>
                            </div>
                            <div class="product-meta">
                                <span>Harga<br><strong>Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></strong></span>
                                <span>Stok<br><strong><?= e((string) $product['stok']) ?></strong></span>
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
    </section>
    <?php
});
