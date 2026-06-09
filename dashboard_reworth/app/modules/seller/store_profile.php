<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$isEditing = ($_GET['edit'] ?? '') === '1';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = seller_update_store_profile($sellerUserId, 'profil', $_POST, $_FILES);
    set_flash((string) ($result['type'] ?? 'success'), (string) ($result['message'] ?? 'Perubahan disimpan.'));
    redirect('app/modules/seller/store_profile.php');
}

$profile = seller_fetch_profile($sellerUserId);
if ($profile === null) {
    set_flash('warning', 'Profil seller tidak ditemukan.');
    redirect('app/modules/seller/dashboard.php');
}

render_layout('Pengaturan Toko', function () use ($isEditing, $profile): void {
    $rekening = $profile['rekening_bank'] ?? null;
    $isActive = (bool) ($profile['aktif'] ?? false);
    $verificationText = status_label((string) $profile['status_verifikasi']);
    $storeStatusText = $isActive ? 'Aktif' : 'Nonaktif';
    ?>
    <?php if ($isEditing): ?>
        <style>
            .seller-edit-page {
                width: 100%;
                max-width: 1280px;
                margin: 0 auto;
                padding: 32px 32px 64px;
                display: grid;
                gap: 24px;
                background: #f7f8fa;
            }
            .seller-edit-card {
                padding: 32px;
                border: 1px solid #eceef1;
                border-radius: 28px;
                background: #ffffff;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.03);
            }
            .seller-edit-layout {
                display: grid;
                grid-template-columns: 240px minmax(0, 1fr);
                gap: 32px;
                align-items: start;
            }
            .seller-edit-media {
                display: grid;
                gap: 16px;
                align-content: start;
            }
            .seller-edit-avatar {
                width: 180px;
                height: 180px;
                overflow: hidden;
                border: 1px solid #eceef1;
                border-radius: 999px;
                background: #f3f4f6;
            }
            .seller-edit-avatar img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                display: block;
            }
            .seller-edit-avatar-fallback {
                width: 100%;
                height: 100%;
                display: grid;
                place-items: center;
                background: linear-gradient(135deg, #eaf7dd, #cdeeb5);
                color: #1f5e23;
                font-size: 36px;
                font-weight: 800;
            }
            .seller-edit-upload {
                width: 100%;
                padding: 18px;
                border: 1px dashed #d0d5dd;
                border-radius: 18px;
                background: #fafafa;
                box-sizing: border-box;
            }
            .seller-edit-upload span {
                display: block;
                margin-bottom: 8px;
                color: #111827;
                font-size: 14px;
                font-weight: 600;
            }
            .seller-edit-upload small {
                display: block;
                margin-bottom: 14px;
                color: #98a2b3;
                font-size: 12px;
                line-height: 1.5;
            }
            .seller-edit-upload input[type="file"] {
                width: 100%;
                color: #667085;
                font-size: 12px;
            }
            .seller-edit-upload input[type="file"]::file-selector-button {
                margin-right: 12px;
                padding: 10px 14px;
                border: 1px solid #d0d5dd;
                border-radius: 12px;
                background: #ffffff;
                color: #344054;
                font-size: 12px;
                font-weight: 600;
                cursor: pointer;
            }
            .seller-edit-preview-meta {
                width: 100%;
                padding: 16px 18px;
                border: 1px solid #eceef1;
                border-radius: 18px;
                background: #ffffff;
                box-sizing: border-box;
            }
            .seller-edit-preview-meta strong {
                display: block;
                color: #111827;
                font-size: 15px;
                font-weight: 700;
            }
            .seller-edit-preview-meta span {
                display: block;
                margin-top: 6px;
                color: #667085;
                font-size: 13px;
                line-height: 1.5;
            }
            .seller-edit-section-title {
                margin: 0 0 16px;
                color: #111827;
                font-size: 18px;
                font-weight: 700;
            }
            .seller-edit-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 16px;
            }
            .seller-edit-grid .form-field,
            .seller-edit-bank-grid .form-field {
                gap: 8px;
            }
            .seller-edit-grid .form-field span,
            .seller-edit-bank-grid .form-field span {
                color: #667085;
                font-size: 13px;
                font-weight: 500;
            }
            .seller-edit-grid input,
            .seller-edit-grid textarea,
            .seller-edit-bank-grid input {
                border: 1px solid #d0d5dd;
                border-radius: 14px;
                background: #ffffff;
            }
            .seller-edit-grid textarea {
                min-height: 120px;
            }
            .seller-edit-bank {
                margin-top: 24px;
                padding-top: 24px;
                border-top: 1px solid #eceef1;
            }
            .seller-edit-bank-grid {
                display: grid;
                grid-template-columns: repeat(3, minmax(0, 1fr));
                gap: 16px;
            }
            .seller-edit-note {
                margin-top: 12px;
                color: #98a2b3;
                font-size: 12px;
                line-height: 1.5;
            }
            .seller-edit-actions {
                display: flex;
                justify-content: flex-end;
                gap: 12px;
                margin-top: 24px;
            }
            @media (max-width: 1100px) {
                .seller-edit-page {
                    padding: 24px 20px 48px;
                }
                .seller-edit-layout,
                .seller-edit-grid,
                .seller-edit-bank-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
        <form class="seller-edit-page" method="post" enctype="multipart/form-data">
            <div class="page-heading seller-profile-page-heading">
                <div>
                    <p>Pengaturan Toko &gt; <strong>Profil Toko</strong></p>
                    <h2>Edit Profil Toko</h2>
                    <span>Perbarui identitas toko dan rekening pencairan dashboard seller.</span>
                </div>
            </div>

            <section class="seller-edit-card">
                <div class="seller-edit-layout">
                    <div class="seller-edit-media">
                        <div class="seller-edit-avatar">
                            <?php if (($profile['foto_toko'] ?? '') !== ''): ?>
                                <img src="<?= e((string) $profile['foto_toko']) ?>" alt="Foto toko">
                            <?php else: ?>
                                <div class="seller-edit-avatar-fallback"><?= e(substr((string) $profile['nama_toko'], 0, 2)) ?></div>
                            <?php endif; ?>
                        </div>
                        <div class="seller-edit-preview-meta">
                            <strong><?= e((string) $profile['nama_toko']) ?></strong>
                            <span>Gunakan foto atau logo toko yang jelas agar tampilan profil seller terlihat lebih profesional.</span>
                        </div>
                        <label class="seller-edit-upload">
                            <span>Logo / Foto Toko</span>
                            <small>Disarankan foto persegi agar hasil crop tetap rapi saat ditampilkan sebagai avatar bulat.</small>
                            <input type="file" name="logo" accept="image/*">
                        </label>
                    </div>

                    <div>
                        <h3 class="seller-edit-section-title">Informasi Toko</h3>
                        <div class="seller-edit-grid">
                            <label class="form-field">
                                <span>Nama Toko</span>
                                <input name="nama_toko" value="<?= e((string) $profile['nama_toko']) ?>" required>
                            </label>
                            <label class="form-field">
                                <span>Email Toko</span>
                                <input type="email" name="email" value="<?= e((string) $profile['email']) ?>">
                            </label>
                            <label class="form-field">
                                <span>Nomor Telepon</span>
                                <input name="telepon" value="<?= e((string) $profile['no_telp']) ?>">
                            </label>
                            <label class="form-field">
                                <span>Username Dashboard</span>
                                <input value="<?= e((string) $profile['username_dashboard']) ?>" disabled>
                            </label>
                            <label class="form-field" style="grid-column: 1 / -1;">
                                <span>Deskripsi Toko</span>
                                <textarea name="deskripsi"><?= e((string) $profile['deskripsi_toko']) ?></textarea>
                            </label>
                        </div>

                        <div class="seller-edit-bank">
                            <h3 class="seller-edit-section-title">Rekening Pencairan</h3>
                            <div class="seller-edit-bank-grid">
                                <label class="form-field">
                                    <span>Nama Bank</span>
                                    <input name="bank_name" value="<?= e((string) ($rekening['nama_bank'] ?? '')) ?>" placeholder="Contoh: BCA">
                                </label>
                                <label class="form-field">
                                    <span>Nama Pemilik Rekening</span>
                                    <input name="bank_owner" value="<?= e((string) ($rekening['nama_pemilik'] ?? ($profile['owner_name'] ?? ''))) ?>" placeholder="Nama lengkap pemilik rekening">
                                </label>
                                <label class="form-field">
                                    <span>Nomor Rekening</span>
                                    <input name="bank_account_number" value="" placeholder="<?= is_array($rekening) ? 'Akhiri dengan ' . e((string) ($rekening['last4_digit'] ?? '')) : 'Masukkan nomor rekening' ?>">
                                </label>
                            </div>
                            <p class="seller-edit-note">Nomor rekening tidak ditampilkan penuh di dashboard. Sistem hanya menyimpan empat digit terakhir untuk ditampilkan kembali.</p>
                        </div>

                        <div class="seller-edit-actions">
                            <a class="btn btn-secondary seller-profile-outline-btn" href="<?= e(url('app/modules/seller/store_profile.php')) ?>">Batal</a>
                            <button class="btn btn-primary" type="submit">Simpan Perubahan</button>
                        </div>
                    </div>
                </div>
            </section>
        </form>
    <?php else: ?>
        <style>
            .seller-profile-page {
                width: 100%;
                max-width: 1280px;
                margin: 0 auto;
                padding: 32px 32px 64px;
                display: grid;
                gap: 24px;
                background: #f7f8fa;
            }
            .seller-profile-page-heading {
                display: block;
            }
            .seller-profile-page-heading p {
                margin: 0;
                color: #98a2b3;
                font-size: 13px;
            }
            .seller-profile-page-heading h2 {
                margin: 18px 0 0;
                color: #111827;
                font-size: 32px;
                font-weight: 700;
                line-height: 1.2;
            }
            .seller-profile-page-heading span {
                display: block;
                margin-top: 8px;
                color: #667085;
                font-size: 14px;
                line-height: 1.5;
            }
            .seller-profile-page .seller-profile-card,
            .seller-profile-page .seller-account-panel,
            .seller-profile-page .seller-payout-panel {
                width: 100%;
                padding: 32px;
                border: 1px solid #eceef1;
                border-radius: 28px;
                background: #ffffff;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.03);
            }
            .seller-profile-page .seller-profile-hero-card {
                display: grid !important;
                grid-template-columns: 220px minmax(0, 1fr);
                align-items: center;
                gap: 40px;
                min-height: 340px;
            }
            .seller-profile-page .seller-profile-cover {
                position: relative;
                width: 180px !important;
                min-width: 180px !important;
                max-width: 180px !important;
                height: 180px !important;
                min-height: 180px !important;
                max-height: 180px !important;
                margin: 0 auto !important;
                overflow: hidden !important;
                border: 1px solid #eceef1 !important;
                border-radius: 999px !important;
                background: #f3f4f6 !important;
            }
            .seller-profile-page .seller-profile-cover img {
                width: 100% !important;
                height: 100% !important;
                object-fit: cover !important;
                display: block !important;
            }
            .seller-profile-page .seller-profile-content {
                width: 100%;
                padding: 0 !important;
            }
            .seller-profile-page .seller-profile-hero-header {
                display: flex !important;
                align-items: flex-start !important;
                justify-content: space-between !important;
                gap: 24px;
                margin-bottom: 24px;
                padding-bottom: 24px;
                border-bottom: 1px solid #eceef1;
            }
            .seller-profile-page .seller-profile-hero-copy h2 {
                margin: 0;
                color: #111827;
                font-size: 42px;
                font-weight: 700;
                line-height: 1.1;
            }
            .seller-profile-page .seller-profile-status-pill {
                display: inline-flex;
                align-items: center;
                margin-top: 12px;
                padding: 8px 16px;
                border-radius: 999px;
                background: #ecfdf3;
                color: #15803d;
                font-size: 14px;
                font-weight: 600;
            }
            .seller-profile-page .seller-profile-hero-copy p {
                max-width: 720px;
                margin: 24px 0 0;
                color: #667085;
                font-size: 14px;
                line-height: 1.5;
                display: -webkit-box;
                overflow: hidden;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
            }
            .seller-profile-page .seller-profile-outline-btn {
                min-height: 48px;
                padding: 0 18px;
                border: 1px solid #15803d;
                border-radius: 14px;
                background: #ffffff;
                color: #15803d;
                font-size: 14px;
                font-weight: 600;
            }
            .seller-profile-page .seller-photo-edit {
                position: absolute;
                right: 8px;
                bottom: 8px;
                width: 42px !important;
                min-width: 42px !important;
                height: 42px !important;
                padding: 0 !important;
                display: grid !important;
                place-items: center !important;
                border: 1px solid #eceef1 !important;
                border-radius: 999px !important;
                background: #ffffff !important;
                color: #15803d !important;
                font-size: 12px !important;
                font-weight: 700 !important;
                box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
            }
            .seller-profile-page .seller-profile-grid {
                display: grid !important;
                grid-template-columns: repeat(3, minmax(0, 1fr));
                gap: 32px;
            }
            .seller-profile-page .seller-profile-grid div {
                padding: 0 !important;
                border: 0 !important;
                background: transparent !important;
            }
            .seller-profile-page .seller-profile-grid span {
                display: block;
                color: #98a2b3;
                font-size: 13px;
                font-weight: 500;
            }
            .seller-profile-page .seller-profile-grid strong {
                display: block;
                margin-top: 8px;
                color: #111827;
                font-size: 17px;
                font-weight: 600;
                line-height: 1.5;
            }
            .seller-profile-page .seller-profile-status-text {
                color: #15803d !important;
            }
            .seller-profile-page .seller-simple-panel-header {
                margin-bottom: 20px;
            }
            .seller-profile-page .seller-simple-panel-header h2 {
                margin: 0;
                font-size: 18px;
                font-weight: 700;
                color: #111827;
            }
            .seller-profile-page .seller-simple-panel-header p {
                margin: 6px 0 0;
                color: #667085;
                font-size: 14px;
            }
            .seller-profile-page .seller-account-list > div {
                display: grid !important;
                grid-template-columns: 44px 140px minmax(0, 1fr) auto;
                align-items: center;
                gap: 16px;
                min-height: 72px;
                padding: 0 8px;
                border-top: 1px solid #eceef1;
            }
            .seller-profile-page .seller-account-list > div:hover {
                background: #fafafa;
            }
            .seller-profile-page .seller-account-icon {
                width: 36px;
                height: 36px;
                display: grid;
                place-items: center;
                border-radius: 12px;
                background: #f8fafc;
                color: #344054;
                font-size: 13px;
                font-weight: 700;
            }
            .seller-profile-page .seller-account-list > div > span:not(.seller-account-icon) {
                color: #344054;
                font-size: 14px;
                font-weight: 500;
            }
            .seller-profile-page .seller-account-list strong {
                color: #111827;
                font-size: 16px;
                font-weight: 500;
            }
            .seller-profile-page .seller-payout-panel .seller-bank-card {
                display: grid !important;
                grid-template-columns: repeat(3, minmax(0, 1fr));
                gap: 24px;
            }
            .seller-profile-page .seller-payout-panel .seller-bank-card > div {
                padding: 20px;
                border: 1px solid #eceef1;
                border-radius: 20px;
                background: #ffffff;
            }
            .seller-profile-page .seller-payout-panel .seller-bank-card span {
                color: #98a2b3;
                font-size: 13px;
            }
            .seller-profile-page .seller-payout-panel .seller-bank-card strong {
                display: block;
                margin-top: 10px;
                color: #111827;
                font-size: 16px;
                font-weight: 600;
            }
            .seller-profile-page .seller-bank-empty {
                min-height: 280px;
                display: grid;
                place-items: center;
                gap: 12px;
                border: 1px dashed #d0d5dd;
                border-radius: 24px;
                background: #ffffff;
                text-align: center;
            }
            .seller-profile-page .seller-bank-empty-icon {
                width: 72px;
                height: 72px;
                display: grid;
                place-items: center;
                border-radius: 999px;
                background: #f2f4f7;
                color: #98a2b3;
                font-size: 22px;
                letter-spacing: -2px;
            }
            .seller-profile-page .seller-bank-empty strong {
                color: #344054;
                font-size: 16px;
                font-weight: 600;
            }
            .seller-profile-page .seller-bank-empty p {
                margin: 0;
                color: #667085;
                font-size: 14px;
            }
            @media (max-width: 1100px) {
                .seller-profile-page {
                    padding: 24px 20px 48px;
                }
                .seller-profile-page .seller-profile-hero-card,
                .seller-profile-page .seller-profile-grid,
                .seller-profile-page .seller-account-list > div,
                .seller-profile-page .seller-payout-panel .seller-bank-card {
                    grid-template-columns: 1fr !important;
                }
                .seller-profile-page .seller-profile-hero-header {
                    flex-direction: column;
                }
            }
        </style>
        <div class="seller-profile-page">
            <div class="page-heading seller-profile-page-heading">
                <div>
                    <p>Pengaturan Toko &gt; <strong>Profil Toko</strong></p>
                    <h2>Profil Toko</h2>
                    <span>Kelola informasi profil toko Anda.</span>
                </div>
            </div>

            <section class="seller-profile-card seller-profile-hero-card">
                <div class="seller-profile-cover">
                    <?php if (($profile['foto_toko'] ?? '') !== ''): ?>
                        <img src="<?= e((string) $profile['foto_toko']) ?>" alt="Foto toko">
                    <?php else: ?>
                        <span><?= e(substr((string) $profile['nama_toko'], 0, 2)) ?></span>
                    <?php endif; ?>
                    <a class="seller-photo-edit" href="<?= e(url('app/modules/seller/store_profile.php?edit=1')) ?>" aria-label="Ubah foto toko">Edit</a>
                </div>
                <div class="seller-profile-content">
                    <div class="panel-header seller-profile-hero-header">
                        <div class="seller-profile-hero-copy">
                            <h2><?= e((string) $profile['nama_toko']) ?></h2>
                            <span class="seller-profile-status-pill"><?= $isActive ? 'Toko Aktif' : 'Toko Nonaktif' ?></span>
                            <p><?= e((string) ($profile['deskripsi_toko'] !== '' ? $profile['deskripsi_toko'] : 'Toko produk daur ulang ReWorth untuk seller dashboard.')) ?></p>
                        </div>
                        <a class="btn btn-secondary seller-profile-outline-btn" href="<?= e(url('app/modules/seller/store_profile.php?edit=1')) ?>">Edit Profil</a>
                    </div>
                    <div class="seller-profile-grid">
                        <div>
                            <span>Pemilik</span>
                            <strong><?= e((string) ($profile['owner_name'] !== '' ? $profile['owner_name'] : '-')) ?></strong>
                        </div>
                        <div>
                            <span>Email</span>
                            <strong><?= e((string) ($profile['email'] !== '' ? $profile['email'] : '-')) ?></strong>
                        </div>
                        <div>
                            <span>Telepon</span>
                            <strong><?= e((string) ($profile['no_telp'] !== '' ? $profile['no_telp'] : '-')) ?></strong>
                        </div>
                        <div>
                            <span>Username Dashboard</span>
                            <strong><?= e((string) $profile['username_dashboard']) ?></strong>
                        </div>
                        <div>
                            <span>Status Verifikasi</span>
                            <strong class="seller-profile-status-text"><?= e($verificationText) ?></strong>
                        </div>
                        <div>
                            <span>Status Toko</span>
                            <strong class="seller-profile-status-text"><?= e($storeStatusText) ?></strong>
                        </div>
                    </div>
                </div>
            </section>

            <section class="panel seller-payout-panel">
                <div class="panel-header seller-simple-panel-header">
                    <div>
                        <h2>Rekening Pencairan</h2>
                        <p>Diambil dari akun bank utama yang ditambahkan di profil mobile.</p>
                    </div>
                </div>
                <?php if (is_array($rekening)): ?>
                    <div class="seller-bank-card">
                        <div>
                            <span><?= e((string) ($rekening['kartu_utama'] ? 'Rekening Aktif' : 'Rekening')) ?></span>
                            <strong><?= e((string) ($rekening['nama_bank'] !== '' ? $rekening['nama_bank'] : 'Bank')) ?></strong>
                        </div>
                        <div>
                            <span>Nomor Rekening</span>
                            <strong>**** **** <?= e((string) ($rekening['last4_digit'] !== '' ? $rekening['last4_digit'] : '----')) ?></strong>
                        </div>
                        <div>
                            <span>Nama Pemilik</span>
                            <strong><?= e((string) ($rekening['nama_pemilik'] !== '' ? $rekening['nama_pemilik'] : '-')) ?></strong>
                        </div>
                    </div>
                <?php else: ?>
                    <div class="empty-state seller-bank-empty">
                        <div class="seller-bank-empty-icon">[]</div>
                        <strong>Belum ada rekening aktif.</strong>
                        <p>Tambahkan akun bank dari menu profil di aplikasi mobile.</p>
                    </div>
                <?php endif; ?>
            </section>
        </div>
    <?php endif; ?>
    <?php
});
