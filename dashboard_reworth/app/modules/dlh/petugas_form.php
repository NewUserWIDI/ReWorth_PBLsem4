<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('dlh');

$id = (string) ($_GET['id'] ?? '');
$officer = null;
foreach (mock_dlh_officers() as $item) {
    if (($item['id_petugas'] ?? '') === $id) {
        $officer = $item;
        break;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    set_flash('success', $id !== '' ? 'Data petugas berhasil diperbarui (mock).' : 'Petugas baru berhasil ditambahkan (mock).');
    redirect('app/modules/dlh/petugas.php');
}

render_layout($id !== '' ? 'Edit Petugas' : 'Tambah Petugas', function () use ($id, $officer): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2><?= $id !== '' ? 'Edit Petugas' : 'Tambah Petugas' ?></h2>
                <p>Siapkan struktur data petugas untuk integrasi Supabase.</p>
            </div>
        </div>
        <form class="form-stack" method="post">
            <div class="form-grid">
                <label class="form-field">
                    <span>Nama Petugas</span>
                    <input name="nama" required value="<?= e((string) ($officer['nama'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Nomor Telepon</span>
                    <input name="kontak" required value="<?= e((string) ($officer['kontak'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Email</span>
                    <input name="email" type="email" placeholder="opsional">
                </label>
                <label class="form-field">
                    <span>Tim</span>
                    <input name="tim" required value="<?= e((string) ($officer['tim'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Wilayah Tugas</span>
                    <input name="wilayah" required value="<?= e((string) ($officer['wilayah'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Status</span>
                    <select name="status">
                        <option value="aktif" <?= (($officer['status'] ?? 'aktif') === 'aktif') ? 'selected' : '' ?>>Aktif</option>
                        <option value="nonaktif" <?= (($officer['status'] ?? '') === 'nonaktif') ? 'selected' : '' ?>>Nonaktif</option>
                    </select>
                </label>
            </div>
            <label class="form-field">
                <span>Catatan</span>
                <textarea name="catatan" placeholder="Catatan tambahan petugas..."></textarea>
            </label>
            <div class="card-actions">
                <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/petugas.php')) ?>">Batal</a>
                <button class="btn btn-primary" type="submit"><?= $id !== '' ? 'Simpan Perubahan' : 'Simpan Petugas' ?></button>
            </div>
        </form>
    </section>
    <?php
});

