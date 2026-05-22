<?php
require_once __DIR__ . '/../../core/helpers.php';
require_once __DIR__ . '/../../layout/main_layout.php';

// Simulasi data laporan (Nanti ini diambil dari Database)
$reports = [
    ['id' => 'LPR-001', 'pelapor' => 'Andi', 'jenis' => 'Plastik', 'status' => 'menunggu_verifikasi'],
    ['id' => 'LPR-002', 'pelapor' => 'Budi', 'jenis' => 'Logam', 'status' => 'valid'],
];

render_layout('Manajemen Laporan', function () use ($reports) { ?>
    <div class="card shadow-sm border-0">
        <div class="card-body">
            <h4 class="mb-4">Daftar Laporan Masyarakat</h4>
            <table class="table table-striped align-middle">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Pelapor</th>
                        <th>Jenis</th>
                        <th>Status</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($reports as $r): ?>
                    <tr>
                        <td><?= e($r['id']) ?></td>
                        <td><?= e($r['pelapor']) ?></td>
                        <td><?= e($r['jenis']) ?></td>
                        <td>
                            <span class="badge <?= status_badge_class($r['status']) ?>">
                                <?= e(status_label($r['status'])) ?>
                            </span>
                        </td>
                        <td>
                            <?php if ($r['status'] === 'menunggu_verifikasi'): ?>
                                <a href="verify.php?id=<?= $r['id'] ?>&action=approve" class="btn btn-sm btn-success">Setujui</a>
                                <a href="verify.php?id=<?= $r['id'] ?>&action=reject" class="btn btn-sm btn-danger">Tolak</a>
                            <?php else: ?>
                                <span class="text-muted small">Sudah diproses</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
<?php });