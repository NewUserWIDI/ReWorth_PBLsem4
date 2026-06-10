<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$dlh = admin_dlh_by_id($id);

if ($dlh === null) {
    set_flash('warning', 'Data DLH tidak ditemukan.');
    redirect('app/modules/admin/data_dlh.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = admin_reset_dlh_password($id, (string) ($_POST['new_password'] ?? ''));
    set_flash($result['success'] ? 'success' : 'danger', (string) $result['message']);
    redirect('app/modules/admin/data_dlh_detail.php?id=' . urlencode($id));
}

render_layout('Detail DLH', function () use ($dlh): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail DLH</h2>
                <p>Informasi profil petugas DLH dan reset password akun dashboard.</p>
            </div>
            <span class="status-badge badge-success">Akun Aktif</span>
        </div>

        <div class="form-grid">
            <article class="form-card">
                <p><strong>Nama Lengkap:</strong> <?= e((string) $dlh['nama']) ?></p>
                <p><strong>Email:</strong> <?= e((string) $dlh['email']) ?></p>
                <p><strong>No. Telepon:</strong> <?= e((string) $dlh['no_telp']) ?></p>
                <p><strong>Username Dashboard:</strong> <?= e((string) (($dlh['username'] ?? '') !== '' ? $dlh['username'] : '-')) ?></p>
                <p><strong>Tanggal Bergabung:</strong> <?= e((string) $dlh['tanggal_bergabung']) ?></p>
            </article>
            <article class="form-card">
                <h3 style="margin-top:0;">Reset Password</h3>
                <p style="color:#6b7280;margin-top:0;">Masukkan password baru untuk akun dashboard DLH.</p>
                <form method="post" data-confirm="Reset password akun DLH ini?">
                    <label class="form-field">
                        <span>Password Baru</span>
                        <input type="password" name="new_password" minlength="8" required placeholder="Minimal 8 karakter">
                    </label>
                    <div class="card-actions">
                        <button class="btn btn-primary" type="submit">Reset Password</button>
                    </div>
                </form>
            </article>
        </div>

        <div class="card-actions">
            <a class="btn btn-primary" href="<?= e(url('app/modules/admin/data_dlh_form.php?id=' . urlencode((string) $dlh['id']))) ?>">Edit Profil</a>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/data_dlh.php')) ?>">Kembali</a>
        </div>
    </section>
    <?php
});
