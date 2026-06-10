<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$isEdit = $id !== '';
$reward = $isEdit ? admin_reward_by_id($id) : null;

if ($isEdit && $reward === null) {
    set_flash('warning', 'Reward tidak ditemukan.');
    redirect('app/modules/admin/rewards.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = admin_save_reward($_POST, $isEdit ? (int) $id : null);
    set_flash($result['success'] ? 'success' : 'danger', (string) $result['message']);

    if ($result['success']) {
        redirect('app/modules/admin/reward_detail.php?id=' . urlencode((string) ($result['id'] ?? $id)));
    }
}

render_layout($isEdit ? 'Edit Reward' : 'Tambah Reward', function () use ($isEdit, $reward): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2><?= e($isEdit ? 'Edit Reward' : 'Tambah Reward Baru') ?></h2>
                <p><?= e($isEdit ? 'Perbarui data reward yang sudah ada.' : 'Tambahkan item reward baru yang bisa ditukar oleh pengguna.') ?></p>
            </div>
        </div>

        <form method="post" class="form-stack">
            <div class="form-grid">
                <label class="form-field">
                    <span>Nama Reward</span>
                    <input type="text" name="nama_reward" required value="<?= e((string) ($reward['nama_reward'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Jenis Reward</span>
                    <select name="jenis_reward" required>
                        <option value="Pulsa" <?= (($reward['jenis_reward'] ?? '') === 'Pulsa') ? 'selected' : '' ?>>Pulsa</option>
                        <option value="Kuota" <?= (($reward['jenis_reward'] ?? '') === 'Kuota') ? 'selected' : '' ?>>Kuota</option>
                    </select>
                </label>
                <label class="form-field">
                    <span>Provider</span>
                    <input type="text" name="provider" required value="<?= e((string) ($reward['provider'] ?? '')) ?>" placeholder="Contoh: Telkomsel/XL/Smartfren">
                </label>
                <label class="form-field">
                    <span>Nominal Reward</span>
                    <input type="text" name="nominal_reward" required value="<?= e((string) ($reward['nominal_reward'] ?? '')) ?>" placeholder="Contoh: Rp5.000 atau 1GB">
                </label>
                <label class="form-field">
                    <span>Poin Dibutuhkan</span>
                    <input type="number" name="poin_dibutuhkan" required min="1" value="<?= e((string) ($reward['poin_dibutuhkan'] ?? '')) ?>">
                </label>
                <label class="form-field">
                    <span>Status Reward</span>
                    <select name="status_reward" required>
                        <option value="Aktif" <?= (($reward['status_reward'] ?? 'Aktif') === 'Aktif') ? 'selected' : '' ?>>Aktif</option>
                        <option value="Nonaktif" <?= (($reward['status_reward'] ?? '') === 'Nonaktif') ? 'selected' : '' ?>>Nonaktif</option>
                    </select>
                </label>
            </div>

            <div class="card-actions">
                <button class="btn btn-primary" type="submit"><?= e($isEdit ? 'Simpan Perubahan' : 'Tambah Reward') ?></button>
                <a class="btn btn-secondary" href="<?= e(url($isEdit ? 'app/modules/admin/reward_detail.php?id=' . urlencode((string) ($reward['id_reward'] ?? '')) : 'app/modules/admin/rewards.php')) ?>">Batal</a>
            </div>
        </form>
    </section>
    <?php
});
