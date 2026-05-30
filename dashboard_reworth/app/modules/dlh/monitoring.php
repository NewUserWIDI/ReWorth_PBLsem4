<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/severity_badge.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';

require_role('dlh');

$filters = [
    'severity' => $_GET['severity'] ?? '',
    'status' => $_GET['status'] ?? '',
    'kecamatan' => $_GET['kecamatan'] ?? '',
    'q' => $_GET['q'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
];

$reports = dlh_active_reports(dlh_reports($filters));
$markers = array_map(fn (array $item): array => [
    'id' => (int) $item['id_laporan'],
    'lat' => (float) $item['latitude'],
    'lng' => (float) $item['longitude'],
    'jalan' => $item['jalan'],
    'kecamatan' => $item['kecamatan'],
    'tingkat' => $item['tingkat_keparahan'],
    'status' => $item['status_laporan'],
], $reports);

$kecamatanOptions = dlh_unique_kecamatan();

render_layout('Monitoring', function () use ($filters, $reports, $markers, $kecamatanOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Monitoring</h2>
                <p>Pantau laporan dan kondisi lingkungan secara real-time.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari lokasi atau ID laporan..." style="min-width:260px;">
                <select class="select" name="severity">
                    <option value="">Semua tingkat</option>
                    <option value="ringan" <?= $filters['severity'] === 'ringan' ? 'selected' : '' ?>>Ringan</option>
                    <option value="sedang" <?= $filters['severity'] === 'sedang' ? 'selected' : '' ?>>Sedang</option>
                    <option value="parah" <?= $filters['severity'] === 'parah' ? 'selected' : '' ?>>Parah</option>
                </select>
                <select class="select" name="status">
                    <option value="">Semua status</option>
                    <option value="menunggu" <?= $filters['status'] === 'menunggu' ? 'selected' : '' ?>>Menunggu</option>
                    <option value="diproses" <?= $filters['status'] === 'diproses' ? 'selected' : '' ?>>Diproses</option>
                </select>
                <select class="select" name="kecamatan">
                    <option value="">Semua kecamatan</option>
                    <?php foreach ($kecamatanOptions as $kecamatan): ?>
                        <option value="<?= e($kecamatan) ?>" <?= $filters['kecamatan'] === $kecamatan ? 'selected' : '' ?>><?= e($kecamatan) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="toolbar-right">
                <input class="input" type="date" name="date_from" value="<?= e((string) $filters['date_from']) ?>">
                <input class="input" type="date" name="date_to" value="<?= e((string) $filters['date_to']) ?>">
                <button class="btn btn-primary" type="submit">Terapkan</button>
            </div>
        </form>
    </section>

    <div class="split-grid">
        <section class="panel map-card">
            <div class="map-toolbar">
                <div class="map-legend">
                    <span><i class="dot dot-light"></i> Ringan</span>
                    <span><i class="dot dot-medium"></i> Sedang</span>
                    <span><i class="dot dot-high"></i> Parah</span>
                </div>
            </div>
            <div id="dlh-monitoring-map" class="map-canvas"></div>
        </section>

        <section class="panel">
            <div class="panel-header">
                <h2>Laporan Aktif</h2>
                <span class="status-badge badge-info"><?= e((string) count($reports)) ?> titik</span>
            </div>
            <div class="report-list">
                <?php if ($reports === []): ?>
                    <div class="empty-state">Tidak ada laporan aktif untuk filter saat ini.</div>
                <?php else: ?>
                    <?php foreach ($reports as $report): ?>
                        <article class="report-item">
                            <img class="report-thumb" src="<?= e(url((string) $report['foto_sampah'])) ?>" alt="Foto laporan">
                            <div>
                                <h3>#<?= e((string) $report['id_laporan']) ?> - <?= e((string) $report['jalan']) ?></h3>
                                <p><?= e((string) $report['kecamatan']) ?> | <?= e((string) $report['waktu_lapor']) ?></p>
                                <div class="report-meta">
                                    <?php severity_badge((string) $report['tingkat_keparahan']); ?>
                                    <?php badge_status((string) $report['status_laporan']); ?>
                                    <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/laporan_detail.php?id=' . urlencode((string) $report['id_laporan']))) ?>">Lihat</a>
                                </div>
                            </div>
                        </article>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </section>
    </div>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="">
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <script>
        (function () {
            const mapNode = document.getElementById('dlh-monitoring-map');
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
                L.marker([point.lat, point.lng], { icon }).addTo(map).bindPopup(
                    `<strong>#${point.id}</strong><br>${point.jalan}<br>${point.kecamatan}<br>${point.tingkat} - ${point.status}`
                );
            });
        })();
    </script>
    <?php
});

