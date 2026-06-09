<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/severity_badge.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';

require_role('admin');

$id = (int) ($_GET['id'] ?? 0);
$report = dlh_report_by_id($id);
if ($report === null) {
    set_flash('warning', 'Detail laporan tidak ditemukan.');
    redirect('app/modules/admin/laporan_sampah.php');
}

render_layout('Detail Laporan', function () use ($report): void {
    // Ambil data dengan aman menggunakan null coalescing
    $idLaporan = $report['id_laporan'] ?? '-';
    $namaPelapor = $report['nama_pelapor'] ?? '-';
    $jalan = $report['jalan'] ?? '-';
    $kelurahan = $report['kelurahan'] ?? '-';
    $kecamatan = $report['kecamatan'] ?? '-';
    $patokan = $report['patokan'] ?? '-';
    $jenisSampah = $report['jenis_sampah'] ?? '-';
    $deskripsi = $report['deskripsi'] ?? '-';
    $waktuLapor = $report['waktu_lapor'] ?? '-';
    $updatedAt = $report['updated_at'] ?? $report['waktu_lapor'] ?? '-';
    $alasanDitolak = $report['alasan_ditolak'] ?? '';
    $fotoSampah = $report['foto_sampah'] ?? '';
    $latitude = (float) ($report['latitude'] ?? 0);
    $longitude = (float) ($report['longitude'] ?? 0);
    $tingkatKeparahan = $report['tingkat_keparahan'] ?? '';
    $statusLaporan = $report['status_laporan'] ?? '';
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Audit Laporan <?= e((string) $idLaporan) ?></h2>
                <p>Halaman ini untuk monitoring admin (read-only operasional).</p>
            </div>
            <div class="report-meta">
                <?php severity_badge((string) $tingkatKeparahan); ?>
                <?php badge_status((string) $statusLaporan); ?>
            </div>
        </div>
        <div class="split-grid">
            <article class="form-card">
                <p><strong>Pelapor:</strong> <?= e($namaPelapor) ?></p>
                <p><strong>Lokasi:</strong> <?= e($jalan) ?>, <?= e($kelurahan) ?>, <?= e($kecamatan) ?></p>
                <p><strong>Patokan:</strong> <?= e($patokan) ?></p>
                <p><strong>Jenis Sampah:</strong> <?= e($jenisSampah) ?></p>
                <p><strong>Deskripsi:</strong> <?= e($deskripsi) ?></p>
                <p><strong>Waktu Lapor:</strong> <?= e($waktuLapor) ?></p>
                <p><strong>Updated:</strong> <?= e($updatedAt) ?></p>
                <?php if (!empty($alasanDitolak)): ?>
                    <p><strong>Alasan Ditolak:</strong> <?= e($alasanDitolak) ?></p>
                <?php endif; ?>
            </article>
            <article class="form-card">
                <?php if (!empty($fotoSampah)): ?>
                    <img src="<?= e($fotoSampah) ?>" alt="Foto laporan" style="width:100%;border-radius:14px;max-height:260px;object-fit:cover;">
                <?php else: ?>
                    <div style="width:100%;border-radius:14px;height:200px;background:#f3f4f6;display:flex;align-items:center;justify-content:center;color:#6b7280;">
                        📷 Tidak ada foto
                    </div>
                <?php endif; ?>
                <div id="admin-laporan-map" class="map-canvas" style="height:220px;border-radius:14px;margin-top:12px;"></div>
            </article>
        </div>
    </section>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="">
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <script>
        (function () {
            const node = document.getElementById('admin-laporan-map');
            if (!node || typeof window.L === 'undefined') return;
            const lat = <?= json_encode($latitude) ?>;
            const lng = <?= json_encode($longitude) ?>;
            
            if (lat && lng && lat !== 0 && lng !== 0) {
                const map = L.map(node, { zoomControl: false }).setView([lat, lng], 15);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    maxZoom: 19,
                    attribution: '&copy; OpenStreetMap'
                }).addTo(map);
                L.marker([lat, lng]).addTo(map);
            } else {
                node.innerHTML = '<div style="height:100%;display:flex;align-items:center;justify-content:center;color:#6b7280;">🗺️ Koordinat tidak tersedia</div>';
            }
        })();
    </script>
    <?php
});