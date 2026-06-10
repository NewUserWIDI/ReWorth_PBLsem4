<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';

require_role('admin');

$isEditing = (string) ($_GET['edit'] ?? '') === '1';
$sessionUser = current_user() ?? [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = admin_save_admin_profile($sessionUser, $_POST, $_FILES);
    if (($result['success'] ?? false) === true) {
        $_SESSION['dashboard_user'] = admin_refresh_session_user(
            $sessionUser,
            is_array($result['profile'] ?? null) ? $result['profile'] : [],
            is_array($result['dashboard_user'] ?? null) ? $result['dashboard_user'] : null
        );
    }

    set_flash(($result['success'] ?? false) ? 'success' : 'danger', (string) ($result['message'] ?? 'Terjadi kesalahan.'));

    $redirectUrl = 'app/modules/admin/pengaturan.php';
    if (($result['success'] ?? false) !== true) {
        $redirectUrl .= '&edit=1';
    }
    redirect($redirectUrl);
}

$sessionUser = current_user() ?? [];
$profile = admin_find_profile_for_staff($sessionUser, 'admin');
$dashboardUser = admin_fetch_dashboard_user_by_id((string) ($sessionUser['dashboard_user_id'] ?? ''));

$adminName = (string) (($profile['nama_lengkap'] ?? $dashboardUser['nama_lengkap'] ?? $sessionUser['nama_lengkap'] ?? $sessionUser['nama'] ?? 'Admin ReWorth') ?: 'Admin ReWorth');
$adminEmail = (string) (($profile['email'] ?? $dashboardUser['email'] ?? $sessionUser['email'] ?? 'admin@reworth.app') ?: 'admin@reworth.app');
$adminPhone = (string) (($profile['no_telp'] ?? '') ?: '');
$adminPhoto = (string) (($profile['foto_profil'] ?? '') ?: '');
$dashboardUsername = (string) (($dashboardUser['username'] ?? $sessionUser['username'] ?? 'admin.reworth') ?: 'admin.reworth');
$dashboardStatusText = (is_array($dashboardUser) && (($dashboardUser['is_active'] ?? true) === false || ($dashboardUser['is_active'] ?? true) === 0)) ? 'Nonaktif' : 'Aktif';
$adminInitials = strtoupper(substr(preg_replace('/[^A-Za-z]/', '', $adminName) ?: 'AD', 0, 2));
$adminRole = 'admin';
$adminDescription = 'Kelola profil admin ReWorth, identitas akun, dan akses dashboard dari satu halaman yang rapi.';
$profileId = (string) (($profile['id'] ?? $sessionUser['profile_id'] ?? '-') ?: '-');

