<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_helpers.php';

require_role('admin');

$overview = mock_admin_overview();
$activities = admin_activities();
$pendingSellers = array_values(array_filter(admin_sellers(), fn (array $item): bool => ($item['status_verifikasi'] ?? '') === 'menunggu'));
$illustration = admin_illustration_path();

render_layout('Dashboard Admin', function () use ($overview, $activities, $pendingSellers, $illustration): void {
    ?>
    <section class="seller-hero">
        <div class="seller-hero-content">
            <h2>Platform ReWorth Aktif</h2>
            <p>Kelola pengguna, seller, laporan sampah, transaksi, dan aktivitas platform dalam satu dashboard terpusat.</p>
            <div class="hero-cta-row">
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/aktivitas.php')) ?>">Lihat Aktivitas Sistem</a>
            </div>
        </div>
        <div class="seller-hero-ellipse seller-hero-ellipse-fill" aria-hidden="true"></div>
        <div class="seller-hero-ellipse seller-hero-ellipse-ring" aria-hidden="true"></div>
        <img class="seller-hero-illustration" src="<?= e(url($illustration)) ?>" alt="Ilustrasi Admin ReWorth">
    </section>

    <div class="stat-grid stat-grid-five">
        <?php stat_card('Total User', number_format((int) $overview['total_user'], 0, ',', '.'), '+18 hari ini'); ?>
        <?php stat_card('Total Seller', number_format((int) $overview['total_seller'], 0, ',', '.'), '+6 minggu ini'); ?>
        <?php stat_card('Total Laporan Sampah', number_format((int) $overview['total_laporan_sampah'], 0, ',', '.'), '+12 hari ini'); ?>
        <?php stat_card('Total Transaksi', number_format((int) $overview['total_transaksi'], 0, ',', '.'), '+7% minggu ini'); ?>
        <?php stat_card('Total Pendapatan', 'Rp ' . number_format((int) $overview['total_pendapatan'], 0, ',', '.'), 'Nilai transaksi platform'); ?>
    </div>

    <div class="two-col-grid">
        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Aktivitas Sistem Terbaru</h2>
                    <p>Audit trail aktivitas penting platform.</p>
                </div>
                <a class="btn btn-secondary" href="<?= e(url('app/modules/admin/aktivitas.php')) ?>">Lihat Semua</a>
            </div>
            <div class="report-list">
                <?php foreach (array_slice($activities, 0, 6) as $activity): ?>
                    <article class="report-item" style="grid-template-columns:minmax(0,1fr);">
                        <div>
                            <h3><?= e((string) $activity['aktivitas']) ?> - <?= e((string) $activity['aktor']) ?></h3>
                            <p><?= e((string) $activity['detail']) ?></p>
                            <div class="report-meta">
                                <span class="status-badge badge-info"><?= e((string) $activity['role']) ?></span>
                                <span class="status-badge badge-neutral"><?= e((string) $activity['modul']) ?></span>
                                <span class="status-badge badge-neutral"><?= e((string) $activity['waktu']) ?></span>
                            </div>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        </section>

        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2>Seller Menunggu Verifikasi</h2>
                    <p>Validasi pengajuan seller baru.</p>
                </div>
            </div>
            <div class="report-list">
                <?php if ($pendingSellers === []): ?>
                    <div class="empty-state">Tidak ada seller menunggu verifikasi.</div>
                <?php else: ?>
                    <?php foreach ($pendingSellers as $seller): ?>
                        <article class="report-item">
                            <img class="report-thumb" src="<?= e(url('assets/logo_reworth.jpeg')) ?>" alt="Logo seller">
                            <div>
                                <h3><?= e((string) $seller['nama_toko']) ?></h3>
                                <p><?= e((string) $seller['email']) ?> | Daftar: <?= e((string) $seller['tanggal_bergabung']) ?></p>
                                <div class="report-meta">
                                    <span class="status-badge badge-warning">Menunggu</span>
                                    <a class="btn btn-primary" href="<?= e(url('app/modules/admin/seller_detail.php?id=' . urlencode((string) $seller['id_seller']))) ?>">Verifikasi</a>
                                    <a class="btn btn-danger" href="<?= e(url('app/modules/admin/seller_detail.php?id=' . urlencode((string) $seller['id_seller']))) ?>">Tolak</a>
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
