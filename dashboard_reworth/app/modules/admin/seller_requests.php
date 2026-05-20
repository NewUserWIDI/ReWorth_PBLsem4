<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('admin');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    set_flash('success', $action === 'approve' ? 'Pengajuan seller disetujui (mock).' : 'Pengajuan seller ditolak (mock).');
    redirect('dashboard.php?role=admin&page=seller_requests');
}

render_layout('Pengajuan Seller', function (): void {
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Pengajuan Pending</h2></div>
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr><th>ID</th><th>Nama Toko</th><th>Kategori</th><th>Status</th><th>Tanggal</th><th>Aksi</th></tr>
                </thead>
                <tbody>
                    <?php foreach (mock_seller_requests() as $request): ?>
                        <tr>
                            <td><?= e($request['id']) ?></td>
                            <td><?= e($request['nama']) ?></td>
                            <td><?= e($request['kategori']) ?></td>
                            <td><?php badge_status($request['status']); ?></td>
                            <td><?= e($request['tanggal']) ?></td>
                            <td class="action-row">
                                <form method="post" data-confirm="Setujui seller ini?">
                                    <input type="hidden" name="action" value="approve">
                                    <button class="btn btn-primary" type="submit">Setujui</button>
                                </form>
                                <form method="post" data-confirm="Tolak seller ini?">
                                    <input type="hidden" name="action" value="reject">
                                    <button class="btn btn-danger" type="submit">Tolak</button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