render_layout('Pengaturan Profile', function () use (
    $isEditing,
    $adminName,
    $adminEmail,
    $adminPhone,
    $adminPhoto,
    $dashboardUsername,
    $dashboardStatusText,
    $adminInitials,
    $adminRole,
    $adminDescription,
    $profileId
): void {
    ?>
    <style>
        .admin-profile-avatar-fallback {
            width: 100%;
            height: 100%;
            display: grid;
            place-items: center;
            background: linear-gradient(135deg, #eaf7dd, #cdeeb5);
            color: #1f5e23;
            font-size: 36px;
            font-weight: 800;
        }
        .admin-profile-page .seller-account-list strong.status-active {
            color: #15803d;
        }
        .admin-profile-edit-note {
            margin-top: 12px;
            color: #98a2b3;
            font-size: 12px;
            line-height: 1.5;
        }
        .admin-profile-edit-page {
            width: 100%;
            max-width: 1280px;
            margin: 0 auto;
            padding: 32px 32px 64px;
            display: grid;
            gap: 24px;
            background: #f7f8fa;
        }
        .admin-profile-edit-card {
            padding: 32px;
            border: 1px solid #eceef1;
            border-radius: 28px;
            background: #ffffff;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.03);
        }
        .admin-profile-edit-layout {
            display: grid;
            grid-template-columns: 240px minmax(0, 1fr);
            gap: 32px;
            align-items: start;
        }
        .admin-profile-edit-media {
            display: grid;
            gap: 16px;
            align-content: start;
        }
        .admin-profile-edit-avatar {
            width: 180px;
            height: 180px;
            overflow: hidden;
            border: 1px solid #eceef1;
            border-radius: 999px;
            background: #f3f4f6;
        }
        .admin-profile-edit-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }
        .admin-profile-edit-upload {
            width: 100%;
            padding: 18px;
            border: 1px dashed #d0d5dd;
            border-radius: 18px;
            background: #fafafa;
            box-sizing: border-box;
        }
        .admin-profile-edit-upload span {
            display: block;
            margin-bottom: 8px;
            color: #111827;
            font-size: 14px;
            font-weight: 600;
        }
        .admin-profile-edit-upload small {
            display: block;
            margin-bottom: 14px;
            color: #98a2b3;
            font-size: 12px;
            line-height: 1.5;
        }
        .admin-profile-edit-upload input[type="file"] {
            width: 100%;
            color: #667085;
            font-size: 12px;
        }
        .admin-profile-edit-upload input[type="file"]::file-selector-button {
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
        .admin-profile-edit-preview-meta {
            width: 100%;
            padding: 16px 18px;
            border: 1px solid #eceef1;
            border-radius: 18px;
            background: #ffffff;
            box-sizing: border-box;
        }
        .admin-profile-edit-preview-meta strong {
            display: block;
            color: #111827;
            font-size: 15px;
            font-weight: 700;
        }
        .admin-profile-edit-preview-meta span {
            display: block;
            margin-top: 6px;
            color: #667085;
            font-size: 13px;
            line-height: 1.5;
        }
        .admin-profile-edit-section-title {
            margin: 0 0 16px;
            color: #111827;
            font-size: 18px;
            font-weight: 700;
        }
        .admin-profile-edit-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }
        .admin-profile-edit-grid .form-field {
            gap: 8px;
        }
        .admin-profile-edit-grid .form-field span {
            color: #667085;
            font-size: 13px;
            font-weight: 500;
        }
        .admin-profile-edit-grid input,
        .admin-profile-edit-grid textarea {
            border: 1px solid #d0d5dd;
            border-radius: 14px;
            background: #ffffff;
        }
        .admin-profile-edit-grid textarea {
            min-height: 120px;
        }
        .admin-profile-edit-access {
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #eceef1;
        }
        .admin-profile-edit-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 24px;
        }
        .admin-profile-edit-actions .seller-profile-outline-btn {
            min-height: 48px;
            padding: 0 18px;
            border: 1px solid #15803d;
            border-radius: 14px;
            background: #ffffff;
            color: #15803d;
            font-size: 14px;
            font-weight: 600;
        }
        @media (max-width: 1100px) {
            .admin-profile-edit-layout,
            .admin-profile-edit-grid {
                grid-template-columns: 1fr;
            }
            .admin-profile-edit-page {
                padding: 24px 20px 48px;
            }
        }
    </style>

    <?php if ($isEditing): ?>
        <form class="admin-profile-edit-page" method="post" enctype="multipart/form-data">
            <div class="page-heading seller-profile-page-heading">
                <div>
                    <p>Pengaturan Profile &gt; <strong>Profil Admin</strong></p>
                    <h2>Edit Profil Admin</h2>
                    <span>Perbarui identitas admin dashboard dan pastikan data profil tetap sinkron dengan akun internal.</span>
                </div>
            </div>

            <section class="admin-profile-edit-card">
                <div class="admin-profile-edit-layout">
                    <div class="admin-profile-edit-media">
                        <div class="admin-profile-edit-avatar">
                            <?php if ($adminPhoto !== ''): ?>
                                <img src="<?= e($adminPhoto) ?>" alt="Foto admin">
                            <?php else: ?>
                                <div class="admin-profile-avatar-fallback"><?= e($adminInitials) ?></div>
                            <?php endif; ?>
                        </div>
                        <div class="admin-profile-edit-preview-meta">
                            <strong><?= e($adminName) ?></strong>
                            <span>Gunakan foto profil yang jelas agar identitas admin lebih mudah dikenali saat mengelola dashboard.</span>
                        </div>
                        <label class="admin-profile-edit-upload">
                            <span>Foto Profil Admin</span>
                            <small>Disarankan foto persegi agar tampil rapi saat dipotong menjadi avatar bulat seperti halaman seller.</small>
                            <input type="file" name="foto_admin" accept="image/*">
                        </label>
                    </div>

                    <div>
                        <h3 class="admin-profile-edit-section-title">Informasi Admin</h3>
                        <div class="admin-profile-edit-grid">
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
                                <span>ID Profil</span>
                                <input value="<?= e($profileId) ?>" disabled>
                            </label>
                            <label class="form-field" style="grid-column: 1 / -1;">
                                <span>Ringkasan Profil</span>
                                <textarea disabled><?= e($adminDescription) ?></textarea>
                            </label>
                        </div>

                        <div class="admin-profile-edit-access">
                            <h3 class="admin-profile-edit-section-title">Akses Dashboard</h3>
                            <div class="admin-profile-edit-grid">
                                <label class="form-field">
                                    <span>Username Dashboard</span>
                                    <input value="<?= e($dashboardUsername) ?>" disabled>
                                </label>
                                <label class="form-field">
                                    <span>Role</span>
                                    <input value="<?= e(strtoupper($adminRole)) ?>" disabled>
                                </label>
                                <label class="form-field">
                                    <span>Status Akun</span>
                                    <input value="<?= e($dashboardStatusText) ?>" disabled>
                                </label>
                                <label class="form-field">
                                    <span>Jenis Akses</span>
                                    <input value="Dashboard Internal ReWorth" disabled>
                                </label>
                            </div>
                            <p class="admin-profile-edit-note">Username dan role dashboard tetap dibaca dari akun internal. Halaman ini fokus pada sinkronisasi identitas admin di tabel profil.</p>
                        </div>

                        <div class="admin-profile-edit-actions">
                            <a class="btn btn-secondary seller-profile-outline-btn" href="<?= e(url('app/modules/admin/pengaturan.php')) ?>">Batal</a>
                            <button class="btn btn-primary" type="submit">Simpan Perubahan</button>
                        </div>
                    </div>
                </div>
            </section>
        </form>
    <?php else: ?>
        <div class="seller-profile-page admin-profile-page">
            <div class="page-heading seller-profile-page-heading">
                <div>
                    <p>Pengaturan Profile &gt; <strong>Profil Admin</strong></p>
                    <h2>Profil Admin</h2>
                    <span>Kelola identitas admin utama ReWorth dengan tampilan yang konsisten seperti halaman profil seller.</span>
                </div>
            </div>

            <section class="seller-profile-card seller-profile-hero-card">
                <div class="seller-profile-cover">
                    <?php if ($adminPhoto !== ''): ?>
                        <img src="<?= e($adminPhoto) ?>" alt="Foto admin">
                    <?php else: ?>
                        <div class="admin-profile-avatar-fallback"><?= e($adminInitials) ?></div>
                    <?php endif; ?>
                    <a class="seller-photo-edit" href="<?= e(url('app/modules/admin/pengaturan.php?edit=1')) ?>" aria-label="Ubah foto admin">Edit</a>
                </div>
                <div class="seller-profile-content">
                    <div class="panel-header seller-profile-hero-header">
                        <div class="seller-profile-hero-copy">
                            <h2><?= e($adminName) ?></h2>
                            <span class="seller-profile-status-pill">Admin <?= e($dashboardStatusText) ?></span>
                            <p><?= e($adminDescription) ?></p>
                        </div>
                        <a class="btn btn-secondary seller-profile-outline-btn" href="<?= e(url('app/modules/admin/pengaturan.php?edit=1')) ?>">Edit Profil</a>
                    </div>
                    <div class="seller-profile-grid">
                        <div>
                            <span>Email</span>
                            <strong><?= e($adminEmail !== '' ? $adminEmail : '-') ?></strong>
                        </div>
                        <div>
                            <span>Telepon</span>
                            <strong><?= e($adminPhone !== '' ? $adminPhone : '-') ?></strong>
                        </div>
                        <div>
                            <span>Role</span>
                            <strong><?= e(strtoupper($adminRole)) ?></strong>
                        </div>
                        <div>
                            <span>Username Dashboard</span>
                            <strong><?= e($dashboardUsername) ?></strong>
                        </div>
                        <div>
                            <span>Status Akun</span>
                            <strong class="seller-profile-status-text"><?= e($dashboardStatusText) ?></strong>
                        </div>
                        <div>
                            <span>ID Profil</span>
                            <strong><?= e($profileId) ?></strong>
                        </div>
                    </div>
                </div>
            </section>

            <section class="panel seller-account-panel">
                <div class="panel-header seller-simple-panel-header">
                    <div>
                        <h2>Informasi Akun Dashboard</h2>
                        <p>Ringkasan akun admin yang dipakai untuk mengelola seluruh modul ReWorth.</p>
                    </div>
                </div>
                <div class="seller-account-list">
                    <div>
                        <span class="seller-account-icon">ID</span>
                        <span>Profil</span>
                        <strong><?= e($profileId) ?></strong>
                        <span></span>
                    </div>
                    <div>
                        <span class="seller-account-icon">@</span>
                        <span>Username</span>
                        <strong><?= e($dashboardUsername) ?></strong>
                        <span></span>
                    </div>
                    <div>
                        <span class="seller-account-icon">EM</span>
                        <span>Email Login</span>
                        <strong><?= e($adminEmail !== '' ? $adminEmail : '-') ?></strong>
                        <span></span>
                    </div>
                    <div>
                        <span class="seller-account-icon">RL</span>
                        <span>Role Sistem</span>
                        <strong><?= e(strtoupper($adminRole)) ?></strong>
                        <span></span>
                    </div>
                    <div>
                        <span class="seller-account-icon">ST</span>
                        <span>Status Akses</span>
                        <strong class="<?= $dashboardStatusText === 'Aktif' ? 'status-active' : '' ?>"><?= e($dashboardStatusText) ?></strong>
                        <span></span>
                    </div>
                </div>
            </section>
        </div>
    <?php endif; ?>
    <?php
});
