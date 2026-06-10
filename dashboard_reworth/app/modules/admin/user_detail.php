<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$user = admin_user_by_id($id);
if ($user === null) {
    set_flash('warning', 'User tidak ditemukan.');
    redirect('app/modules/admin/users.php');
}

render_layout('Detail User', function () use ($user): void {
    $photoUrl = trim((string) ($user['foto_profil'] ?? ''));
    $initial = strtoupper(substr((string) ($user['nama'] ?? 'U'), 0, 1));
    ?>
    <style>
        .user-detail-hero {
            display: grid;
            grid-template-columns: 120px minmax(0, 1fr);
            gap: 20px;
            align-items: center;
            padding: 20px;
            border-radius: 18px;
            background: linear-gradient(135deg, #f3faf2 0%, #ffffff 100%);
            border: 1px solid #e5e7eb;
        }
        .user-detail-avatar {
            width: 120px;
            height: 120px;
            border-radius: 24px;
            overflow: hidden;
            display: grid;
            place-items: center;
            background: linear-gradient(135deg, #1f5e23, #4faf3d);
            color: #ffffff;
            font-size: 40px;
            font-weight: 700;
            box-shadow: 0 12px 30px rgba(31, 94, 35, 0.18);
        }
        .user-detail-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .user-detail-hero h3 {
            margin: 0;
            color: #111827;
            font-size: 24px;
            line-height: 1.2;
        }
        .user-detail-hero p {
            margin: 6px 0 0;
            color: #6b7280;
            font-size: 14px;
        }
        .user-detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }
        .user-detail-card p {
            margin: 10px 0;
            color: #374151;
            line-height: 1.5;
        }
        @media (max-width: 768px) {
            .user-detail-hero,
            .user-detail-grid {
                grid-template-columns: 1fr;
            }
            .user-detail-hero {
                justify-items: start;
            }
        }
    </style>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail User (<?= e((string) $user['nama']) ?>)</h2>
                <p>Informasi profil pengguna yang tersimpan dalam sistem.</p>
            </div>
            <span class="status-badge badge-neutral"><?= e(ucfirst((string) $user['role'])) ?></span>
        </div>

        <div class="user-detail-hero">
            <div class="user-detail-avatar">
                <?php if ($photoUrl !== ''): ?>
                    <img src="<?= e($photoUrl) ?>" alt="Foto profil user">
                <?php else: ?>
                    <span><?= e($initial) ?></span>
                <?php endif; ?>
            </div>
            <div>
                <h3><?= e((string) $user['nama']) ?></h3>
                <p><?= e((string) $user['email']) ?></p>
            </div>
        </div>

        <div class="user-detail-grid" style="margin-top: 18px;">
            <article class="form-card user-detail-card">
                <p><strong>ID User:</strong> <?= e((string) $user['id_user']) ?></p>
                <p><strong>Nama:</strong> <?= e((string) $user['nama']) ?></p>
                <p><strong>Email:</strong> <?= e((string) $user['email']) ?></p>
                <p><strong>No. Telepon:</strong> <?= e((string) ($user['no_telp'] ?? '-')) ?></p>
                <p><strong>Role:</strong> <?= e((string) $user['role']) ?></p>
                <p><strong>Tanggal Daftar:</strong> <?= e((string) $user['tanggal_bergabung']) ?></p>
            </article>
            <article class="form-card user-detail-card">
                <p><strong>Jumlah Laporan:</strong> <?= e((string) $user['total_laporan']) ?></p>
                <p><strong>Total Poin:</strong> <?= e((string) $user['total_poin']) ?></p>
                <p><strong>Laporan Valid:</strong> <?= e((string) ($user['laporan_valid'] ?? 0)) ?></p>
                <p><strong>Status Pengajuan Seller:</strong> <?= e((string) ($user['status_pengajuan_seller'] ?? '-')) ?></p>
            </article>
        </div>
        <div class="card-actions">
            <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/users.php')) ?>">Kembali</a>
        </div>
    </section>
    <?php
});

