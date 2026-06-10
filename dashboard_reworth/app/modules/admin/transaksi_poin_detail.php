<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';
require_once __DIR__ . '/../../components/badge_status.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$transaksi = admin_point_redemption_by_id($id);

if ($transaksi === null) {
    set_flash('warning', 'Transaksi tukar poin tidak ditemukan.');
    redirect('app/modules/admin/transaksi_poin.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = admin_update_point_redemption_status((int) $id, $_POST);
    $flashType = $result['success'] ? (str_contains((string) $result['message'], 'belum tersimpan') ? 'info' : 'success') : 'danger';
    set_flash($flashType, (string) $result['message']);
    redirect('app/modules/admin/transaksi_poin_detail.php?id=' . urlencode($id));
}

render_layout('Detail Transaksi Tukar Poin', function () use ($transaksi): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Transaksi Tukar Poin</h2>
                <p>Perbarui status penukaran poin dan isi referensi prosesnya.</p>
            </div>
            <?php badge_status((string) ($transaksi['status_proses'] ?? 'Pending')); ?>
        </div>

        <div class="form-grid">
            <article class="form-card">
                <p><strong>ID Penukaran:</strong> #<?= e((string) ($transaksi['id_penukaran'] ?? 0)) ?></p>
                <p><strong>User:</strong> <?= e((string) ($transaksi['user']['nama'] ?? '-')) ?></p>
                <p><strong>Email:</strong> <?= e((string) ($transaksi['user']['email'] ?? '-')) ?></p>
                <p><strong>No. Telepon User:</strong> <?= e((string) ($transaksi['user']['no_telp'] ?? '-')) ?></p>
                <p><strong>Nomor Tujuan Reward:</strong> <?= e((string) ($transaksi['no_hp_tujuan'] ?? '-')) ?></p>
            </article>
            <article class="form-card">
                <p><strong>Reward:</strong> <?= e((string) ($transaksi['reward']['nama_reward'] ?? '-')) ?></p>
                <p><strong>Jenis:</strong> <?= e((string) ($transaksi['reward']['jenis_reward'] ?? '-')) ?></p>
                <p><strong>Provider:</strong> <?= e((string) ($transaksi['reward']['provider'] ?? '-')) ?></p>
                <p><strong>Nominal:</strong> <?= e((string) ($transaksi['reward']['nominal_reward'] ?? '-')) ?></p>
                <p><strong>Poin Terpakai:</strong> <?= e((string) ($transaksi['poin_terpakai'] ?? 0)) ?></p>
                <p><strong>Kode Referensi Saat Ini:</strong> <?= e((string) (($transaksi['kode_referensi'] ?? '') !== '' ? $transaksi['kode_referensi'] : '-')) ?></p>
                <p><strong>Tanggal Penukaran:</strong> <?= e((string) ($transaksi['tanggal_penukaran'] ?? '-')) ?></p>
                <p><strong>Tanggal Diproses:</strong> <?= e((string) ($transaksi['tanggal_diproses'] ?? '-')) ?></p>
            </article>
        </div>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Update Status</h2>
                <p>Jika status `Sukses`, isi kode referensi. Jika `Gagal`, isi alasan kegagalan.</p>
            </div>
        </div>

        <form method="post" class="form-stack">
            <div class="form-grid">
                <label class="form-field">
                    <span>Status Proses</span>
                    <select name="status_proses" required>
                        <option value="Sukses" <?= (($transaksi['status_proses'] ?? '') === 'Sukses') ? 'selected' : '' ?>>Sukses</option>
                        <option value="Gagal" <?= (($transaksi['status_proses'] ?? '') === 'Gagal') ? 'selected' : '' ?>>Gagal</option>
                    </select>
                </label>
                <label class="form-field">
                    <span>Kode Referensi</span>
                    <input type="text" name="kode_referensi" value="<?= e((string) ($transaksi['kode_referensi'] ?? '')) ?>" placeholder="Wajib saat status sukses">
                </label>
            </div>

            <label class="form-field">
                <span>Alasan Gagal</span>
                <textarea name="alasan_gagal" rows="4" placeholder="Wajib saat status gagal. Jika kolom database belum tersedia, sistem akan tetap menyimpan perubahan statusnya."><?= e((string) ($transaksi['alasan_gagal'] ?? '')) ?></textarea>
            </label>

            <div class="card-actions">
                <button class="btn btn-primary" type="submit">Simpan Status</button>
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/transaksi_poin.php')) ?>">Kembali</a>
            </div>
        </form>
    </section>
    <?php
});
