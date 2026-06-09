<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'kategori' => $_GET['kategori'] ?? '',
    'status_produk' => $_GET['status_produk'] ?? '',
];

// Gunakan fungsi dari admin_helpers yang sudah terhubung ke database
$rows = admin_products($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 10);

// Ambil opsi kategori dari database
$kategoriOptions = [];
$kategoriResult = supabase_fetch('kategori_produk', 'nama_kategori');
if (is_array($kategoriResult)) {
    foreach ($kategoriResult as $kat) {
        $kategoriOptions[] = $kat['nama_kategori'];
    }
}

render_layout('Mini Market', function () use ($filters, $pagination, $kategoriOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Mini Market</h2>
                <p>Monitoring produk seluruh seller.</p>
            </div>
        </div>
        <form method="get" style="display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 20px;">
            <div style="flex: 2; min-width: 200px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari produk / seller..." style="width: 100%;">
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="kategori" style="width: 100%;">
                    <option value="">Semua kategori</option>
                    <?php foreach ($kategoriOptions as $value): ?>
                        <option value="<?= e($value) ?>" <?= ($filters['kategori'] ?? '') === $value ? 'selected' : '' ?>><?= e($value) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <div style="flex: 1; min-width: 150px;">
                <select class="select" name="status_produk" style="width: 100%;">
                    <option value="">Semua status</option>
                    <option value="aktif" <?= ($filters['status_produk'] ?? '') === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                    <option value="draft" <?= ($filters['status_produk'] ?? '') === 'draft' ? 'selected' : '' ?>>Draft</option>
                    <option value="disembunyikan" <?= ($filters['status_produk'] ?? '') === 'disembunyikan' ? 'selected' : '' ?>>Disembunyikan</option>
                    <option value="nonaktif" <?= ($filters['status_produk'] ?? '') === 'nonaktif' ? 'selected' : '' ?>>Nonaktif</option>
                </select>
            </div>
            
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a href="<?= e(url('app/modules/admin/mini_market.php')) ?>" class="btn btn-secondary" style="margin-left: 8px;">Reset</a>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Produk</th>
                        <th>Foto</th>
                        <th>Nama Produk</th>
                        <th>Seller</th>
                        <th>Kategori</th>
                        <th>Harga</th>
                        <th>Stok</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr>
                            <td colspan="9" style="text-align:center;color:#6b7280; padding: 40px;">
                                📭 Belum ada produk.
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $item): ?>
                            <?php
                            $foto = $item['foto'] ?? 'assets/logo_reworth.jpeg';
                            ?>
                            <tr>
                                <td><strong><?= e((string) $item['id_produk']) ?></strong></td>
                                <td>
                                    <img src="<?= e(filter_var($foto, FILTER_VALIDATE_URL) ? $foto : url($foto)) ?>" 
                                         alt="foto produk" 
                                         style="width:50px; height:50px; object-fit:cover; border-radius:8px;">
                                </td>
                                <td><?= e((string) $item['nama_produk']) ?></td>
                                <td><?= e((string) $item['seller']) ?></td>
                                <td><?= e((string) $item['kategori']) ?></td>
                                <td>Rp <?= e(number_format((int) $item['harga'], 0, ',', '.')) ?></td>
                                <td><?= e((string) $item['stok']) ?></td>
                                <td><?php badge_status((string) $item['status_produk']); ?></td>
                                <td>
                                    <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/product_detail.php?id=' . urlencode((string) $item['id_produk']))) ?>" 
                                       style="padding: 6px 12px; font-size: 12px;">
                                        Detail
                                    </a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- PAGINATION -->
        <div class="card-actions" style="justify-content: flex-end; margin-top: 20px; gap: 12px;">
            <?php if ($pagination['page'] > 1): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] - 1]))) ?>">◀ Prev</a>
            <?php endif; ?>
            
            <span class="status-badge badge-neutral">
                Halaman <?= e((string) $pagination['page']) ?> dari <?= e((string) $pagination['total_pages']) ?>
            </span>
            
            <?php if ($pagination['page'] < $pagination['total_pages']): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] + 1]))) ?>">Next ▶</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});