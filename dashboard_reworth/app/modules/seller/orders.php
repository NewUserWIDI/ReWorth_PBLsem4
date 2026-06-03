<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/seller_helpers.php';

require_active_seller();

$user = current_user() ?? [];
$sellerUserId = (string) ($user['seller_user_id'] ?? $user['user_id'] ?? '');
$filters = [
    'status' => $_GET['status'] ?? '',
    'q' => $_GET['q'] ?? '',
];
$orders = seller_fetch_order_summaries($sellerUserId, $filters);
$tabs = ['semua' => 'Semua', 'diproses' => 'Diproses', 'dikemas' => 'Dikemas', 'dikirim' => 'Dikirim', 'selesai' => 'Selesai', 'dibatalkan' => 'Dibatalkan'];

render_layout('Pesanan', function () use ($orders, $tabs, $filters): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pesanan</h2>
                <p>Kelola semua pesanan toko Anda.</p>
            </div>
        </div>
        <form class="toolbar" method="get" style="margin-bottom: 18px;">
            <div class="tabs">
                <?php foreach ($tabs as $value => $label): ?>
                    <a class="tab <?= (($filters['status'] ?: 'semua') === $value) ? 'active' : '' ?>" href="?<?= e(http_build_query(['status' => $value, 'q' => $filters['q']])) ?>"><?= e($label) ?></a>
                <?php endforeach; ?>
            </div>
            <input class="input" style="width: 280px;" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari ID pesanan atau pembeli">
            <input type="hidden" name="status" value="<?= e((string) ($filters['status'] ?: 'semua')) ?>">
        </form>
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>ID Pesanan</th><th>Pembeli</th><th>Tanggal</th><th>Status</th><th>Net Seller</th><th>Aksi</th></tr></thead>
                <tbody>
                    <?php if ($orders === []): ?>
                        <tr><td colspan="6" style="text-align:center;color:#6b7280;">Belum ada pesanan yang cocok.</td></tr>
                    <?php else: ?>
                        <?php foreach ($orders as $order): ?>
                            <tr>
                                <td><?= e((string) $order['kode_pesanan']) ?></td>
                                <td><?= e((string) $order['pembeli']) ?></td>
                                <td><?= e(substr((string) $order['tanggal'], 0, 10)) ?></td>
                                <td><?php badge_status((string) $order['status_pesanan']); ?></td>
                                <td>Rp <?= e(number_format((int) $order['total'], 0, ',', '.')) ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/seller/order_detail.php?id=' . urlencode((string) $order['id_pesanan']))) ?>">Lihat Detail</a></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});
