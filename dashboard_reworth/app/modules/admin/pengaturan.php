<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$tab = $_GET['tab'] ?? 'profil_admin';
$allowed = ['profil_admin', 'profil_sistem'];
if (!in_array($tab, $allowed, true)) {
    $tab = 'profil_admin';
}

// Fungsi helper untuk setting
function get_setting($key, $default = '') {
    $result = supabase_fetch_one('pengaturan', 'setting_value', ['setting_key' => 'eq.' . $key]);
    return $result['setting_value'] ?? $default;
}

function update_setting($key, $value) {
    $existing = supabase_fetch_one('pengaturan', 'id_setting', ['setting_key' => 'eq.' . $key]);
    if ($existing) {
        return supabase_update('pengaturan', 
            ['setting_value' => $value, 'updated_at' => date('Y-m-d H:i:s')],
            ['setting_key' => 'eq.' . $key]
        );
    } else {
        return supabase_insert('pengaturan', [
            'setting_key' => $key,
            'setting_value' => $value,
            'updated_at' => date('Y-m-d H:i:s')
        ]);
    }
}

// Proses update pengaturan
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user = current_user();
    $userId = $user['id'] ?? null;
    $profileId = trim((string) ($user['profile_id'] ?? ''));
    $dashboardUserId = trim((string) ($user['dashboard_user_id'] ?? ''));
    
    if ($tab === 'profil_admin') {
        $updateData = [];
        if (!empty($_POST['nama_admin'])) {
            $updateData['nama_lengkap'] = $_POST['nama_admin'];
        }
        if (!empty($_POST['email_admin'])) {
            $updateData['email'] = $_POST['email_admin'];
        }
        if (!empty($updateData)) {
            if ($profileId !== '') {
                $result = supabase_update('profiles', $updateData, ['id' => 'eq.' . $profileId]);
            } elseif ($dashboardUserId !== '') {
                $result = supabase_update('dashboard_users', $updateData, ['id' => 'eq.' . $dashboardUserId]);
            } else {
                $result = null;
            }

            if (is_array($result)) {
                set_flash('success', 'Profil admin berhasil diupdate.');
            } else {
                set_flash('danger', 'Gagal update profil admin.');
            }
        } else {
            set_flash('info', 'Tidak ada perubahan pada profil admin.');
        }
        
    } elseif ($tab === 'profil_sistem') {
        update_setting('app_name', $_POST['nama_platform'] ?? 'ReWorth');
        update_setting('contact_email', $_POST['email_kontak'] ?? '');
        update_setting('contact_phone', $_POST['telepon'] ?? '');
        update_setting('app_description', $_POST['deskripsi'] ?? '');
        set_flash('success', 'Pengaturan sistem berhasil disimpan.');
    }
    
    redirect('app/modules/admin/pengaturan.php?tab=' . urlencode($tab));
}

// Ambil data admin yang login
$admin = current_user();
$adminName = $admin['nama_lengkap'] ?? $admin['nama'] ?? 'Admin ReWorth';
$adminEmail = $admin['email'] ?? 'admin@reworth.app';

// Ambil nilai setting untuk tampilan
$appName = get_setting('app_name', 'ReWorth');
$contactEmail = get_setting('contact_email', 'support@reworth.app');
$contactPhone = get_setting('contact_phone', '+62 812 0000 1111');
$appDescription = get_setting('app_description', 'ReWorth adalah platform ekosistem pelaporan sampah dan mini market produk daur ulang.');

