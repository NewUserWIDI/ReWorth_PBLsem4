<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$source = (string) ($_GET['source'] ?? 'data');
$source = $source === 'verification' ? 'verification' : 'data';

$seller = admin_seller_by_id($id);
if ($seller === null) {
    set_flash('warning', 'Data seller tidak ditemukan.');
    redirect('app/modules/admin/sellers.php');
}

$isPengajuan = (bool) ($seller['is_pengajuan'] ?? false);
$isVerificationView = $source === 'verification';
$statusPengajuan = strtolower(trim((string) ($seller['status_pengajuan'] ?? '')));
$canProcessVerification = $isVerificationView && $isPengajuan && $statusPengajuan === 'pending';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$canProcessVerification) {
        set_flash('warning', 'Halaman detail seller pada menu Data Seller hanya dapat dibaca.');
        redirect('app/modules/admin/seller_detail.php?id=' . urlencode($id) . '&source=' . urlencode($source));
    }

    $action = (string) ($_POST['action'] ?? '');
    $reason = trim((string) ($_POST['alasan_penolakan'] ?? ''));
    $idPengajuan = (int) ($seller['id_pengajuan'] ?? 0);
    $pengajuan = supabase_fetch_one('pengajuan_seller', '*', ['id_pengajuan' => 'eq.' . $idPengajuan]);

    if (!$pengajuan || !is_array($pengajuan)) {
        set_flash('danger', 'Data pengajuan seller tidak ditemukan.');
        redirect('app/modules/admin/sellers.php?status=menunggu');
    }

    if (($pengajuan['status_pengajuan'] ?? '') !== 'Pending') {
        set_flash('warning', 'Pengajuan seller ini sudah diproses sebelumnya.');
        redirect('app/modules/admin/sellers.php?status=menunggu');
    }

    if ($action === 'verify') {
        $existingSeller = supabase_fetch_one('seller', '*', ['id_masyarakat' => 'eq.' . $pengajuan['id_masyarakat']]);
        if ($existingSeller) {
            supabase_update('pengajuan_seller', [
                'status_pengajuan' => 'Ditolak',
                'alasan_penolakan' => 'User sudah terdaftar sebagai seller',
                'tanggal_diproses' => date('Y-m-d H:i:s'),
            ], ['id_pengajuan' => 'eq.' . $idPengajuan]);

            set_flash('danger', 'Gagal memverifikasi karena user sudah terdaftar sebagai seller.');
            redirect('app/modules/admin/sellers.php?status=menunggu');
        }

        $insertResult = supabase_insert('seller', [
            'id_masyarakat' => $pengajuan['id_masyarakat'],
            'id_pengajuan' => $pengajuan['id_pengajuan'],
            'nama_toko' => $pengajuan['nama_toko_usulan'],
            'deskripsi_toko' => $pengajuan['deskripsi_toko'],
            'alamat_toko' => $pengajuan['alamat_toko'],
            'foto_toko' => $pengajuan['foto_toko'],
            'username_dashboard' => $pengajuan['username_usulan'],
            'password_hash_dashboard' => $pengajuan['password_hash_usulan'],
            'status_verifikasi' => 'Disetujui',
            'aktif' => true,
            'tanggal_disetujui' => date('Y-m-d H:i:s'),
        ]);

        if (!isset($insertResult['id_seller'])) {
            set_flash('danger', 'Gagal menyimpan data seller: ' . supabase_last_error());
            redirect('app/modules/admin/sellers.php?status=menunggu');
        }

        supabase_update('pengajuan_seller', [
            'status_pengajuan' => 'Disetujui',
            'tanggal_diproses' => date('Y-m-d H:i:s'),
        ], ['id_pengajuan' => 'eq.' . $idPengajuan]);

        supabase_update('profiles', [
            'role' => 'seller',
            'status_pengajuan_seller' => 'aktif',
        ], ['id' => 'eq.' . $pengajuan['id_masyarakat']]);

        set_flash('success', 'Pengajuan seller berhasil disetujui.');
        redirect('app/modules/admin/sellers.php?status=menunggu');
    }

    if ($action === 'reject') {
        if (mb_strlen(preg_replace('/\s+/', ' ', $reason)) < 10) {
            set_flash('danger', 'Alasan penolakan minimal 10 karakter.');
            redirect('app/modules/admin/seller_detail.php?id=' . urlencode($id) . '&source=verification');
        }

        supabase_update('pengajuan_seller', [
            'status_pengajuan' => 'Ditolak',
            'alasan_penolakan' => $reason,
            'tanggal_diproses' => date('Y-m-d H:i:s'),
        ], ['id_pengajuan' => 'eq.' . $idPengajuan]);

        supabase_update('profiles', [
            'status_pengajuan_seller' => 'ditolak',
        ], ['id' => 'eq.' . $pengajuan['id_masyarakat']]);

        set_flash('success', 'Pengajuan seller berhasil ditolak.');
        redirect('app/modules/admin/sellers.php?status=menunggu');
    }

    set_flash('warning', 'Aksi yang diminta tidak dikenali.');
    redirect('app/modules/admin/seller_detail.php?id=' . urlencode($id) . '&source=' . urlencode($source));
}

