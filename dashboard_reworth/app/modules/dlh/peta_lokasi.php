<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';

require_role('dlh');

$filters = [
    'status' => $_GET['status'] ?? '',
    'severity' => $_GET['severity'] ?? '',
    'kecamatan' => $_GET['kecamatan'] ?? '',
    'q' => $_GET['q'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
];

$reports = dlh_reports($filters);
$hasStatusFilter = trim((string) $filters['status']) !== '';
if (!$hasStatusFilter) {
    $reports = array_values(array_filter($reports, fn (array $item): bool => in_array((string) ($item['status_laporan'] ?? ''), ['menunggu', 'diproses'], true)));
}

$reports = array_values(array_filter($reports, fn (array $item): bool => is_numeric($item['latitude'] ?? null) && is_numeric($item['longitude'] ?? null)));
$reports = array_slice($reports, 0, 300);

$markers = array_map(fn (array $item): array => [
    'id' => (int) $item['id_laporan'],
    'lat' => (float) $item['latitude'],
    'lng' => (float) $item['longitude'],
    'jalan' => $item['jalan'],
    'kecamatan' => $item['kecamatan'],
    'tingkat' => $item['tingkat_keparahan'],
    'status' => $item['status_laporan'],
    'waktu' => $item['waktu_lapor'],
], $reports);

$kecamatanOptions = dlh_unique_kecamatan();

render_layout('Peta Lokasi', function () use ($filters, $kecamatanOptions, $reports, $markers): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Peta Lokasi</h2>
                <p>Lihat sebaran titik laporan sampah di wilayah kota.</p>
            </div>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e((string) $filters['q']) ?>" placeholder="Cari lokasi..." style="min-width:220px;">
                <select class="select" name="severity">
                    <option value="">Semua tingkat</option>
                    <option value="ringan" <?= $filters['severity'] === 'ringan' ? 'selected' : '' ?>>Ringan</option>
                    <option value="sedang" <?= $filters['severity'] === 'sedang' ? 'selected' : '' ?>>Sedang</option>
                    <option value="parah" <?= $filters['severity'] === 'parah' ? 'selected' : '' ?>>Parah</option>
                </select>
                <select class="select" name="kecamatan">
                    <option value="">Semua kecamatan</option>
                    <?php foreach ($kecamatanOptions as $kecamatan): ?>
                        <option value="<?= e($kecamatan) ?>" <?= $filters['kecamatan'] === $kecamatan ? 'selected' : '' ?>><?= e($kecamatan) ?></option>
                    <?php endforeach; ?>
                </select>
                <select class="select" name="status">
                    <option value="">Status aktif (default)</option>
                    <option value="menunggu" <?= $filters['status'] === 'menunggu' ? 'selected' : '' ?>>Menunggu</option>
                    <option value="diproses" <?= $filters['status'] === 'diproses' ? 'selected' : '' ?>>Diproses</option>
                    <option value="selesai" <?= $filters['status'] === 'selesai' ? 'selected' : '' ?>>Selesai</option>
                    <option value="ditolak" <?= $filters['status'] === 'ditolak' ? 'selected' : '' ?>>Ditolak</option>
                </select>
            </div>
            <div class="toolbar-right">
                <input class="input" type="date" name="date_from" value="<?= e((string) $filters['date_from']) ?>">
                <input class="input" type="date" name="date_to" value="<?= e((string) $filters['date_to']) ?>">
                <button class="btn btn-primary" type="submit">Terapkan</button>
            </div>
        </form>
    </section>

    <section class="panel map-card">
        <div class="map-toolbar">
            <div class="quick-cards">
                <article class="quick-card"><strong><?= e((string) count($reports)) ?></strong><span>Total Titik Aktif</span></article>
                <article class="quick-card"><strong><?= e((string) dlh_severity_count($reports, 'ringan')) ?></strong><span>Ringan</span></article>
                <article class="quick-card"><strong><?= e((string) dlh_severity_count($reports, 'sedang')) ?></strong><span>Sedang</span></article>
                <article class="quick-card"><strong><?= e((string) dlh_severity_count($reports, 'parah')) ?></strong><span>Parah</span></article>
            </div>
            <div class="map-legend" style="margin-top:12px;">
                <span><i class="dot dot-light"></i> Hijau = Ringan</span>
                <span><i class="dot dot-medium"></i> Oranye = Sedang</span>
                <span><i class="dot dot-high"></i> Merah = Parah</span>
            </div>
        </div>
        <div id="dlh-full-map" class="map-canvas" style="height:560px;"></div>
    </section>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="">
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <script>
        (function () {
            const mapNode = document.getElementById('dlh-full-map');
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
                const detailUrl = '<?= e(url('app/modules/dlh/laporan_detail.php?id=')) ?>' + encodeURIComponent(point.id);
                const popup = `
                    <strong>#${point.id}</strong><br>
                    ${point.jalan}<br>
                    ${point.kecamatan}<br>
                    Tingkat: ${point.tingkat}<br>
                    Status: ${point.status}<br>
                    ${point.waktu}<br>
                    <a href="${detailUrl}" style="display:inline-block;margin-top:8px;">Lihat Detail</a>
                `;
                L.marker([point.lat, point.lng], { icon }).addTo(map).bindPopup(popup);
            });
        })();
    </script>
    <?php
});

