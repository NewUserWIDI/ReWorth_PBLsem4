<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$productId = isset($_GET['id']) ? (int) $_GET['id'] : 0;
$isEdit = $productId > 0;
$categories = seller_fetch_categories();
$product = $isEdit ? seller_fetch_product_by_id($sellerUserId, $productId) : null;

if ($isEdit && $product === null) {
    set_flash('warning', 'Produk tidak ditemukan.');
    redirect('app/modules/seller/products.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = $isEdit
        ? seller_update_product($sellerUserId, $productId, $_POST, $_FILES)
        : seller_create_product($sellerUserId, $_POST, $_FILES);

    set_flash((string) ($result['type'] ?? 'success'), (string) ($result['message'] ?? 'Perubahan disimpan.'));
    redirect('app/modules/seller/products.php');
}

render_layout($isEdit ? 'Edit Produk' : 'Tambah Produk', function () use ($isEdit, $product, $categories): void {
    $product = $product ?? [
        'nama_produk' => '',
        'id_kategori' => 0,
        'bahan' => '',
        'status_produk' => 'aktif',
        'harga' => '',
        'stok' => '',
        'berat_gram' => '',
        'deskripsi' => '',
        'manfaat' => '',
        'cara_pakai' => '',
        'eco_value' => '',
        'images' => [],
    ];
    ?>
    <form method="post" class="form-stack" enctype="multipart/form-data">
        <section class="form-card">
            <div class="panel-header">
                <div>
                    <h2>Informasi Produk</h2>
                    <p>Pastikan nama, kategori, dan status produk jelas untuk pembeli.</p>
                </div>
            </div>
            <div class="form-grid">
                <label class="form-field"><span>Nama Produk</span><input name="nama" value="<?= e((string) $product['nama_produk']) ?>" required></label>
                <label class="form-field">
                    <span>Kategori</span>
                    <select name="kategori" required>
                        <option value="">Pilih kategori</option>
                        <?php foreach ($categories as $category): ?>
                            <?php $categoryId = (int) ($category['id_kategori'] ?? 0); ?>
                            <option value="<?= e((string) $categoryId) ?>" <?= (int) ($product['id_kategori'] ?? 0) === $categoryId ? 'selected' : '' ?>>
                                <?= e((string) ($category['nama_kategori'] ?? 'Kategori')) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label class="form-field"><span>Bahan / Material</span><input name="material" value="<?= e((string) $product['bahan']) ?>"></label>
                <label class="form-field">
                    <span>Status Produk</span>
                    <select name="status">
                        <?php foreach (['aktif', 'nonaktif', 'pending', 'disembunyikan'] as $status): ?>
                            <option value="<?= e($status) ?>" <?= (string) ($product['status_produk'] ?? '') === $status ? 'selected' : '' ?>><?= e(status_label($status)) ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
            </div>
        </section>

        <section class="form-card">
            <div class="panel-header">
                <div>
                    <h2>Media Produk</h2>
                    <p>Foto diunggah ke bucket Supabase Storage `product-images`.</p>
                </div>
            </div>
            <?php if (($product['images'] ?? []) !== []): ?>
                <div class="quick-cards" style="margin-bottom: 16px;">
                    <?php foreach ($product['images'] as $image): ?>
                        <article class="quick-card" style="padding:0;overflow:hidden;">
                            <img src="<?= e((string) ($image['public_url'] ?? '')) ?>" alt="gambar produk" style="width:100%;height:120px;object-fit:cover;border-radius:16px;">
                        </article>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
            <div class="upload-box">
                <div>
                    <strong><?= $isEdit ? 'Upload foto tambahan / pengganti' : 'Klik untuk upload foto produk' ?></strong>
                    <p class="panel-subtitle">PNG/JPG. Saat membuat produk, minimal 1 foto wajib.</p>
                    <input name="foto[]" type="file" accept="image/*" multiple>
                </div>
            </div>
        </section>

        <section class="form-card">
            <div class="panel-header"><h2>Harga & Stok</h2></div>
            <div class="form-grid">
                <label class="form-field"><span>Harga</span><input name="harga" type="number" min="1" value="<?= e((string) $product['harga']) ?>" required></label>
                <label class="form-field"><span>Stok</span><input name="stok" type="number" min="0" value="<?= e((string) $product['stok']) ?>" required></label>
                <label class="form-field"><span>Berat (gram)</span><input name="berat" type="number" min="0" value="<?= e((string) ($product['berat_gram'] ?: '')) ?>"></label>
                <label class="form-field"><span>Eco Value</span><input name="eco_value" value="<?= e((string) $product['eco_value']) ?>" placeholder="Contoh: reusable, low waste"></label>
            </div>
        </section>

        <section class="form-card">
            <div class="panel-header"><h2>Deskripsi Produk</h2></div>
            <label class="form-field">
                <span>Detail Barang</span>
                <textarea name="deskripsi" required placeholder="Tuliskan bahan, manfaat, cara pakai, kondisi produk, dan cerita daur ulangnya."><?= e((string) $product['deskripsi']) ?></textarea>
            </label>
            <div class="form-grid" style="margin-top:16px;">
                <label class="form-field">
                    <span>Manfaat</span>
                    <textarea name="manfaat" placeholder="Nilai tambah untuk pembeli"><?= e((string) $product['manfaat']) ?></textarea>
                </label>
                <label class="form-field">
                    <span>Cara Pakai</span>
                    <textarea name="cara_pakai" placeholder="Cara penggunaan produk"><?= e((string) $product['cara_pakai']) ?></textarea>
                </label>
            </div>
        </section>

        <div class="toolbar">
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/products.php')) ?>">Batal</a>
            <button class="btn btn-primary" type="submit"><?= $isEdit ? 'Simpan Perubahan' : 'Simpan Produk' ?></button>
        </div>
    </form>
    <?php
});
