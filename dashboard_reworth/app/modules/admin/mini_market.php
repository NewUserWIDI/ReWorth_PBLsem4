<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';
require_once __DIR__ . '/../../components/market_helpers.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'kategori' => $_GET['kategori'] ?? '',
    'seller' => $_GET['seller'] ?? '',
    'status_produk' => $_GET['status_produk'] ?? '',
];
$rows = admin_market_products($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 10);
$kategoriOptions = admin_market_unique_values($rows, 'kategori');
$sellerOptions = admin_market_unique_values($rows, 'seller');
$sourceLabel = admin_market_data_source_label();

render_layout('Mini Market', function () use ($filters, $pagination, $kategoriOptions, $sellerOptions, $sourceLabel): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Mini Market</h2>
                <p>Monitoring produk seluruh seller.</p>
            </div>
            <span class="status-badge badge-neutral">Sumber: <?= e($sourceLabel) ?></span>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari produk...">
                <select class="select" name="kategori">
                    <option value="">Semua kategori</option>
                    <?php foreach ($kategoriOptions as $value): ?>
                        <option value="<?= e($value) ?>" <?= $filters['kategori'] === $value ? 'selected' : '' ?>><?= e($value) ?></option>
                    <?php endforeach; ?>
                </select>
                <select class="select" name="seller">
                    <option value="">Semua seller</option>
                    <?php foreach ($sellerOptions as $value): ?>
                        <option value="<?= e($value) ?>" <?= $filters['seller'] === $value ? 'selected' : '' ?>><?= e($value) ?></option>
                    <?php endforeach; ?>
                </select>
                <select class="select" name="status_produk">
                    <option value="">Semua status</option>
                    <option value="aktif" <?= $filters['status_produk'] === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                    <option value="pending" <?= $filters['status_produk'] === 'pending' ? 'selected' : '' ?>>Pending</option>
                    <option value="disembunyikan" <?= $filters['status_produk'] === 'disembunyikan' ? 'selected' : '' ?>>Disembunyikan</option>
                    <option value="nonaktif" <?= $filters['status_produk'] === 'nonaktif' ? 'selected' : '' ?>>Nonaktif</option>
                </select>
            </div>
            <button class="btn btn-primary" type="submit">Filter</button>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Produk</th><th>Foto</th><th>Nama Produk</th><th>Seller</th><th>Kategori</th><th>Harga</th><th>Stok</th><th>Status</th><th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="9" style="text-align:center;color:#6b7280;">Belum ada produk.</td></tr>
                    <?php else: foreach ($pagination['items'] as $item): ?>
                        <tr>
                            <td><?= e((string) $item['id_produk']) ?></td>
                            <td>
                                <?php if (filter_var((string) $item['foto'], FILTER_VALIDATE_URL)): ?>
                                    <img class="report-thumb" src="<?= e((string) $item['foto']) ?>" alt="foto produk" style="width:54px;height:54px;">
                                <?php else: ?>
                                    <img class="report-thumb" src="<?= e(url((string) ($item['foto'] !== '' ? $item['foto'] : 'assets/logo_reworth.jpeg'))) ?>" alt="foto produk" style="width:54px;height:54px;">
                                <?php endif; ?>
                            </td>
                            <td><?= e((string) $item['nama_produk']) ?></td>
                            <td><?= e((string) $item['seller']) ?></td>
                            <td><?= e((string) $item['kategori']) ?></td>
                            <td>Rp <?= e(number_format((int) $item['harga'], 0, ',', '.')) ?></td>
                            <td><?= e((string) $item['stok']) ?></td>
                            <td><?php badge_status((string) $item['status_produk']); ?></td>
                            <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/product_detail.php?id=' . urlencode((string) $item['id_produk']))) ?>">Detail</a></td>
                        </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
        <div class="card-actions" style="justify-content:flex-end;">
            <?php if ($pagination['page'] > 1): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] - 1]))) ?>">Prev</a>
            <?php endif; ?>
            <span class="status-badge badge-neutral">Halaman <?= e((string) $pagination['page']) ?> / <?= e((string) $pagination['total_pages']) ?></span>
            <?php if ($pagination['page'] < $pagination['total_pages']): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] + 1]))) ?>">Next</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});
