<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';

require_active_seller();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    set_flash('success', 'Pengaturan toko berhasil disimpan (mock).');
    redirect('app/modules/seller/store_profile.php');
}

render_layout('Pengaturan Toko', function (): void {
    $activeTab = $_GET['tab'] ?? 'profil';
    $tabs = [
        'profil' => 'Profil Toko',
        'alamat' => 'Alamat Toko',
        'rekening' => 'Rekening Bank',
        'pengiriman' => 'Pengiriman',
    ];
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
                    <div class="form-grid">
                        <label class="form-field"><span>Logo Toko</span><input type="file" name="logo" accept="image/*"></label>
                        <label class="form-field"><span>Nama Toko</span><input name="nama_toko" value="Eco Craft" required></label>
                        <label class="form-field"><span>Email Toko</span><input type="email" name="email" value="seller@reworth.app"></label>
                        <label class="form-field"><span>Nomor Telepon</span><input name="telepon" value="08xxxxxxxxxx"></label>
                    </div>
                    <label class="form-field" style="margin-top: 16px;"><span>Deskripsi Toko</span><textarea name="deskripsi">Menjual produk ramah lingkungan dari material daur ulang.</textarea></label>
                </section>
            <?php elseif ($activeTab === 'alamat'): ?>
                <section class="form-card">
                    <div class="panel-header"><h2>Alamat Toko</h2></div>
                    <div class="form-grid">
                        <label class="form-field"><span>Jalan / Alamat Lengkap</span><input name="jalan" required></label>
                        <label class="form-field"><span>Kelurahan</span><input name="kelurahan"></label>
                        <label class="form-field"><span>Kecamatan</span><input name="kecamatan" required></label>
                        <label class="form-field"><span>Kota/Kabupaten</span><input name="kota"></label>
                        <label class="form-field"><span>Provinsi</span><input name="provinsi"></label>
                        <label class="form-field"><span>Kode Pos</span><input name="kode_pos"></label>
                    </div>
                    <label class="form-field" style="margin-top: 16px;"><span>Patokan</span><textarea name="patokan"></textarea></label>
                </section>
            <?php elseif ($activeTab === 'rekening'): ?>
                <section class="form-card">
                    <div class="panel-header">
                        <div>
                            <h2>Rekening Bank</h2>
                            <p>Maksimal 3 rekening aktif per seller.</p>
                        </div>
                    </div>
                    <div class="form-grid">
                        <label class="form-field"><span>Nama Bank</span><input name="nama_bank" required></label>
                        <label class="form-field"><span>Nama Pemilik Rekening</span><input name="nama_pemilik" required></label>
                        <label class="form-field"><span>Nomor Rekening</span><input name="nomor_rekening" required></label>
                        <label class="form-field"><span>Label Rekening</span><input name="label" placeholder="Utama / Operasional"></label>
                    </div>
                </section>
            <?php else: ?>
                <section class="form-card">
                    <div class="panel-header"><h2>Pengiriman</h2></div>
                    <div class="form-grid">
                        <label class="form-field"><span>Opsi Pengiriman</span><select name="opsi"><option>Standard</option><option>Instant Lokal</option><option>COD Lokal</option></select></label>
                        <label class="form-field"><span>Estimasi Proses</span><input name="estimasi" placeholder="1-2 hari"></label>
                    </div>
                    <label class="form-field" style="margin-top: 16px;"><span>Catatan Pengiriman</span><textarea name="catatan" placeholder="Instruksi packing, jadwal kirim, atau batas area layanan."></textarea></label>
                </section>
            <?php endif; ?>

            <div class="toolbar">
                <span></span>
                <button class="btn btn-primary" type="submit">Simpan Perubahan</button>
            </div>
        </form>
    </div>
    <?php
});
