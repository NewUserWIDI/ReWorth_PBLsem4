<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';

require_role('admin');

$id = trim((string) ($_GET['id'] ?? ''));
$isEdit = $id !== '';
$dlh = $isEdit ? admin_dlh_by_id($id) : null;

if ($isEdit && $dlh === null) {
    set_flash('warning', 'Data DLH tidak ditemukan.');
    redirect('app/modules/admin/data_dlh.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = admin_save_dlh($_POST, $isEdit ? $id : null);
    set_flash($result['success'] ? 'success' : 'danger', (string) $result['message']);

    if ($result['success']) {
        redirect('app/modules/admin/data_dlh_detail.php?id=' . urlencode((string) ($result['id'] ?? $id)));
    }
}

$formValues = [
    'nama_lengkap' => (string) ($dlh['nama'] ?? ''),
    'email' => (string) ($dlh['email'] ?? ''),
    'no_telp' => (string) ($dlh['no_telp'] ?? ''),
    'username' => (string) ($dlh['username'] ?? ''),
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $formValues = [
        'nama_lengkap' => trim((string) ($_POST['nama_lengkap'] ?? '')),
        'email' => trim((string) ($_POST['email'] ?? '')),
        'no_telp' => trim((string) ($_POST['no_telp'] ?? '')),
        'username' => trim((string) ($_POST['username'] ?? '')),
    ];
}

render_layout($isEdit ? 'Edit DLH' : 'Tambah DLH', function () use ($isEdit, $dlh, $formValues): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2><?= e($isEdit ? 'Edit Data DLH' : 'Tambah DLH Baru') ?></h2>
                <p><?= e($isEdit ? 'Perbarui profil petugas DLH yang sudah ada.' : 'Buat profil dan akun dashboard untuk petugas DLH baru.') ?></p>
            </div>
        </div>

        <form method="post" class="form-stack">
            <div class="form-grid">
                <label class="form-field">
                    <span>Nama Lengkap</span>
                    <input type="text" name="nama_lengkap" required value="<?= e((string) ($formValues['nama_lengkap'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Email</span>
                    <input type="email" name="email" required value="<?= e((string) ($formValues['email'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>No. Telepon</span>
                    <input type="text" name="no_telp" required value="<?= e((string) ($formValues['no_telp'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Username Dashboard</span>
                    <input type="text" name="username" required value="<?= e((string) ($formValues['username'] ?? '')) ?>">
                </label>
                <?php if (!$isEdit): ?>
                    <label class="form-field">
                        <span>Password Awal</span>
                        <input type="password" name="password" minlength="8" required placeholder="Minimal 8 karakter">
                    </label>
                    <label class="form-field">
                        <span>Konfirmasi Password Awal</span>
                        <input type="password" name="password_confirmation" minlength="8" required placeholder="Ulangi password awal">
                    </label>
                <?php endif; ?>
            </div>

            <div class="card-actions">
                <button class="btn btn-primary" type="submit"><?= e($isEdit ? 'Simpan Perubahan' : 'Tambah DLH') ?></button>
                <a class="btn btn-secondary" href="<?= e(url($isEdit ? 'app/modules/admin/data_dlh_detail.php?id=' . urlencode((string) ($dlh['id'] ?? '')) : 'app/modules/admin/data_dlh.php')) ?>">Batal</a>
            </div>
        </form>
    </section>
    <?php
});
