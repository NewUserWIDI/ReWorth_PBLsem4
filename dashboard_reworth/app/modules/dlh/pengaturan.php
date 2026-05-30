<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';

require_role('dlh');

$tab = $_GET['tab'] ?? 'profil';
$allowed = ['profil', 'akun', 'notifikasi', 'keamanan'];
if (!in_array($tab, $allowed, true)) {
    $tab = 'profil';
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    set_flash('success', 'Pengaturan berhasil disimpan (mock).');
    redirect('app/modules/dlh/pengaturan.php?tab=' . urlencode($tab));
}

render_layout('Pengaturan', function () use ($tab): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pengaturan</h2>
                <p>Kelola profil instansi dan preferensi sistem.</p>
            </div>
        </div>
        <div class="settings-layout">
            <nav class="settings-tabs">
                <a class="<?= $tab === 'profil' ? 'active' : '' ?>" href="?tab=profil">Profil Instansi</a>
                <a class="<?= $tab === 'akun' ? 'active' : '' ?>" href="?tab=akun">Akun</a>
                <a class="<?= $tab === 'notifikasi' ? 'active' : '' ?>" href="?tab=notifikasi">Notifikasi</a>
                <a class="<?= $tab === 'keamanan' ? 'active' : '' ?>" href="?tab=keamanan">Keamanan</a>
            </nav>

            <form method="post" class="form-card form-stack">
                <?php if ($tab === 'profil'): ?>
                    <label class="form-field"><span>Logo Instansi</span><input type="file" name="logo"></label>
                    <div class="form-grid">
                        <label class="form-field"><span>Nama Instansi</span><input name="nama_instansi" value="DLH Kota Bandung"></label>
                        <label class="form-field"><span>Email</span><input name="email" type="email" value="monitoring@dlh.reworth.app"></label>
                        <label class="form-field"><span>Telepon</span><input name="telepon" value="022-1234567"></label>
                        <label class="form-field"><span>Kota/Kabupaten</span><input name="kota" value="Bandung"></label>
                    </div>
                    <label class="form-field"><span>Alamat</span><textarea name="alamat">Jl. Wastukencana No. 2, Bandung</textarea></label>
                <?php elseif ($tab === 'akun'): ?>
                    <div class="form-grid">
                        <label class="form-field"><span>Nama Admin DLH</span><input name="nama_admin" value="Petugas DLH"></label>
                        <label class="form-field"><span>Email Login</span><input name="email_login" type="email" value="dlh@reworth.app"></label>
                        <label class="form-field"><span>Role</span><input name="role" value="DLH" readonly></label>
                    </div>
                <?php elseif ($tab === 'notifikasi'): ?>
                    <label class="form-field"><span>Notifikasi laporan baru</span><select name="notif_baru"><option>Aktif</option><option>Nonaktif</option></select></label>
                    <label class="form-field"><span>Notifikasi laporan parah</span><select name="notif_parah"><option>Aktif</option><option>Nonaktif</option></select></label>
                    <label class="form-field"><span>Batas laporan belum diproses (jam)</span><input type="number" value="6" min="1" name="sla_jam"></label>
                <?php else: ?>
                    <label class="form-field"><span>Password lama</span><input type="password" name="old_password"></label>
                    <label class="form-field"><span>Password baru</span><input type="password" name="new_password"></label>
                    <label class="form-field"><span>Konfirmasi password baru</span><input type="password" name="confirm_password"></label>
                    <label class="form-field"><span>Logout semua sesi</span><select name="logout_all"><option>Tidak</option><option>Ya</option></select></label>
                <?php endif; ?>
                <div class="card-actions">
                    <button class="btn btn-primary" type="submit">Simpan Perubahan</button>
                </div>
            </form>
        </div>
    </section>
    <?php
});

