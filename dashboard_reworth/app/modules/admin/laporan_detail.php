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
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Audit Laporan #<?= e((string) $report['id_laporan']) ?></h2>
                <p>Halaman ini untuk monitoring admin (read-only operasional).</p>
            </div>
            <div class="report-meta">
                <?php severity_badge((string) $report['tingkat_keparahan']); ?>
                <?php badge_status((string) $report['status_laporan']); ?>
            </div>
        </div>
        <div class="split-grid">
            <article class="form-card">
                <p><strong>Pelapor:</strong> <?= e((string) $report['pelapor']) ?></p>
                <p><strong>Lokasi:</strong> <?= e((string) $report['jalan']) ?>, <?= e((string) $report['kelurahan']) ?>, <?= e((string) $report['kecamatan']) ?></p>
                <p><strong>Patokan:</strong> <?= e((string) $report['patokan']) ?></p>
                <p><strong>Jenis Sampah:</strong> <?= e((string) $report['jenis_sampah']) ?></p>
                <p><strong>Deskripsi:</strong> <?= e((string) $report['deskripsi']) ?></p>
                <p><strong>Waktu Lapor:</strong> <?= e((string) $report['waktu_lapor']) ?></p>
                <p><strong>Updated:</strong> <?= e((string) $report['updated_at']) ?></p>
                <?php if ((string) $report['alasan_ditolak'] !== ''): ?>
                    <p><strong>Alasan Ditolak:</strong> <?= e((string) $report['alasan_ditolak']) ?></p>
                <?php endif; ?>
            </article>
            <article class="form-card">
                <img src="<?= e(url((string) $report['foto_sampah'])) ?>" alt="Foto laporan" style="width:100%;border-radius:14px;max-height:260px;object-fit:cover;">
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
            const lat = <?= json_encode((float) $report['latitude']) ?>;
            const lng = <?= json_encode((float) $report['longitude']) ?>;
            const map = L.map(node, { zoomControl: false }).setView([lat, lng], 15);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; OpenStreetMap'
            }).addTo(map);
            L.marker([lat, lng]).addTo(map);
        })();
    </script>
    <?php
});

