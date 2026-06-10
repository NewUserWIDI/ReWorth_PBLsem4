<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';
require_once __DIR__ . '/../../components/badge_status.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$reward = admin_reward_by_id($id);

if ($reward === null) {
    set_flash('warning', 'Reward tidak ditemukan.');
    redirect('app/modules/admin/rewards.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    if ($action === 'toggle') {
        $result = admin_toggle_reward_status((int) $id);
        set_flash($result['success'] ? 'success' : 'danger', (string) $result['message']);
        redirect('app/modules/admin/reward_detail.php?id=' . urlencode($id));
    }

    if ($action === 'delete') {
        $result = admin_delete_reward((int) $id);
        set_flash($result['success'] ? 'success' : 'danger', (string) $result['message']);
        redirect('app/modules/admin/rewards.php');
    }
}

render_layout('Detail Reward', function () use ($reward): void {
    $isAktif = strcasecmp((string) ($reward['status_reward'] ?? ''), 'Aktif') === 0;
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Reward</h2>
                <p>Informasi lengkap item reward dan aksi pengelolaannya.</p>
            </div>
            <?php badge_status((string) ($reward['status_reward'] ?? 'Nonaktif')); ?>
        </div>

        <div class="form-grid">
            <article class="form-card">
                <p><strong>Nama Reward:</strong> <?= e((string) ($reward['nama_reward'] ?? '-')) ?></p>
                <p><strong>Jenis Reward:</strong> <?= e((string) ($reward['jenis_reward'] ?? '-')) ?></p>
                <p><strong>Provider:</strong> <?= e((string) ($reward['provider'] ?? '-')) ?></p>
                <p><strong>Nominal:</strong> <?= e((string) ($reward['nominal_reward'] ?? '-')) ?></p>
            </article>
            <article class="form-card">
                <p><strong>Poin Dibutuhkan:</strong> <?= e((string) ($reward['poin_dibutuhkan'] ?? 0)) ?></p>
                <p><strong>Status Reward:</strong> <?= e((string) ($reward['status_reward'] ?? '-')) ?></p>
                <p><strong>Dibuat Pada:</strong> <?= e(format_date($reward['created_at'] ?? null)) ?></p>
                <p><strong>Diperbarui:</strong> <?= e(format_date($reward['updated_at'] ?? null)) ?></p>
            </article>
        </div>

        <div class="card-actions" style="flex-wrap:wrap;">
            <a class="btn btn-primary" href="<?= e(url('app/modules/admin/reward_form.php?id=' . urlencode((string) ($reward['id_reward'] ?? '')))) ?>">Edit Reward</a>
            <form method="post" data-confirm="<?= e($isAktif ? 'Nonaktifkan reward ini?' : 'Aktifkan reward ini?') ?>">
                <input type="hidden" name="action" value="toggle">
                <button class="btn btn-secondary" type="submit"><?= e($isAktif ? 'Nonaktifkan' : 'Aktifkan') ?></button>
            </form>
            <form method="post" data-confirm="Hapus reward ini secara permanen?">
                <input type="hidden" name="action" value="delete">
                <button class="btn btn-danger" type="submit">Hapus Reward</button>
            </form>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/rewards.php')) ?>">Kembali</a>
        </div>
    </section>
    <?php
});