render_layout('Pengaturan', function () use ($tab, $adminName, $adminEmail, $appName, $contactEmail, $contactPhone, $appDescription): void {
    ?>
    <style>
        .settings-layout {
            display: flex;
            gap: 24px;
            margin-top: 20px;
        }
        .settings-tabs {
            width: 200px;
            flex-shrink: 0;
            background: #f9fafb;
            border-radius: 12px;
            padding: 8px;
        }
        .settings-tabs a {
            display: block;
            padding: 12px 16px;
            color: #374151;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.2s;
        }
        .settings-tabs a:hover {
            background: #e5e7eb;
        }
        .settings-tabs a.active {
            background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(34, 197, 94, 0.3);
        }
        .form-stack {
            flex: 1;
            background: #f9fafb;
            border-radius: 12px;
            padding: 24px;
        }
        .form-field {
            display: block;
            margin-bottom: 20px;
        }
        .form-field span {
            display: block;
            font-weight: 500;
            color: #374151;
            margin-bottom: 8px;
        }
        .form-field input, .form-field select, .form-field textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            background: white;
        }
        .form-field input:focus, .form-field select:focus, .form-field textarea:focus {
            outline: none;
            border-color: #22c55e;
            box-shadow: 0 0 0 2px rgba(34, 197, 94, 0.2);
        }
        .form-field input:disabled, .form-field input:read-only {
            background: #f3f4f6;
            cursor: not-allowed;
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .card-actions {
            margin-top: 24px;
            padding-top: 16px;
            border-top: 1px solid #e5e7eb;
        }
        .btn-save {
            background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
            border: none;
            color: white;
            padding: 10px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(34, 197, 94, 0.25);
        }
        .btn-save:hover {
            background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(34, 197, 94, 0.4);
        }
        @media (max-width: 768px) {
            .settings-layout {
                flex-direction: column;
            }
            .settings-tabs {
                width: 100%;
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
            }
            .settings-tabs a {
                flex: 1;
                text-align: center;
            }
            .form-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pengaturan</h2>
                <p>Konfigurasi admin dan sistem ReWorth.</p>
            </div>
        </div>
        <div class="settings-layout">
            <nav class="settings-tabs">
                <a class="<?= $tab === 'profil_admin' ? 'active' : '' ?>" href="?tab=profil_admin">Profil Admin</a>
                <a class="<?= $tab === 'profil_sistem' ? 'active' : '' ?>" href="?tab=profil_sistem">Profil Sistem</a>
            </nav>
            
            <form class="form-stack" method="post" enctype="multipart/form-data">
                <?php if ($tab === 'profil_admin'): ?>
                    <div class="form-field">
                        <span>Foto Admin</span>
                        <input type="file" name="foto_admin" accept="image/*">
                        <small style="color: #6b7280;">Ukuran maksimal 2MB. Format: JPG, PNG</small>
                    </div>
                    <div class="form-grid">
                        <div class="form-field">
                            <span>Nama</span>
                            <input type="text" name="nama_admin" value="<?= e($adminName) ?>">
                        </div>
                        <div class="form-field">
                            <span>Email</span>
                            <input type="email" name="email_admin" value="<?= e($adminEmail) ?>">
                        </div>
                        <div class="form-field">
                            <span>Role</span>
                            <input type="text" value="admin" readonly disabled>
                        </div>
                    </div>
                    
                <?php elseif ($tab === 'profil_sistem'): ?>
                    <div class="form-grid">
                        <div class="form-field">
                            <span>Nama Platform</span>
                            <input type="text" name="nama_platform" value="<?= e($appName) ?>">
                        </div>
                        <div class="form-field">
                            <span>Email Kontak</span>
                            <input type="email" name="email_kontak" value="<?= e($contactEmail) ?>">
                        </div>
                        <div class="form-field">
                            <span>Nomor Telepon</span>
                            <input type="text" name="telepon" value="<?= e($contactPhone) ?>">
                        </div>
                    </div>
                    <div class="form-field">
                        <span>Logo Platform</span>
                        <input type="file" name="logo_platform" accept="image/*">
                        <small style="color: #6b7280;">Rekomendasi ukuran: 200x200px</small>
                    </div>
                    <div class="form-field">
                        <span>Deskripsi Platform</span>
                        <textarea name="deskripsi" rows="4"><?= e($appDescription) ?></textarea>
                    </div>
                <?php endif; ?>
                
                <div class="card-actions">
                    <button class="btn-save" type="submit">
                        <i class="fas fa-save"></i> Simpan Perubahan
                    </button>
                </div>
            </form>
        </div>
    </section>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <?php
});
