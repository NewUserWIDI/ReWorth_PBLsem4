<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/admin_helpers.php';
require_once __DIR__ . '/../../components/admin_management_helpers.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/stat_card.php';

require_role('admin');

$filters = [
    'q' => $_GET['q'] ?? '',
    'jenis_reward' => $_GET['jenis_reward'] ?? '',
    'status_reward' => $_GET['status_reward'] ?? '',
];

$rows = admin_rewards_list($filters);
$pagination = admin_paginate($rows, max(1, (int) ($_GET['page'] ?? 1)), 10);

$totalReward = count($rows);
$aktif = count(array_filter($rows, static fn (array $item): bool => strcasecmp((string) $item['status_reward'], 'Aktif') === 0));
$nonaktif = count(array_filter($rows, static fn (array $item): bool => strcasecmp((string) $item['status_reward'], 'Nonaktif') === 0));
$totalPoin = array_sum(array_map(static fn (array $item): int => (int) ($item['poin_dibutuhkan'] ?? 0), $rows));

render_layout('Kelola Reward', function () use ($filters, $pagination, $totalReward, $aktif, $nonaktif, $totalPoin): void {
    ?>
    <div class="stat-grid">
        <?php stat_card('Total Reward', (string) $totalReward, 'Semua item reward'); ?>
        <?php stat_card('Reward Aktif', (string) $aktif, 'Siap ditukar user'); ?>
        <?php stat_card('Reward Nonaktif', (string) $nonaktif, 'Tidak tampil ke user'); ?>
        <?php stat_card('Akumulasi Poin', (string) $totalPoin, 'Total kebutuhan poin'); ?>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Kelola Reward</h2>
                <p>Kelola item reward seperti pulsa dan kuota yang dapat ditukar pengguna.</p>
            </div>
            <a class="btn btn-primary" href="<?= e(url('app/modules/admin/reward_form.php')) ?>">Tambah Reward</a>
        </div>

        <form method="get" style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;">
            <div style="flex:2;min-width:220px;">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari nama reward, provider, atau nominal..." style="width:100%;">
            </div>
            <div style="flex:1;min-width:160px;">
                <select class="select" name="jenis_reward" style="width:100%;">
                    <option value="">Semua jenis</option>
                    <option value="Pulsa" <?= ($filters['jenis_reward'] ?? '') === 'Pulsa' ? 'selected' : '' ?>>Pulsa</option>
                    <option value="Kuota" <?= ($filters['jenis_reward'] ?? '') === 'Kuota' ? 'selected' : '' ?>>Kuota</option>
                </select>
            </div>
            <div style="flex:1;min-width:160px;">
                <select class="select" name="status_reward" style="width:100%;">
                    <option value="">Semua status</option>
                    <option value="Aktif" <?= ($filters['status_reward'] ?? '') === 'Aktif' ? 'selected' : '' ?>>Aktif</option>
                    <option value="Nonaktif" <?= ($filters['status_reward'] ?? '') === 'Nonaktif' ? 'selected' : '' ?>>Nonaktif</option>
                </select>
            </div>
            <div>
                <button class="btn btn-primary" type="submit">Filter</button>
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/rewards.php')) ?>" style="margin-left:8px;">Reset</a>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Nama Reward</th>
                        <th>Jenis</th>
                        <th>Provider</th>
                        <th>Nominal</th>
                        <th>Poin Dibutuhkan</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($pagination['items'] === []): ?>
                        <tr><td colspan="7" style="text-align:center;color:#6b7280;">Belum ada data reward.</td></tr>
                    <?php else: ?>
                        <?php foreach ($pagination['items'] as $item): ?>
                            <tr>
                                <td><?= e((string) $item['nama_reward']) ?></td>
                                <td><?= e((string) $item['jenis_reward']) ?></td>
                                <td><?= e((string) $item['provider']) ?></td>
                                <td><?= e((string) $item['nominal_reward']) ?></td>
                                <td><?= e((string) $item['poin_dibutuhkan']) ?></td>
                                <td><?php badge_status((string) $item['status_reward']); ?></td>
                                <td><a class="btn btn-secondary" href="<?= e(url('app/modules/admin/reward_detail.php?id=' . urlencode((string) $item['id_reward']))) ?>">Detail</a></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        <div class="card-actions" style="justify-content:flex-end;">
            <?php if ($pagination['page'] > 1): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] - 1]))) ?>">Prev</a>
            <?php endif; ?>
            <span class="status-badge badge-neutral">Halaman <?= e((string) $pagination['page']) ?> / <?= e((string) $pagination['total_pages']) ?></span>
            <?php if ($pagination['page'] < $pagination['total_pages']): ?>
                <a class="btn btn-secondary" href="?<?= e(http_build_query(array_merge($_GET, ['page' => $pagination['page'] + 1]))) ?>">Next</a>
            <?php endif; ?>
        </div>
    </section>
    <?php
});
