<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$id = (string) ($_GET['id'] ?? '');
$user = admin_user_by_id($id);
if ($user === null) {
    set_flash('warning', 'User tidak ditemukan.');
    redirect('app/modules/admin/users.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    if ($action === 'suspend') {
        set_flash('success', 'User ' . $id . ' berhasil disuspend (mock).');
    } elseif ($action === 'activate') {
        set_flash('success', 'User ' . $id . ' diaktifkan kembali (mock).');
    }
    redirect('app/modules/admin/user_detail.php?id=' . urlencode($id));
}

render_layout('Detail User', function () use ($user): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail User <?= e((string) $user['id_user']) ?></h2>
                <p>Informasi akun dan aktivitas ringkas.</p>
            </div>
            <?php badge_status((string) $user['status']); ?>
        </div>
        <div class="form-grid">
            <article class="form-card">
                <p><strong>Nama:</strong> <?= e((string) $user['nama']) ?></p>
                <p><strong>Email:</strong> <?= e((string) $user['email']) ?></p>
                <p><strong>Role:</strong> <?= e((string) $user['role']) ?></p>
                <p><strong>Tanggal Daftar:</strong> <?= e((string) $user['tanggal_bergabung']) ?></p>
            </article>
            <article class="form-card">
                <p><strong>Jumlah Laporan:</strong> <?= e((string) $user['total_laporan']) ?></p>
                <p><strong>Total Poin:</strong> <?= e((string) $user['total_poin']) ?></p>
                <p><strong>Riwayat Aktivitas:</strong> Ringkasan aktivitas user ditampilkan di sini (mock).</p>
            </article>
        </div>
        <div class="card-actions">
            <?php if (($user['status'] ?? '') === 'aktif'): ?>
                <form method="post" data-confirm="Suspend user ini?">
                    <input type="hidden" name="action" value="suspend">
                    <button class="btn btn-danger" type="submit">Suspend User</button>
                </form>
            <?php else: ?>
                <form method="post" data-confirm="Aktifkan kembali user ini?">
                    <input type="hidden" name="action" value="activate">
                    <button class="btn btn-primary" type="submit">Aktifkan Kembali</button>
                </form>
            <?php endif; ?>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/users.php')) ?>">Kembali</a>
        </div>
    </section>
    <?php
});

