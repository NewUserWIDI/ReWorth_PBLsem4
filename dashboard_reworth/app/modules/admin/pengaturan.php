<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';

require_role('admin');

$tab = $_GET['tab'] ?? 'profil_admin';
$allowed = ['profil_admin', 'profil_sistem', 'notifikasi', 'keamanan'];
if (!in_array($tab, $allowed, true)) {
    $tab = 'profil_admin';
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    set_flash('success', 'Pengaturan admin berhasil disimpan (mock).');
    redirect('app/modules/admin/pengaturan.php?tab=' . urlencode($tab));
}

render_layout('Pengaturan', function () use ($tab): void {
    ?>
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
                <a class="<?= $tab === 'notifikasi' ? 'active' : '' ?>" href="?tab=notifikasi">Notifikasi</a>
                <a class="<?= $tab === 'keamanan' ? 'active' : '' ?>" href="?tab=keamanan">Keamanan</a>
            </nav>
            <form class="form-card form-stack" method="post">
                <?php if ($tab === 'profil_admin'): ?>
                    <label class="form-field"><span>Foto Admin</span><input type="file" name="foto_admin"></label>
                    <div class="form-grid">
                        <label class="form-field"><span>Nama</span><input value="Admin Utama" name="nama_admin"></label>
                        <label class="form-field"><span>Email</span><input type="email" value="admin@reworth.app" name="email_admin"></label>
                        <label class="form-field"><span>Role</span><input value="admin" readonly></label>
                    </div>
                <?php elseif ($tab === 'profil_sistem'): ?>
                    <div class="form-grid">
                        <label class="form-field"><span>Nama Platform</span><input value="ReWorth" name="nama_platform"></label>
                        <label class="form-field"><span>Email Kontak</span><input type="email" value="support@reworth.app" name="email_kontak"></label>
                        <label class="form-field"><span>Nomor Telepon</span><input value="+62 812 0000 1111" name="telepon"></label>
                    </div>
                    <label class="form-field"><span>Logo Platform</span><input type="file" name="logo_platform"></label>
                    <label class="form-field"><span>Deskripsi Platform</span><textarea name="deskripsi">ReWorth adalah platform ekosistem pelaporan sampah dan mini market produk daur ulang.</textarea></label>
                <?php elseif ($tab === 'notifikasi'): ?>
                    <label class="form-field"><span>Notifikasi seller baru</span><select name="notif_seller"><option>Aktif</option><option>Nonaktif</option></select></label>
                    <label class="form-field"><span>Notifikasi laporan baru</span><select name="notif_laporan"><option>Aktif</option><option>Nonaktif</option></select></label>
                    <label class="form-field"><span>Notifikasi transaksi gagal</span><select name="notif_transaksi"><option>Aktif</option><option>Nonaktif</option></select></label>
                    <label class="form-field"><span>Notifikasi sistem</span><select name="notif_sistem"><option>Aktif</option><option>Nonaktif</option></select></label>
                <?php else: ?>
                    <label class="form-field"><span>Password Lama</span><input type="password" name="old_password"></label>
                    <label class="form-field"><span>Password Baru</span><input type="password" name="new_password"></label>
                    <label class="form-field"><span>Konfirmasi Password Baru</span><input type="password" name="confirm_password"></label>
                    <label class="form-field"><span>Logout Semua Sesi</span><select name="logout_all"><option>Tidak</option><option>Ya</option></select></label>
                <?php endif; ?>
                <div class="card-actions">
                    <button class="btn btn-primary" type="submit">Simpan Perubahan</button>
                </div>
            </form>
        </div>
    </section>
    <?php
});

