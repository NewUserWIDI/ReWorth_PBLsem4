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

// Proses form
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    $reason = trim((string) ($_POST['alasan_penolakan'] ?? ''));
    
    // Validasi alasan penolakan minimal 10 karakter
    if ($action === 'reject' && mb_strlen(preg_replace('/\s+/', ' ', $reason)) < 10) {
        set_flash('danger', 'Alasan penolakan minimal 10 karakter.');
        redirect('app/modules/admin/seller_detail.php?id=' . urlencode($id));
    }

    // ========== 1. PROSES VERIFIKASI (SETUJUI) ==========
    if ($action === 'verify') {
        if (str_starts_with($id, 'PEN-')) {
            $idPengajuan = (int) str_replace('PEN-', '', $id);
            $pengajuan = supabase_fetch_one('pengajuan_seller', '*', ['id_pengajuan' => 'eq.' . $idPengajuan]);
            
            if (!$pengajuan) {
                set_flash('danger', 'Data pengajuan tidak ditemukan.');
                redirect('app/modules/admin/sellers.php');
            }
            
            if ($pengajuan['status_pengajuan'] !== 'Pending') {
                set_flash('warning', 'Pengajuan ini sudah diproses sebelumnya.');
                redirect('app/modules/admin/sellers.php');
            }
            
            $existingSeller = supabase_fetch_one('seller', '*', ['id_masyarakat' => 'eq.' . $pengajuan['id_masyarakat']]);
            
            if ($existingSeller) {
                supabase_update('pengajuan_seller',
                    [
                        'status_pengajuan' => 'Ditolak', 
                        'alasan_penolakan' => 'User sudah terdaftar sebagai seller',
                        'tanggal_diproses' => date('Y-m-d H:i:s')
                    ],
                    ['id_pengajuan' => 'eq.' . $idPengajuan]
                );
                set_flash('danger', 'Gagal! User sudah terdaftar sebagai seller.');
                redirect('app/modules/admin/sellers.php');
            }
            
            $sellerData = [
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
                'tanggal_disetujui' => date('Y-m-d H:i:s')
            ];
            
            $insertResult = supabase_insert('seller', $sellerData);
            
            if (!isset($insertResult['id_seller'])) {
                set_flash('danger', 'Gagal insert ke seller: ' . supabase_last_error());
                redirect('app/modules/admin/sellers.php');
            }
            
            supabase_update('pengajuan_seller', 
                ['status_pengajuan' => 'Disetujui', 'tanggal_diproses' => date('Y-m-d H:i:s')],
                ['id_pengajuan' => 'eq.' . $idPengajuan]
            );
            
            supabase_update('profiles',
                ['role' => 'seller', 'status_pengajuan_seller' => 'aktif'],
                ['id' => 'eq.' . $pengajuan['id_masyarakat']]
            );
            
            set_flash('success', 'Seller berhasil diverifikasi!');
            
        } else {
            supabase_update('seller',
                ['status_verifikasi' => 'Disetujui', 'aktif' => true],
                ['id_seller' => 'eq.' . $id]
            );
            
            $sellerData = supabase_fetch_one('seller', 'id_masyarakat', ['id_seller' => 'eq.' . $id]);
            if ($sellerData) {
                supabase_update('profiles',
                    ['role' => 'seller', 'status_pengajuan_seller' => 'aktif'],
                    ['id' => 'eq.' . $sellerData['id_masyarakat']]
                );
            }
            set_flash('success', 'Seller berhasil diverifikasi!');
        }
        
    // ========== 2. PROSES TOLAK (HANYA UNTUK PENGAJUAN) ==========
    } elseif ($action === 'reject') {
        if (str_starts_with($id, 'PEN-')) {
            $idPengajuan = (int) str_replace('PEN-', '', $id);
            supabase_update('pengajuan_seller',
                ['status_pengajuan' => 'Ditolak', 'alasan_penolakan' => $reason, 'tanggal_diproses' => date('Y-m-d H:i:s')],
                ['id_pengajuan' => 'eq.' . $idPengajuan]
            );
            $pengajuan = supabase_fetch_one('pengajuan_seller', 'id_masyarakat', ['id_pengajuan' => 'eq.' . $idPengajuan]);
            if ($pengajuan) {
                supabase_update('profiles',
                    ['status_pengajuan_seller' => 'ditolak'],
                    ['id' => 'eq.' . $pengajuan['id_masyarakat']]
                );
            }
            set_flash('success', 'Pengajuan seller ditolak.');
        } else {
            set_flash('warning', 'Tolak hanya untuk pengajuan yang masih menunggu.');
        }
        
    // ========== 3. PROSES NONAKTIFKAN ==========
    } elseif ($action === 'disable') {
        if (!str_starts_with($id, 'PEN-')) {
            $sellerData = supabase_fetch_one('seller', 'id_masyarakat', ['id_seller' => 'eq.' . $id]);
            
            if ($sellerData) {
                supabase_update('seller',
                    ['aktif' => false, 'status_verifikasi' => 'Nonaktif'],
                    ['id_seller' => 'eq.' . $id]
                );
                
                supabase_update('profiles',
                    ['role' => 'user', 'status_pengajuan_seller' => 'nonaktif'],
                    ['id' => 'eq.' . $sellerData['id_masyarakat']]
                );
                set_flash('warning', 'Seller dinonaktifkan.');
            } else {
                set_flash('danger', 'Seller tidak ditemukan.');
            }
        } else {
            set_flash('warning', 'Pengajuan yang belum diverifikasi tidak bisa dinonaktifkan.');
        }
        
    // ========== 4. PROSES AKTIFKAN ==========
    } elseif ($action === 'activate') {
        if (!str_starts_with($id, 'PEN-')) {
            $sellerData = supabase_fetch_one('seller', 'id_masyarakat', ['id_seller' => 'eq.' . $id]);
            
            if ($sellerData) {
                supabase_update('seller',
                    ['aktif' => true, 'status_verifikasi' => 'Disetujui'],
                    ['id_seller' => 'eq.' . $id]
                );
                
                supabase_update('profiles',
                    ['role' => 'seller', 'status_pengajuan_seller' => 'aktif'],
                    ['id' => 'eq.' . $sellerData['id_masyarakat']]
                );
                set_flash('success', 'Seller berhasil diaktifkan kembali!');
            } else {
                set_flash('danger', 'Seller tidak ditemukan.');
            }
        }
    }
    
    redirect('app/modules/admin/sellers.php');
}

