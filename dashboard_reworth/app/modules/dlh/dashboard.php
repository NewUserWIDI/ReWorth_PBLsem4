<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/stat_card.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/severity_badge.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';

require_role('dlh');

$allReports = dlh_reports();
$activeReports = dlh_active_reports($allReports);
$markers = array_map(function (array $item): array {


    return [
        'id' => (int) $item['id_laporan'],
        'lat' => (float) $item['latitude'],
        'lng' => (float) $item['longitude'],
        'jalan' => $item['jalan'],
        'kecamatan' => $item['kecamatan'],
        'tingkat' => $item['tingkat_keparahan'],
        'status' => $item['status_laporan'],
        'waktu' => $item['waktu_lapor'],
    ];
}, $activeReports);

$illustration = dlh_illustration_path();

render_layout('Dashboard DLH', function () use ($allReports, $activeReports, $markers, $illustration): void {
    ?>
    <section class="seller-hero">
        <div class="seller-hero-content">
            <h2>Monitoring Lingkungan Aktif</h2>
            <p>Pantau laporan masyarakat dan tindak lanjut sampah secara real-time untuk lingkungan yang lebih bersih.</p>
            <div class="hero-cta-row">
                <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/peta_lokasi.php')) ?>">Lihat Peta Monitoring</a>
                <a class="btn btn-primary" href="<?= e(url('app/modules/dlh/laporan.php?status=menunggu')) ?>">Verifikasi Laporan</a>
            </div>
        </div>
        <div class="seller-hero-ellipse seller-hero-ellipse-fill" aria-hidden="true"></div>
        <div class="seller-hero-ellipse seller-hero-ellipse-ring" aria-hidden="true"></div>
        <img class="seller-hero-illustration" src="<?= e(url($illustration)) ?>" alt="Ilustrasi DLH ReWorth">
    </section>

    <div class="stat-grid">
    <?php stat_card('Laporan Baru', dlh_status_count($allReports, 'pending'), 'Perlu verifikasi awal'); ?>
    <?php stat_card('Diproses', dlh_status_count($allReports, 'processing'), 'Sedang ditangani petugas'); ?>
    <?php stat_card('Selesai', dlh_status_count($allReports, 'completed'), 'Sudah ditindaklanjuti'); ?>
    <?php stat_card('Titik Sampah Aktif', count($activeReports), 'Koordinat valid'); ?>
    </div>

    <div class="two-col-grid">
        <section class="panel map-card">
            <div class="map-toolbar">
                <div class="panel-header" style="margin:0;">
                    <div>
                        <h2>Peta Monitoring Ringkas</h2>
                        <p>Titik menunggu dan diproses 30 hari terakhir.</p>
                    </div>
                    <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/monitoring.php')) ?>">Buka Monitoring</a>
                </div>
            </div>
            <div id="dlh-dashboard-map" class="map-canvas"></div>
        </section>

        <section class="panel">
            <div class="panel-header"><h2>Tingkat Keparahan</h2></div>
            <div class="quick-cards">
            <article class="quick-card"><strong><?= e((string) dlh_severity_count($allReports, 'Ringan')) ?></strong><span>Ringan</span></article>
            <article class="quick-card"><strong><?= e((string) dlh_severity_count($allReports, 'Sedang')) ?></strong><span>Sedang</span></article>
            <article class="quick-card"><strong><?= e((string) dlh_severity_count($allReports, 'Berat')) ?></strong><span>Berat</span></article>
            </div>
            <div class="map-legend" style="margin-top:14px;">
                <span><i class="dot dot-light"></i> Ringan</span>
                <span><i class="dot dot-medium"></i> Sedang</span>
                <span><i class="dot dot-high"></i> Parah</span>
            </div>
        </section>
    </div>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Laporan Terbaru</h2>
                <p>Ringkasan laporan masuk dari masyarakat.</p>
            </div>
            <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/laporan.php')) ?>">Lihat Semua</a>
        </div>
        <div class="report-list">
            <?php foreach (array_slice($allReports, 0, 5) as $report): ?>
                <article class="report-item">
                    <img class="report-thumb" src="<?= e(url((string) $report['foto_sampah'])) ?>" alt="Foto laporan <?= e((string) $report['id_laporan']) ?>">
                    <div>
                        <h3>#<?= e((string) $report['id_laporan']) ?> - <?= e((string) $report['jalan']) ?></h3>
                        <p><?= e((string) $report['kelurahan']) ?>, <?= e((string) $report['kecamatan']) ?> | <?= e((string) $report['waktu_lapor']) ?></p>
                        <div class="report-meta">
                            <?php severity_badge((string) $report['tingkat_keparahan']); ?>
                            <?php badge_status((string) $report['status_laporan']); ?>
                            <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/laporan_detail.php?id=' . urlencode((string) $report['id_laporan']))) ?>">Detail</a>
                        </div>
                    </div>
                </article>
            <?php endforeach; ?>
        </div>
    </section>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="">
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <script>
        (function () {
            const mapNode = document.getElementById('dlh-dashboard-map');
            if (!mapNode || typeof window.L === 'undefined') return;

            const points = <?= json_encode($markers, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?>;
            const map = L.map(mapNode).setView([-6.92, 107.62], 12);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; OpenStreetMap'
            }).addTo(map);

            points.forEach((point) => {
                const color = point.tingkat === 'parah' ? '#EF4444' : (point.tingkat === 'sedang' ? '#F59E0B' : '#2E7D32');
                const icon = L.divIcon({
                    className: '',
                    html: `<span style="display:inline-block;width:14px;height:14px;border-radius:999px;background:${color};border:2px solid #fff;box-shadow:0 4px 10px rgba(0,0,0,.28)"></span>`,
                    iconSize: [14, 14]
                });

                const popup = `
                    <strong>#${point.id}</strong><br>
                    ${point.jalan}<br>
                    ${point.kecamatan}<br>
                    Tingkat: ${point.tingkat}<br>
                    Status: ${point.status}<br>
                    ${point.waktu}
                `;
                L.marker([point.lat, point.lng], { icon }).addTo(map).bindPopup(popup);
            });
        })();
    </script>
    <?php
});
