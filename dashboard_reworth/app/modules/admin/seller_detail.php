<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$seller = admin_seller_by_id($id);
if ($seller === null) {
    set_flash('warning', 'Seller tidak ditemukan.');
    redirect('app/modules/admin/sellers.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    $reason = trim((string) ($_POST['alasan_penolakan'] ?? ''));
    if ($action === 'reject' && mb_strlen(preg_replace('/\s+/', ' ', $reason)) < 10) {
        set_flash('danger', 'Alasan penolakan minimal 10 karakter.');
        redirect('app/modules/admin/seller_detail.php?id=' . urlencode($id));
    }

    if ($action === 'verify') {
        set_flash('success', 'Seller #' . $id . ' berhasil diverifikasi (mock).');
    } elseif ($action === 'reject') {
        set_flash('success', 'Seller #' . $id . ' ditolak. Alasan: ' . $reason . ' (mock).');
    } elseif ($action === 'disable') {
        set_flash('warning', 'Seller #' . $id . ' dinonaktifkan (mock).');
    }
    redirect('app/modules/admin/sellers.php');
}

render_layout('Detail Seller', function () use ($seller): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Seller <?= e((string) $seller['id_seller']) ?></h2>
                <p>Profil toko dan riwayat verifikasi.</p>
            </div>
            <?php badge_status((string) $seller['status_verifikasi']); ?>
        </div>

        <div class="form-grid">
            <article class="form-card">
                <p><strong>Nama Toko:</strong> <?= e((string) $seller['nama_toko']) ?></p>
                <p><strong>Pemilik:</strong> <?= e((string) $seller['pemilik']) ?></p>
                <p><strong>Email:</strong> <?= e((string) $seller['email']) ?></p>
                <p><strong>Jumlah Produk:</strong> <?= e((string) $seller['jumlah_produk']) ?></p>
            </article>
            <article class="form-card">
                <p><strong>Status Verifikasi:</strong> <?= e(status_label((string) $seller['status_verifikasi'])) ?></p>
                <p><strong>Status Toko:</strong> <?= e(status_label((string) $seller['status_toko'])) ?></p>
                <p><strong>Tanggal Bergabung:</strong> <?= e((string) $seller['tanggal_bergabung']) ?></p>
                <p><strong>Riwayat Verifikasi:</strong> Log verifikasi seller akan tampil di sini (mock).</p>
            </article>
        </div>

        <div class="card-actions">
            <form method="post" data-confirm="Verifikasi seller ini?">
                <input type="hidden" name="action" value="verify">
                <button class="btn btn-primary" type="submit">Verifikasi</button>
            </form>
            <form method="post" class="reject-form" data-confirm="Tolak seller ini?">
                <input type="hidden" name="action" value="reject">
                <textarea name="alasan_penolakan" required minlength="10" placeholder="Alasan penolakan seller (minimal 10 karakter)..."></textarea>
                <button class="btn btn-danger" type="submit">Tolak</button>
            </form>
            <form method="post" data-confirm="Nonaktifkan seller ini?">
                <input type="hidden" name="action" value="disable">
                <button class="btn btn-secondary" type="submit">Nonaktifkan</button>
            </form>
        </div>
    </section>
    <?php
});

