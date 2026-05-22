<?php

declare(strict_types=1);

// KITA UBAH NAMA TABELNYA PAKAI HURUF KAPITAL SESUAI DI SUPABASE
$total_pengguna  = supabase_count('Users');        // 'users' diganti 'Users'
$total_penukaran = supabase_count('Penukaran');    // 'penukaran' diganti 'Penukaran'
$total_hadiah    = supabase_count('Hadiah');       // 'hadiah' diganti 'Hadiah'
$total_pengaduan = supabase_count('Pengaduan');    // 'pengaduan' diganti 'Pengaduan'

// Bagian ini juga kita ubah nama tabelnya jadi 'Penukaran'
$penukaran_terbaru = supabase_fetch('Penukaran', '*', '&order=created_at.desc&limit=5');

// 2. MASUKKAN VARIABEL DI ATAS KE DALAM RENDER LAYOUT
render_layout('Dashboard Admin', function () use ($total_pengguna, $total_penukaran, $total_hadiah, $total_pengaduan, $penukaran_terbaru) {
    ?>
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-title">Total Pengguna</div>
            <div class="stat-value"><?= number_format($total_pengguna) ?></div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Total Penukaran</div>
            <div class="stat-value"><?= number_format($total_penukaran) ?></div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Total Hadiah</div>
            <div class="stat-value"><?= number_format($total_hadiah) ?></div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Total Pengaduan</div>
            <div class="stat-value"><?= number_format($total_pengaduan) ?></div>
        </div>
    </div>

    <div class="dashboard-content">
        <div class="table-container">
            <div class="table-header">
                <h3>Aktivitas Penukaran Terbaru</h3>
                <a href="<?= url('admin/penukaran.php') ?>" class="btn btn-sm btn-outline">Lihat Semua</a>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID Penukaran</th>
                        <th>User ID</th>
                        <th>Tanggal</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($penukaran_terbaru)): ?>
                        <tr>
                            <td colspan="4" style="text-align: center;">Belum ada data transaksi di Supabase</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($penukaran_terbaru as $row): ?>
                            <tr>
                                <td>#<?= e((string)$row['id']) ?></td>
                                <td><?= e($row['user_id']) ?></td>
                                <td><?= e(date('d M Y', strtotime($row['created_at']))) ?></td>
                                <td>
                                    <span class="status-badge <?= e(status_badge_class($row['status'] ?? '')) ?>">
                                        <?= e(status_label($row['status'] ?? '')) ?>
                                    </span>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
    <?php

});