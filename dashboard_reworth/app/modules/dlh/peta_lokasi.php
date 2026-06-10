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
    $reports = array_values(array_filter(
        $reports,
        fn (array $item): bool => in_array(
            (string) ($item['status_laporan'] ?? ''),
            ['pending', 'processing'],
            true
        )
    ));
}

$reports = array_values(array_filter(
    $reports,
    fn (array $item): bool =>
        is_numeric($item['latitude'] ?? null)
        && is_numeric($item['longitude'] ?? null)
));

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
                <select class="select" name="status">
                    <option value="">Status aktif (default)</option>
                    <option value="pending" <?= $filters['status'] === 'pending' ? 'selected' : '' ?>>Menunggu</option>
                    <option value="processing" <?= $filters['status'] === 'processing' ? 'selected' : '' ?>>Diproses</option>
                    <option value="completed" <?= $filters['status'] === 'completed' ? 'selected' : '' ?>>Selesai</option>
                    <option value="rejected" <?= $filters['status'] === 'rejected' ? 'selected' : '' ?>>Ditolak</option>
                </select>
            </div>
        </form>
    </section>

    <section class="panel map-card">
        <div class="map-toolbar">
            <div class="quick-cards">
                <article class="quick-card"><strong><?= e((string) count($reports)) ?></strong><span>Total Titik Aktif</span></article>
                <article class="quick-card">
                    <strong><?= e((string) dlh_severity_count($reports, 'Ringan')) ?></strong>
                    <span>Ringan</span>
                </article>

                <article class="quick-card">
                    <strong><?= e((string) dlh_severity_count($reports, 'Sedang')) ?></strong>
                    <span>Sedang</span>
                </article>

                <article class="quick-card">
                    <strong><?= e((string) dlh_severity_count($reports, 'Berat')) ?></strong>
                    <span>Parah</span>
                </article>
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
    <pre>
    <script>
        (function () {
            const mapNode = document.getElementById('dlh-full-map');
            if (!mapNode || typeof window.L === 'undefined') return;

            const points = <?= json_encode($markers, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?>;
            console.log('POINTS = ', points);
            const map = L.map(mapNode).setView([-7.94, 112.61], 13);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; OpenStreetMap'
            }).addTo(map);

            points.forEach((point) => {
                console.log(point);
                const tingkat = (point.tingkat || '').toLowerCase();
                const color =
                    tingkat === 'berat'
                        ? '#EF4444'
                        : tingkat === 'sedang'
                            ? '#F59E0B'
                            : '#2E7D32';
                 const icon = L.divIcon({
                    className: '',
                    html: `<div style="
                        width:18px;
                        height:18px;
                        border-radius:50%;
                        background:${color};
                        border:3px solid white;
                        box-shadow:0 0 6px rgba(0,0,0,.5);
                    "></div>`,
                    iconSize: [18, 18]
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

L.marker([point.lat, point.lng], { icon })
    .addTo(map)
    .bindPopup(popup);
            });
        })();
    </script>
    <?php
});

