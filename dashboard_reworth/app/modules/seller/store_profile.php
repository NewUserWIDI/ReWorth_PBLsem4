<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$activeTab = $_GET['tab'] ?? 'profil';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = seller_update_store_profile($sellerUserId, $activeTab, $_POST, $_FILES);
    set_flash((string) ($result['type'] ?? 'success'), (string) ($result['message'] ?? 'Perubahan disimpan.'));
    redirect('app/modules/seller/store_profile.php?tab=' . urlencode($activeTab));
}

$profile = seller_fetch_profile($sellerUserId);
if ($profile === null) {
    set_flash('warning', 'Profil seller tidak ditemukan.');
    redirect('app/modules/seller/dashboard.php');
}

render_layout('Pengaturan Toko', function () use ($activeTab, $profile): void {
    $tabs = [
        'profil' => 'Profil Toko',
        'alamat' => 'Alamat Toko',
        'rekening' => 'Rekening Bank',
        'pengiriman' => 'Pengiriman',
    ];
    $canSave = in_array($activeTab, ['profil', 'alamat'], true);
    ?>
    <div class="settings-layout">
        <nav class="settings-tabs">
            <?php foreach ($tabs as $key => $label): ?>
                <a class="<?= $activeTab === $key ? 'active' : '' ?>" href="<?= e(url('app/modules/seller/store_profile.php?tab=' . $key)) ?>"><?= e($label) ?></a>
            <?php endforeach; ?>
        </nav>

        <form class="form-stack" method="post" enctype="multipart/form-data">
            <?php if ($activeTab === 'profil'): ?>
                <section class="form-card">
                    <div class="panel-header"><h2>Profil Toko</h2></div>
                    <?php if (($profile['foto_toko'] ?? '') !== ''): ?>
                        <div class="product-card-media" style="height:180px;margin-bottom:16px;padding:0;overflow:hidden;">
                            <img src="<?= e((string) $profile['foto_toko']) ?>" alt="Foto toko" style="width:100%;height:100%;object-fit:cover;">
                        </div>
                    <?php endif; ?>
                    <div class="form-grid">
                        <label class="form-field"><span>Logo / Foto Toko</span><input type="file" name="logo" accept="image/*"></label>
                        <label class="form-field"><span>Nama Toko</span><input name="nama_toko" value="<?= e((string) $profile['nama_toko']) ?>" required></label>
                        <label class="form-field"><span>Email Toko</span><input type="email" name="email" value="<?= e((string) $profile['email']) ?>"></label>
                        <label class="form-field"><span>Nomor Telepon</span><input name="telepon" value="<?= e((string) $profile['no_telp']) ?>"></label>
                    </div>
                    <label class="form-field" style="margin-top: 16px;"><span>Deskripsi Toko</span><textarea name="deskripsi"><?= e((string) $profile['deskripsi_toko']) ?></textarea></label>
                    <div class="form-grid" style="margin-top:16px;">
                        <label class="form-field"><span>Username Dashboard</span><input value="<?= e((string) $profile['username_dashboard']) ?>" disabled></label>
                        <label class="form-field"><span>Status Verifikasi</span><input value="<?= e(status_label((string) $profile['status_verifikasi'])) ?>" disabled></label>
                    </div>
                </section>
            <?php elseif ($activeTab === 'alamat'): ?>
                <section class="form-card">
                    <div class="panel-header">
                        <div>
                            <h2>Alamat Toko</h2>
                            <p>Schema seller saat ini menyimpan alamat toko dalam satu field `alamat_toko`.</p>
                        </div>
                    </div>
                    <label class="form-field">
                        <span>Alamat Lengkap Toko</span>
                        <textarea name="alamat_toko" required placeholder="Tulis alamat lengkap toko di sini."><?= e((string) $profile['alamat_toko']) ?></textarea>
                    </label>
                </section>
            <?php elseif ($activeTab === 'rekening'): ?>
                <section class="form-card">
                    <div class="panel-header">
                        <div>
                            <h2>Rekening Bank</h2>
                            <p>Belum ada tabel khusus rekening seller pada schema saat ini.</p>
                        </div>
                    </div>
                    <div class="empty-state">Bagian ini akan mengikuti schema database berikutnya.</div>
                </section>
            <?php else: ?>
                <section class="form-card">
                    <div class="panel-header">
                        <div>
                            <h2>Pengiriman</h2>
                            <p>Belum ada tabel pengaturan pengiriman seller pada schema saat ini.</p>
                        </div>
                    </div>
                    <div class="empty-state">Bagian ini akan mengikuti schema database berikutnya.</div>
                </section>
            <?php endif; ?>

            <?php if ($canSave): ?>
                <div class="toolbar">
                    <span></span>
                    <button class="btn btn-primary" type="submit">Simpan Perubahan</button>
                </div>
            <?php endif; ?>
        </form>
    </div>
    <?php
});
