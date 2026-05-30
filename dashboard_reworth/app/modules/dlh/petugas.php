<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('dlh');

$query = strtolower(trim((string) ($_GET['q'] ?? '')));
$status = trim((string) ($_GET['status'] ?? ''));
$tim = trim((string) ($_GET['tim'] ?? ''));

$officers = array_values(array_filter(mock_dlh_officers(), function (array $item) use ($query, $status, $tim): bool {
    if ($status !== '' && ($item['status'] ?? '') !== $status) {
        return false;
    }
    if ($tim !== '' && strcasecmp((string) ($item['tim'] ?? ''), $tim) !== 0) {
        return false;
    }
    if ($query === '') {
        return true;
    }

    $haystack = strtolower(implode(' ', [
        (string) ($item['nama'] ?? ''),
        (string) ($item['wilayah'] ?? ''),
        (string) ($item['kontak'] ?? ''),
        (string) ($item['tim'] ?? ''),
    ]));
    return str_contains($haystack, $query);
}));

$timOptions = array_values(array_unique(array_map(fn (array $item): string => (string) ($item['tim'] ?? ''), mock_dlh_officers())));
sort($timOptions);

render_layout('Petugas', function () use ($officers, $query, $status, $tim, $timOptions): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Petugas</h2>
                <p>Kelola data petugas lapangan.</p>
            </div>
            <a class="btn btn-primary" href="<?= e(url('app/modules/dlh/petugas_form.php')) ?>">Tambah Petugas</a>
        </div>
        <form class="toolbar" method="get">
            <div class="toolbar-left">
                <input class="input" type="search" name="q" value="<?= e($query) ?>" placeholder="Cari petugas...">
                <select class="select" name="status">
                    <option value="">Semua status</option>
                    <option value="aktif" <?= $status === 'aktif' ? 'selected' : '' ?>>Aktif</option>
                    <option value="nonaktif" <?= $status === 'nonaktif' ? 'selected' : '' ?>>Nonaktif</option>
                </select>
                <select class="select" name="tim">
                    <option value="">Semua tim</option>
                    <?php foreach ($timOptions as $item): ?>
                        <option value="<?= e($item) ?>" <?= $tim === $item ? 'selected' : '' ?>><?= e($item) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <button class="btn btn-secondary" type="submit">Filter</button>
        </form>
    </section>

    <section class="panel">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Nama Petugas</th>
                        <th>Tim</th>
                        <th>Wilayah</th>
                        <th>Kontak</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if ($officers === []): ?>
                        <tr><td colspan="6" style="text-align:center;color:#6b7280;">Tidak ada data petugas.</td></tr>
                    <?php else: ?>
                        <?php foreach ($officers as $item): ?>
                            <tr>
                                <td><?= e((string) $item['nama']) ?></td>
                                <td><?= e((string) $item['tim']) ?></td>
                                <td><?= e((string) $item['wilayah']) ?></td>
                                <td><?= e((string) $item['kontak']) ?></td>
                                <td><span class="status-badge <?= ($item['status'] ?? '') === 'aktif' ? 'badge-success' : 'badge-danger' ?>"><?= e(ucfirst((string) $item['status'])) ?></span></td>
                                <td>
                                    <div class="card-actions">
                                        <a class="btn btn-secondary" href="<?= e(url('app/modules/dlh/petugas_form.php?id=' . urlencode((string) $item['id_petugas']))) ?>">Edit</a>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
    <?php
});