// Ambil status dari database
$displayStatus = 'menunggu';

if (str_starts_with($id, 'PEN-')) {
    $idPengajuan = (int) str_replace('PEN-', '', $id);
    $pengajuanStatus = supabase_fetch_one('pengajuan_seller', 'status_pengajuan', ['id_pengajuan' => 'eq.' . $idPengajuan]);
    if ($pengajuanStatus) {
        $statusDb = $pengajuanStatus['status_pengajuan'];
        if ($statusDb === 'Pending') {
            $displayStatus = 'menunggu';
        } elseif ($statusDb === 'Disetujui') {
            $displayStatus = 'terverifikasi';
        } elseif ($statusDb === 'Ditolak') {
            $displayStatus = 'ditolak';
        }
    }
} else {
    $sellerStatus = supabase_fetch_one('seller', 'status_verifikasi, aktif', ['id_seller' => 'eq.' . $id]);
    if ($sellerStatus) {
        if ($sellerStatus['status_verifikasi'] === 'Disetujui' && $sellerStatus['aktif'] === true) {
            $displayStatus = 'terverifikasi';
        } elseif ($sellerStatus['status_verifikasi'] === 'Nonaktif' || $sellerStatus['aktif'] === false) {
            $displayStatus = 'nonaktif';
        } elseif ($sellerStatus['status_verifikasi'] === 'Ditolak') {
            $displayStatus = 'ditolak';
        }
    }
}

$statusBadgeClass = match($displayStatus) {
    'terverifikasi' => 'badge-success',
    'menunggu' => 'badge-warning',
    'ditolak' => 'badge-danger',
    'nonaktif' => 'badge-neutral',
    default => 'badge-neutral',
};

$statusLabel = match($displayStatus) {
    'terverifikasi' => 'Terverifikasi',
    'menunggu' => 'Menunggu Verifikasi',
    'ditolak' => 'Ditolak',
    'nonaktif' => 'Nonaktif',
    default => 'Menunggu',
};

