<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';

require_role('admin');

$overview = admin_overview();
$activities = admin_activities([
    'limit' => 5,
]);
$pendingSellers = array_values(array_filter(admin_sellers([
    'status_verifikasi' => 'menunggu',
    'include_pending' => true,
]), static fn (array $seller): bool => (bool) ($seller['is_pengajuan'] ?? false)));
$pendingSellers = array_slice($pendingSellers, 0, 5);
$illustration = admin_illustration_path();

$activityTypeLabels = [
    'registrasi' => 'Registrasi',
    'transaksi' => 'Mini Market',
    'pengajuan_seller' => 'Pengajuan Seller',
    'tukar_poin' => 'Tukar Poin',
    'lapor_sampah' => 'Lapor Sampah',
    'lainnya' => 'Aktivitas',
];

render_layout('Dashboard Admin', function () use ($overview, $activities, $pendingSellers, $illustration, $activityTypeLabels): void {
    ?>
    <section class="seller-hero">
        <div class="seller-hero-content">
            <h2>Platform ReWorth Aktif</h2>
            <p>Kelola pengguna, seller, laporan sampah, transaksi, dan semua aktivitas penting platform dari satu dashboard terpusat.</p>
            <div class="hero-cta-row">
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/aktivitas.php')) ?>">Lihat Aktivitas Sistem</a>
            </div>
        </div>
        <div class="seller-hero-ellipse seller-hero-ellipse-fill" aria-hidden="true"></div>
        <div class="seller-hero-ellipse seller-hero-ellipse-ring" aria-hidden="true"></div>
        <img class="seller-hero-illustration" src="<?= e(url($illustration)) ?>" alt="Ilustrasi Admin ReWorth">
    </section>

    <div class="stat-grid stat-grid-five">
        <?php stat_card('Total User', number_format((int) $overview['total_user'], 0, ',', '.'), '+' . number_format((int) $overview['new_users_today'], 0, ',', '.') . ' hari ini'); ?>
        <?php stat_card('Total Seller', number_format((int) $overview['total_seller'], 0, ',', '.'), '+' . number_format((int) $overview['new_seller_week'], 0, ',', '.') . ' minggu ini'); ?>
        <?php stat_card('Total Laporan Sampah', number_format((int) $overview['total_laporan_sampah'], 0, ',', '.'), '+' . number_format((int) $overview['new_laporan_today'], 0, ',', '.') . ' hari ini'); ?>
        <?php stat_card('Total Transaksi', number_format((int) $overview['total_transaksi'], 0, ',', '.'), '+' . number_format((int) $overview['transaksi_week'], 0, ',', '.') . ' minggu ini'); ?>
        <?php stat_card('Pendapatan Sistem', 'Rp ' . number_format((int) $overview['total_pendapatan'], 0, ',', '.'), 'Minggu ini Rp ' . number_format((int) $overview['pendapatan_week'], 0, ',', '.')); ?>
    </div>

    <div class="two-col-grid">
        <section class="panel activity-preview-panel">
            <div class="panel-header">
                <div>
                    <h2>Aktivitas Sistem Terbaru</h2>
                    <p>Menampilkan 5 aktivitas terbaru dari registrasi, laporan, transaksi, pengajuan seller, dan penukaran poin.</p>
                </div>
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/aktivitas.php')) ?>">Detail Aktivitas</a>
            </div>

            <?php if ($activities === []): ?>
                <div class="empty-state">Belum ada aktivitas sistem terbaru.</div>
            <?php else: ?>
                <div class="activity-preview-grid">
                    <?php foreach ($activities as $activity): ?>
                        <?php $typeKey = (string) ($activity['type_key'] ?? 'lainnya'); ?>
                        <article class="activity-preview-card activity-accent-<?= e($typeKey) ?>">
                            <div class="activity-preview-top">
                                <span class="activity-type-pill activity-type-<?= e($typeKey) ?>"><?= e($activityTypeLabels[$typeKey] ?? 'Aktivitas') ?></span>
                                <span class="activity-time-stamp"><?= e((string) ($activity['waktu'] ?? '-')) ?></span>
                            </div>
                            <h3><?= e((string) ($activity['aktivitas'] ?? '-')) ?></h3>
                            <p><?= e((string) ($activity['detail'] ?? '-')) ?></p>
                            <div class="activity-preview-meta">
                                <span class="status-badge badge-info"><?= e((string) ($activity['role'] ?? 'Sistem')) ?></span>
                                <span class="status-badge badge-neutral"><?= e((string) ($activity['modul'] ?? '-')) ?></span>
                                <span class="activity-actor-text"><?= e((string) ($activity['aktor'] ?? '-')) ?></span>
                            </div>
                        </article>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </section>

        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Seller Menunggu Verifikasi</h2>
                    <p>Pengajuan terbaru yang masih perlu ditinjau admin.</p>
                </div>
            </div>
            <div class="report-list">
                <?php if ($pendingSellers === []): ?>
                    <div class="empty-state">Tidak ada seller menunggu verifikasi.</div>
                <?php else: ?>
                    <?php foreach ($pendingSellers as $seller): ?>
                        <article class="report-item seller-review-card">
                            <img class="report-thumb" src="<?= e(url('assets/logo_reworth.jpeg')) ?>" alt="Logo seller">
                            <div>
                                <h3><?= e((string) $seller['nama_toko']) ?></h3>
                                <p><?= e((string) $seller['email']) ?> | Daftar: <?= e((string) $seller['tanggal_bergabung']) ?></p>
                                <div class="report-meta">
                                    <span class="status-badge badge-warning">Menunggu</span>
                                    <span class="status-badge badge-neutral"><?= e((string) ($seller['pemilik'] ?? '-')) ?></span>
                                    <a class="btn btn-primary" href="<?= e(url('app/modules/admin/seller_detail.php?id=' . urlencode((string) $seller['id_seller']) . '&source=verification')) ?>">Tinjau</a>
                                </div>
                            </div>
                        </article>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </section>
    </div>
    <?php
});
