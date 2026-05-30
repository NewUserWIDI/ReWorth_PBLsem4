<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/severity_badge.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';

require_role('dlh');

$id = (int) ($_GET['id'] ?? 0);
$report = dlh_report_by_id($id) ?? dlh_reports()[0] ?? null;
if ($report === null) {
    set_flash('warning', 'Data laporan tidak ditemukan.');
    redirect('app/modules/dlh/laporan.php');
}

render_layout('Detail Laporan', function () use ($report): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Detail Laporan #<?= e((string) $report['id_laporan']) ?></h2>
                <p><?= e((string) $report['waktu_lapor']) ?> | Pelapor: <?= e((string) $report['pelapor']) ?></p>
            </div>
            <div class="report-meta">
                <?php severity_badge((string) $report['tingkat_keparahan']); ?>
                <?php badge_status((string) $report['status_laporan']); ?>
            </div>
        </div>

        <div class="split-grid">
            <div class="form-stack">
                <article class="form-card">
                    <div class="panel-header"><h2>Informasi Lokasi</h2></div>
                    <p><strong>Jalan:</strong> <?= e((string) $report['jalan']) ?></p>
                    <p><strong>Kelurahan:</strong> <?= e((string) $report['kelurahan']) ?></p>
                    <p><strong>Kecamatan:</strong> <?= e((string) $report['kecamatan']) ?></p>
                    <p><strong>Patokan:</strong> <?= e((string) $report['patokan']) ?></p>
                    <p><strong>Koordinat:</strong> <?= e((string) $report['latitude']) ?>, <?= e((string) $report['longitude']) ?></p>
                </article>

                <article class="form-card">
                    <div class="panel-header"><h2>Informasi Laporan</h2></div>
                    <p><strong>Jenis Sampah:</strong> <?= e(ucfirst((string) $report['jenis_sampah'])) ?></p>
                    <p><strong>Deskripsi:</strong> <?= e((string) $report['deskripsi']) ?></p>
                    <?php if ((string) $report['alasan_ditolak'] !== ''): ?>
                        <p><strong>Alasan Ditolak:</strong> <?= e((string) $report['alasan_ditolak']) ?></p>
                    <?php endif; ?>
                </article>
            </div>

            <div class="form-stack">
                <article class="form-card">
                    <div class="panel-header"><h2>Foto Laporan</h2></div>
                    <img src="<?= e(url((string) $report['foto_sampah'])) ?>" alt="Foto laporan" style="width:100%;border-radius:14px;max-height:260px;object-fit:cover;">
                </article>
                <article class="form-card">
                    <div class="panel-header"><h2>Titik Lokasi</h2></div>
                    <div id="dlh-detail-map" class="map-canvas" style="height:220px;border-radius:14px;"></div>
                </article>

                <article class="form-card">
                    <div class="panel-header"><h2>Aksi Verifikasi</h2></div>
                    <form class="action-row" method="post" action="<?= e(url('app/modules/dlh/verification_action.php')) ?>" data-confirm="Terima laporan ini dan ubah status ke diproses?">
                        <input type="hidden" name="id_laporan" value="<?= e((string) $report['id_laporan']) ?>">
                        <input type="hidden" name="action" value="accept">
                        <button class="btn btn-primary" type="submit">Verifikasi / Terima</button>
                    </form>
                    <hr style="border:none;border-top:1px solid #e5e7eb;margin:14px 0;">
                    <form class="reject-form" method="post" action="<?= e(url('app/modules/dlh/verification_action.php')) ?>" data-confirm="Tolak laporan ini?">
                        <input type="hidden" name="id_laporan" value="<?= e((string) $report['id_laporan']) ?>">
                        <input type="hidden" name="action" value="reject">
                        <label class="form-field">
                            <span>Alasan Penolakan (minimal 10 karakter)</span>
                            <textarea name="alasan_ditolak" required minlength="10" placeholder="Contoh: Foto tidak jelas, lokasi tidak valid, atau laporan duplikat."></textarea>
                        </label>
                        <button class="btn btn-danger" type="submit">Tolak Laporan</button>
                    </form>
                    <hr style="border:none;border-top:1px solid #e5e7eb;margin:14px 0;">
                    <form class="action-row" method="post" action="<?= e(url('app/modules/dlh/verification_action.php')) ?>" data-confirm="Tandai laporan ini selesai?">
                        <input type="hidden" name="id_laporan" value="<?= e((string) $report['id_laporan']) ?>">
                        <input type="hidden" name="action" value="finish">
                        <button class="btn btn-secondary" type="submit">Update ke Selesai</button>
                    </form>
                </article>
            </div>
        </div>
    </section>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="">
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <script>
        (function () {
            const mapNode = document.getElementById('dlh-detail-map');
            if (!mapNode || typeof window.L === 'undefined') return;

            const lat = <?= json_encode((float) $report['latitude']) ?>;
            const lng = <?= json_encode((float) $report['longitude']) ?>;
            const map = L.map(mapNode, { zoomControl: false }).setView([lat, lng], 15);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; OpenStreetMap'
            }).addTo(map);
            L.marker([lat, lng]).addTo(map);
        })();
    </script>
    <?php
});
