<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';

require_role('admin');

$tab = (string) ($_GET['tab'] ?? 'profil_admin');
$allowed = ['profil_admin', 'profil_sistem'];
if (!in_array($tab, $allowed, true)) {
    $tab = 'profil_admin';
}

$sessionUser = current_user() ?? [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($tab === 'profil_admin') {
        $result = admin_save_admin_profile($sessionUser, $_POST, $_FILES);
        if (($result['success'] ?? false) === true) {
            $_SESSION['dashboard_user'] = admin_refresh_session_user(
                $sessionUser,
                is_array($result['profile'] ?? null) ? $result['profile'] : [],
                is_array($result['dashboard_user'] ?? null) ? $result['dashboard_user'] : null
            );
        }
    } else {
        $result = admin_save_system_settings($sessionUser, $_POST, $_FILES);
    }

    set_flash(($result['success'] ?? false) ? 'success' : 'danger', (string) ($result['message'] ?? 'Terjadi kesalahan.'));
    redirect('app/modules/admin/pengaturan.php?tab=' . urlencode($tab));
}

$sessionUser = current_user() ?? [];
$profile = admin_find_profile_for_staff($sessionUser, 'admin');
$dashboardUser = admin_fetch_dashboard_user_by_id((string) ($sessionUser['dashboard_user_id'] ?? ''));

$adminName = (string) (($profile['nama_lengkap'] ?? $dashboardUser['nama_lengkap'] ?? $sessionUser['nama_lengkap'] ?? $sessionUser['nama'] ?? 'Admin ReWorth') ?: 'Admin ReWorth');
$adminEmail = (string) (($profile['email'] ?? $dashboardUser['email'] ?? $sessionUser['email'] ?? 'admin@reworth.app') ?: 'admin@reworth.app');
$adminPhone = (string) (($profile['no_telp'] ?? '') ?: '');
$adminPhoto = (string) (($profile['foto_profil'] ?? '') ?: '');

$appName = admin_setting_value('app_name', 'ReWorth');
$contactEmail = admin_setting_value('contact_email', 'support@reworth.app');
$contactPhone = admin_setting_value('contact_phone', '+62 812 0000 1111');
$appDescription = admin_setting_value('app_description', 'ReWorth adalah platform ekosistem pelaporan sampah dan mini market produk daur ulang.');
$appLogo = admin_setting_value('app_logo', 'assets/logo_reworth.jpeg');

render_layout('Pengaturan Profile', function () use (
    $tab,
    $adminName,
    $adminEmail,
    $adminPhone,
    $adminPhoto,
    $appName,
    $contactEmail,
    $contactPhone,
    $appDescription,
    $appLogo
): void {
    ?>
    <style>
        .settings-preview {
            display: grid;
            grid-template-columns: 96px minmax(0, 1fr);
            gap: 16px;
            align-items: center;
            padding: 16px;
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            background: #f9fafb;
        }
        .settings-preview-media {
            width: 96px;
            height: 96px;
            border-radius: 20px;
            overflow: hidden;
            background: linear-gradient(135deg, #e5f7dd, #f5fbf1);
            display: grid;
            place-items: center;
            color: #2e7d32;
            font-weight: 700;
        }
        .settings-preview-media img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .settings-helper {
            margin-top: 6px;
            color: #6b7280;
            font-size: 12px;
        }
    </style>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pengaturan Profile</h2>
                <p>Kelola profil admin dan konfigurasi aplikasi dari tabel `profiles` dan `pengaturan`.</p>
            </div>
        </div>

        <div class="settings-layout">
            <nav class="settings-tabs">
                <a class="<?= $tab === 'profil_admin' ? 'active' : '' ?>" href="<?= e(url('app/modules/admin/pengaturan.php?tab=profil_admin')) ?>">Profil Admin</a>
                <a class="<?= $tab === 'profil_sistem' ? 'active' : '' ?>" href="<?= e(url('app/modules/admin/pengaturan.php?tab=profil_sistem')) ?>">Profil Sistem</a>
            </nav>

            <form method="post" enctype="multipart/form-data" class="form-stack">
                <?php if ($tab === 'profil_admin'): ?>
                    <div class="settings-preview">
                        <div class="settings-preview-media">
                            <?php if ($adminPhoto !== ''): ?>
                                <img src="<?= e($adminPhoto) ?>" alt="Foto admin">
                            <?php else: ?>
                                <span><?= e(strtoupper(substr($adminName, 0, 1))) ?></span>
                            <?php endif; ?>
                        </div>
                        <div>
                            <strong><?= e($adminName) ?></strong>
                            <div style="color:#6b7280;margin-top:6px;"><?= e($adminEmail) ?></div>
                            <div style="color:#6b7280;margin-top:4px;"><?= e($adminPhone !== '' ? $adminPhone : 'Nomor telepon belum diisi') ?></div>
                        </div>
                    </div>

                    <div class="form-grid">
                        <label class="form-field">
                            <span>Nama Admin</span>
                            <input type="text" name="nama_admin" value="<?= e($adminName) ?>" required>
                        </label>
                        <label class="form-field">
                            <span>Email Admin</span>
                            <input type="email" name="email_admin" value="<?= e($adminEmail) ?>" required>
                        </label>
                        <label class="form-field">
                            <span>Nomor Telepon</span>
                            <input type="text" name="no_telp_admin" value="<?= e($adminPhone) ?>" placeholder="Contoh: 081234567890">
                        </label>
                        <label class="form-field">
                            <span>Role</span>
                            <input type="text" value="admin" readonly>
                        </label>
                    </div>

                    <label class="form-field">
                        <span>Foto Admin</span>
                        <input type="file" name="foto_admin" accept="image/*">
                        <small class="settings-helper">Format JPG/PNG, maksimal 2MB.</small>
                    </label>
                <?php else: ?>
                    <div class="settings-preview">
                        <div class="settings-preview-media" style="border-radius:16px;">
                            <img src="<?= e($appLogo !== '' ? $appLogo : url('assets/logo_reworth.jpeg')) ?>" alt="Logo aplikasi">
                        </div>
                        <div>
                            <strong><?= e($appName) ?></strong>
                            <div style="color:#6b7280;margin-top:6px;"><?= e($contactEmail) ?></div>
                            <div style="color:#6b7280;margin-top:4px;"><?= e($contactPhone) ?></div>
                        </div>
                    </div>

                    <div class="form-grid">
                        <label class="form-field">
                            <span>Nama Platform</span>
                            <input type="text" name="nama_platform" value="<?= e($appName) ?>" required>
                        </label>
                        <label class="form-field">
                            <span>Email Kontak</span>
                            <input type="email" name="email_kontak" value="<?= e($contactEmail) ?>">
                        </label>
                        <label class="form-field">
                            <span>Nomor Telepon Kontak</span>
                            <input type="text" name="telepon" value="<?= e($contactPhone) ?>">
                        </label>
                        <label class="form-field">
                            <span>Logo Aplikasi</span>
                            <input type="file" name="logo_platform" accept="image/*">
                            <small class="settings-helper">Logo akan disimpan ke pengaturan `app_logo`.</small>
                        </label>
                    </div>

                    <label class="form-field">
                        <span>Deskripsi Platform</span>
                        <textarea name="deskripsi" rows="5"><?= e($appDescription) ?></textarea>
                    </label>
                <?php endif; ?>

                <div class="card-actions">
                    <button class="btn btn-primary" type="submit">Simpan Perubahan</button>
                </div>
            </form>
        </div>
    </section>
    <?php
});
