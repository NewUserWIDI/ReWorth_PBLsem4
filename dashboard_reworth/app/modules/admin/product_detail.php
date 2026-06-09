<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$product = admin_product_by_id($id);
if ($product === null) {
    set_flash('warning', 'Produk tidak ditemukan.');
    redirect('app/modules/admin/mini_market.php');
}

render_layout('Detail Produk', function () use ($product): void {
    $status = $product['status_produk'] ?? 'draft';
    $statusLabel = match($status) {
        'aktif' => 'Aktif',
        'nonaktif' => 'Nonaktif',
        'disembunyikan' => 'Disembunyikan',
        'draft' => 'Draft',
        default => ucfirst($status)
    };
    $statusClass = match($status) {
        'aktif' => 'badge-success',
        'nonaktif' => 'badge-danger',
        'disembunyikan' => 'badge-neutral',
        default => 'badge-warning'
    };
    
    $kategori = $product['kategori'] ?? '-';
    ?>
    <style>
        .detail-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        .detail-card {
            background: #f9fafb;
            border-radius: 12px;
            padding: 20px;
        }
        .detail-card img {
            width: 100%;
            border-radius: 12px;
            max-height: 300px;
            object-fit: cover;
        }
        .detail-card p {
            margin: 10px 0;
            line-height: 1.5;
        }
        .detail-card strong {
            color: #374151;
            width: 120px;
            display: inline-block;
        }
        .gallery {
            display: flex;
            gap: 8px;
            margin-top: 12px;
            flex-wrap: wrap;
        }
        .gallery img {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
            cursor: pointer;
        }
        @media (max-width: 768px) {
            .detail-container {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Produk <?= e((string) $product['id_produk']) ?></h2>
                <p>Audit produk mini market lintas seller.</p>
            </div>
            <span class="status-badge <?= $statusClass ?>"><?= $statusLabel ?></span>
        </div>

        <div class="detail-container">
            <!-- Kolom Kiri: Foto -->
            <div class="detail-card">
                <?php 
                $gambar = $product['gambar'] ?? [];
                $firstImage = !empty($gambar) ? $gambar[0] : ($product['foto'] ?? 'assets/logo_reworth.jpeg');
                ?>
                <img src="<?= e(filter_var($firstImage, FILTER_VALIDATE_URL) ? $firstImage : url($firstImage)) ?>" 
                     alt="foto produk" 
                     id="mainImage">
                
                <?php if (count($gambar) > 1): ?>
                    <div class="gallery">
                        <?php foreach ($gambar as $img): ?>
                            <img src="<?= e(filter_var($img, FILTER_VALIDATE_URL) ? $img : url($img)) ?>" 
                                 onclick="document.getElementById('mainImage').src = this.src">
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>

            <!-- Kolom Kanan: Informasi Produk -->
            <div class="detail-card">
                <p><strong>Nama Produk:</strong> <?= e((string) $product['nama_produk']) ?></p>
                <p><strong>Seller:</strong> <?= e((string) $product['seller']) ?></p>
                <p><strong>Email Seller:</strong> <?= e((string) ($product['seller_email'] ?? '-')) ?></p>
                <p><strong>Kategori:</strong> <?= e($kategori) ?></p>
                <p><strong>Harga:</strong> Rp <?= e(number_format((int) $product['harga'], 0, ',', '.')) ?></p>
                <p><strong>Stok:</strong> <?= e((string) $product['stok']) ?></p>
                <p><strong>Berat:</strong> <?= e((string) ($product['berat_gram'] ?? 0)) ?> gram</p>
                <p><strong>Rating:</strong> <i class="fas fa-star" style="color: #f59e0b;"></i> <?= e((string) ($product['rating'] ?? 0)) ?></p>
                <p><strong>Tanggal Dibuat:</strong> <?= e((string) $product['tanggal_dibuat']) ?></p>
                <p><strong>Deskripsi:</strong></p>
                <div style="background: white; padding: 12px; border-radius: 8px; margin-top: 8px;">
                    <?= nl2br(e((string) ($product['deskripsi'] ?? '-'))) ?>
                </div>
            </div>
        </div>
    </section>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <?php
});