render_layout('Detail Seller', function () use ($seller, $statusBadgeClass, $statusLabel, $displayStatus, $id): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Seller <?= e((string) $seller['id_seller']) ?></h2>
                <p>Profil toko dan riwayat verifikasi.</p>
            </div>
            <span class="status-badge <?= $statusBadgeClass ?>"><?= $statusLabel ?></span>
        </div>

        <div class="form-grid">
            <article class="form-card">
                <p><strong>Nama Toko:</strong> <?= e((string) ($seller['nama_toko'] ?? '-')) ?></p>
                <p><strong>Pemilik:</strong> <?= e((string) ($seller['pemilik'] ?? '-')) ?></p>
                <p><strong>Email:</strong> <?= e((string) ($seller['email'] ?? '-')) ?></p>
                <p><strong>No. Telepon:</strong> <?= e((string) ($seller['no_telp'] ?? '-')) ?></p>
                <p><strong>Jumlah Produk:</strong> <?= e((string) ($seller['jumlah_produk'] ?? 0)) ?></p>
            </article>
            <article class="form-card">
                <p><strong>Status Verifikasi:</strong> <?= $statusLabel ?></p>
                <p><strong>Status Toko:</strong> <?= e(status_label((string) ($seller['status_toko'] ?? 'pending'))) ?></p>
                <p><strong>Tanggal Bergabung:</strong> <?= e((string) ($seller['tanggal_bergabung'] ?? '-')) ?></p>
                <?php if (!empty($seller['deskripsi_toko'])): ?>
                <p><strong>Deskripsi Toko:</strong> <?= e((string) $seller['deskripsi_toko']) ?></p>
                <?php endif; ?>
                <?php if (!empty($seller['alamat_toko'])): ?>
                <p><strong>Alamat Toko:</strong> <?= e((string) $seller['alamat_toko']) ?></p>
                <?php endif; ?>
                <?php if (!empty($seller['alasan_penolakan'])): ?>
                <p><strong>Alasan Penolakan:</strong> <span style="color:#dc2626;"><?= e((string) $seller['alasan_penolakan']) ?></span></p>
                <?php endif; ?>
            </article>
        </div>

        <!-- TAMPILAN TOMBOL BERDASARKAN STATUS (TANPA TOMBOL TOLAK YANG TIDAK PERLU) -->
        
        <?php if ($displayStatus === 'menunggu'): ?>
        <!-- 1. PENGAJUAN YANG MASIH MENUNGGU -->
        <div class="card-actions" style="flex-wrap: wrap; gap: 16px;">
            <form method="post" onsubmit="return confirm('Verifikasi seller ini?')">
                <input type="hidden" name="action" value="verify">
                <button class="btn btn-primary" type="submit">✓ Setujui</button>
            </form>
            
            <form method="post" class="reject-form" onsubmit="return confirm('Tolak pengajuan seller ini?')">
                <input type="hidden" name="action" value="reject">
                <textarea name="alasan_penolakan" required minlength="10" placeholder="Alasan penolakan (minimal 10 karakter)..." style="width: 300px; padding: 8px; border-radius: 8px; border: 1px solid #ddd;"></textarea>
                <button class="btn btn-danger" type="submit">✗ Tolak Pengajuan</button>
            </form>
        </div>
        
        <?php elseif ($displayStatus === 'nonaktif'): ?>
        <!-- 2. SELLER YANG NONAKTIF - HANYA TOMBOL AKTIFKAN -->
        <div class="card-actions">
            <form method="post" onsubmit="return confirm('Aktifkan seller ini? Seller akan bisa login dan berjualan kembali.')">
                <input type="hidden" name="action" value="activate">
                <button class="btn btn-success" type="submit">✓ Aktifkan Seller</button>
            </form>
        </div>
        
        <?php elseif ($displayStatus === 'terverifikasi'): ?>
        <!-- 3. SELLER YANG AKTIF - HANYA TOMBOL NONAKTIFKAN -->
        <div class="card-actions">
            <form method="post" onsubmit="return confirm('Nonaktifkan seller ini? Seller tidak bisa login dan berjualan.')">
                <input type="hidden" name="action" value="disable">
                <button class="btn btn-secondary" type="submit">⛔ Nonaktifkan Seller</button>
            </form>
        </div>
        
        <?php elseif ($displayStatus === 'ditolak'): ?>
        <!-- 4. PENGAJUAN YANG DITOLAK - TIDAK ADA TOMBOL -->
        <div class="card-actions">
            <div class="alert alert-danger">
                <strong>⚠️ Pengajuan ini telah ditolak.</strong><br>
                Alasan: <?= e((string) ($seller['alasan_penolakan'] ?? 'Tidak ada alasan')) ?>
            </div>
        </div>
        <?php endif; ?>
    </section>

    <style>
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin: 20px 0;
        }
        .form-card {
            background: #f9fafb;
            border-radius: 12px;
            padding: 20px;
        }
        .form-card p {
            margin: 8px 0;
            line-height: 1.5;
        }
        .card-actions {
            display: flex;
            gap: 16px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
        }
        .reject-form {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            flex-wrap: wrap;
        }
        textarea {
            min-width: 260px;
            font-family: inherit;
        }
        .btn-success {
            background-color: #10b981;
            color: white;
        }
        .btn-success:hover {
            background-color: #059669;
        }
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            width: 100%;
        }
        .alert-danger {
            background-color: #fee2e2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .reject-form {
                flex-direction: column;
            }
            textarea {
                width: 100%;
            }
        }
    </style>
    <?php
});