$statusKey = (string) ($seller['status_verifikasi'] ?? 'menunggu');
$statusLabel = match ($statusKey) {
    'terverifikasi' => 'Terverifikasi',
    'nonaktif' => 'Nonaktif',
    'ditolak' => 'Ditolak',
    default => 'Menunggu Verifikasi',
};
$statusBadgeClass = match ($statusKey) {
    'terverifikasi' => 'badge-success',
    'nonaktif' => 'badge-neutral',
    'ditolak' => 'badge-danger',
    default => 'badge-warning',
};
$backUrl = $isVerificationView ? 'app/modules/admin/sellers.php?status=menunggu' : 'app/modules/admin/sellers.php';
$photoUrl = trim((string) ($seller['foto_toko'] ?? ''));

render_layout($isVerificationView ? 'Detail Pengajuan Seller' : 'Detail Seller', function () use ($seller, $statusLabel, $statusBadgeClass, $backUrl, $photoUrl, $isVerificationView, $canProcessVerification): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2><?= e($isVerificationView ? 'Detail Pengajuan Seller' : 'Detail Seller') ?></h2>
                <p><?= e($isVerificationView ? 'Tinjau data pengajuan seller sebelum diproses.' : 'Halaman ini hanya menampilkan data seller yang sudah tersimpan pada database.') ?></p>
            </div>
            <span class="status-badge <?= e($statusBadgeClass) ?>"><?= e($statusLabel) ?></span>
        </div>

        <div class="user-detail-hero">
            <div class="user-detail-hero-media">
                <?php if ($photoUrl !== ''): ?>
                    <img src="<?= e($photoUrl) ?>" alt="Foto toko <?= e((string) ($seller['nama_toko'] ?? 'Seller')) ?>" style="width:100%;height:100%;object-fit:cover;">
                <?php else: ?>
                    <span><?= e(strtoupper(substr((string) ($seller['nama_toko'] ?? 'S'), 0, 1))) ?></span>
                <?php endif; ?>
            </div>
            <div class="user-detail-hero-copy">
                <h3><?= e((string) ($seller['nama_toko'] ?? '-')) ?></h3>
                <p><?= e((string) ($seller['email'] ?? '-')) ?></p>
            </div>
        </div>

        <?php if (!$isVerificationView): ?>
            <div class="alert-inline alert-inline-info">
                Detail seller pada menu ini bersifat read only.
            </div>
        <?php endif; ?>

        <div class="detail-grid" style="margin-top: 20px;">
            <article class="detail-card">
                <h3>Data Pemilik</h3>
                <div class="detail-list">
                    <div><strong><?= e($seller['is_pengajuan'] ? 'ID Pengajuan' : 'ID Seller') ?>:</strong> <?= e((string) ($seller['id_seller'] ?? '-')) ?></div>
                    <div><strong>ID User:</strong> <?= e((string) ($seller['id_masyarakat'] ?? '-')) ?></div>
                    <div><strong>Nama Pemilik:</strong> <?= e((string) ($seller['pemilik'] ?? '-')) ?></div>
                    <div><strong>Email:</strong> <?= e((string) ($seller['email'] ?? '-')) ?></div>
                    <div><strong>No. Telepon:</strong> <?= e((string) ($seller['no_telp'] ?? '-')) ?></div>
                </div>
            </article>

            <article class="detail-card">
                <h3>Data Toko</h3>
                <div class="detail-list">
                    <div><strong>Nama Toko:</strong> <?= e((string) ($seller['nama_toko'] ?? '-')) ?></div>
                    <div><strong>Username Dashboard:</strong> <?= e((string) (($seller['username_dashboard'] ?? $seller['username_usulan'] ?? '') ?: '-')) ?></div>
                    <div><strong>Kategori Jualan:</strong> <?= e((string) (($seller['kategori_jualan'] ?? '') ?: '-')) ?></div>
                    <div><strong>Jenis Produk:</strong> <?= e((string) (($seller['jenis_produk_jualan'] ?? '') ?: '-')) ?></div>
                    <div><strong>Alamat Toko:</strong> <?= e((string) (($seller['alamat_toko'] ?? '') ?: '-')) ?></div>
                    <div><strong>Deskripsi Toko:</strong> <?= e((string) (($seller['deskripsi_toko'] ?? '') ?: '-')) ?></div>
                </div>
            </article>

            <article class="detail-card">
                <h3>Status & Waktu</h3>
                <div class="detail-list">
                    <div><strong>Status Verifikasi:</strong> <?= e($statusLabel) ?></div>
                    <div><strong>Status Toko:</strong> <?= e(status_label((string) ($seller['status_toko'] ?? '-'))) ?></div>
                    <?php if (!empty($seller['tanggal_pengajuan']) && $seller['tanggal_pengajuan'] !== '-'): ?>
                        <div><strong>Tanggal Pengajuan:</strong> <?= e((string) $seller['tanggal_pengajuan']) ?></div>
                    <?php endif; ?>
                    <?php if (!empty($seller['tanggal_disetujui']) && $seller['tanggal_disetujui'] !== '-'): ?>
                        <div><strong>Tanggal Disetujui:</strong> <?= e((string) $seller['tanggal_disetujui']) ?></div>
                    <?php endif; ?>
                    <?php if (!empty($seller['tanggal_diproses']) && $seller['tanggal_diproses'] !== '-'): ?>
                        <div><strong>Tanggal Diproses:</strong> <?= e((string) $seller['tanggal_diproses']) ?></div>
                    <?php endif; ?>
                    <?php if (!empty($seller['tanggal_dibuat']) && $seller['tanggal_dibuat'] !== '-'): ?>
                        <div><strong>Dibuat Pada:</strong> <?= e((string) $seller['tanggal_dibuat']) ?></div>
                    <?php endif; ?>
                    <div><strong>Terakhir Tercatat:</strong> <?= e((string) (($seller['tanggal_bergabung'] ?? '') ?: '-')) ?></div>
                    <?php if (!empty($seller['alasan_penolakan'])): ?>
                        <div><strong>Alasan Penolakan:</strong> <?= e((string) $seller['alasan_penolakan']) ?></div>
                    <?php endif; ?>
                </div>
            </article>
        </div>

        <div class="card-actions" style="margin-top: 24px; display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
    <a class="btn btn-secondary" href="<?= e(url($backUrl)) ?>" style="min-width: 100px; text-align: center;">← Kembali</a>

    <?php if ($canProcessVerification): ?>
        <div style="display: flex; gap: 12px; margin-left: auto; flex-wrap: wrap;">
            <form method="post" onsubmit="return confirm('Setujui pengajuan seller ini?')">
                <input type="hidden" name="action" value="verify">
                <button class="btn btn-primary" type="submit" style="min-width: 150px;">Terima Pengajuan</button>
            </form>

            <form method="post" class="reject-form" onsubmit="return confirm('Tolak pengajuan seller ini?')" style="display: flex; gap: 12px; align-items: flex-start;">
                <input type="hidden" name="action" value="reject">
                <textarea name="alasan_penolakan" required minlength="10" placeholder="Alasan penolakan (min. 10 karakter)" style="width: 260px; min-height: 44px; padding: 8px 12px; border-radius: 12px; border: 1px solid #d1d5db; resize: vertical;"></textarea>
                <button class="btn btn-danger" type="submit" style="min-width: 120px;">Tolak</button>
            </form>
        </div>
    <?php endif; ?>
</div>
    </section>

    <style>
        .user-detail-hero {
            display: grid;
            grid-template-columns: 96px minmax(0, 1fr);
            gap: 18px;
            align-items: center;
            padding: 18px;
            border-radius: 18px;
            background: linear-gradient(135deg, #f3faf2 0%, #ffffff 100%);
            border: 1px solid #e5e7eb;
        }

        .user-detail-hero-media {
            width: 96px;
            height: 96px;
            border-radius: 20px;
            overflow: hidden;
            display: grid;
            place-items: center;
            background: linear-gradient(135deg, #1f5e23, #4faf3d);
            color: #ffffff;
            font-size: 30px;
            font-weight: 700;
            box-shadow: 0 12px 28px rgba(31, 94, 35, 0.16);
        }

        .user-detail-hero-media img {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .user-detail-hero-copy h3 {
            margin: 0;
            color: #111827;
            font-size: 22px;
            line-height: 1.2;
        }

        .user-detail-hero-copy p {
            margin: 6px 0 0;
            color: #6b7280;
            font-size: 14px;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 18px;
        }

        .detail-card {
            background: #f8fafc;
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            padding: 18px;
        }

        .detail-card h3 {
            margin: 0 0 12px;
            font-size: 15px;
            color: #111827;
        }

        .detail-list {
            display: grid;
            gap: 10px;
            color: #374151;
            line-height: 1.55;
        }

        .alert-inline {
            margin-top: 18px;
            padding: 12px 14px;
            border-radius: 12px;
            font-size: 13px;
            line-height: 1.55;
        }

        .alert-inline-info {
            background: rgba(14, 116, 144, 0.08);
            border: 1px solid rgba(14, 116, 144, 0.18);
            color: #0f766e;
        }

        .reject-form {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .verification-action-block {
            flex: 1;
            min-width: 0;
        }

        .verification-action-row {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            flex-wrap: wrap;
            justify-content: flex-end;
            width: 100%;
        }

        .verification-action-row form {
            margin: 0;
        }

        .verification-action-row > form:first-child {
            display: flex;
            align-items: stretch;
            flex: 0 0 auto;
        }

        .verification-action-row > form:first-child .btn {
            min-width: 170px;
        }

        .reject-form {
            flex: 1 1 360px;
            min-width: 320px;
            justify-content: flex-end;
        }

        .reject-form textarea {
            min-width: 300px;
            width: 100%;
            min-height: 88px;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 12px;
            font: inherit;
            resize: vertical;
        }

        .reject-form .btn {
            min-width: 170px;
        }

        @media (max-width: 768px) {
            .user-detail-hero {
                grid-template-columns: 1fr;
                justify-items: start;
            }

            .reject-form {
                width: 100%;
                flex-direction: column;
            }

            .verification-action-row {
                flex-direction: column;
                width: 100%;
                justify-content: flex-start;
                align-items: stretch;
            }

            .reject-form textarea {
                width: 100%;
                min-width: 100%;
            }
        }
    </style>
    <?php
});
