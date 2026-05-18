<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/auth.php';
require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../core/helpers.php';
require_once __DIR__ . '/../../data/mock_reporters.php';
require_once __DIR__ . '/../../layout/sidebar.php';
require_once __DIR__ . '/../../layout/topbar.php'; 
require_once __DIR__ . '/../../layout/footer.php'; 

require_login();
require_role('dlh');

$pageTitle = 'Data Pelapor';

// Mengambil data user yang sedang login dari session untuk komponen sidebar/topbar
// Pastikan menambahkan key 'nama' dan 'email' sesuai kebutuhan fungsi render_topbar
$user = $_SESSION['user'] ?? [
    'role' => 'dlh', 
    'nama' => 'Petugas DLH', 
    'email' => 'dlh@reworth.app'
];

/*
|--------------------------------------------------------------------------
| Search Logic
|--------------------------------------------------------------------------
*/
$search = trim($_GET['search'] ?? '');
$reporters = $mockReporters;

if ($search !== '') {
    $reporters = array_filter($reporters, function ($item) use ($search) {
        return stripos($item['nama'], $search) !== false
            || stripos($item['email'], $search) !== false
            || stripos($item['alamat'], $search) !== false;
    });
}

/*
|--------------------------------------------------------------------------
| Statistik Logic
|--------------------------------------------------------------------------
*/
$totalPelapor = count($mockReporters); // Total keseluruhan dari mock data asli
$totalAktif = count(array_filter($mockReporters, function ($item) {
    return $item['status'] === 'aktif';
}));
?>
<!doctype html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($pageTitle) ?> - ReWorth</title>
    <link rel="stylesheet" href="<?= e(url('public/assets/css/app.css')) ?>">
    <link rel="stylesheet" href="<?= e(url('public/assets/css/dashboard.css')) ?>">
</head>
<body>

<div class="dashboard-shell">
    
    <?php render_sidebar($user); ?>

    <main class="main-area">
        
        <?php render_topbar($pageTitle, $user); ?>

        <div class="page-content">
            
            <section class="stat-grid">
                <div class="stat-card">
                    <span>Total Pelapor Terdaftar</span>
                    <strong><?= $totalPelapor ?></strong>
                    <small>Masyarakat</small>
                </div>
                <div class="stat-card">
                    <span>Pelapor Aktif</span>
                    <strong><?= $totalAktif ?></strong>
                    <small>Status Aktif</small>
                </div>
            </section>

            <section class="panel">
                <div class="panel-header">
                    <h2>Daftar Pelapor Terdaftar</h2>
                    
                    <form method="GET" action="" style="width: 100%; max-width: 320px;">
                        <div class="form-field" style="margin-bottom: 0;">
                            <input 
                                type="text" 
                                name="search" 
                                placeholder="Cari nama atau alamat..." 
                                value="<?= e($search) ?>"
                                onchange="this.form.submit()"
                            >
                        </div>
                    </form>
                </div>

                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nama Pelapor</th>
                                <th>Email</th>
                                <th>Alamat Pelapor</th>
                                <th>Total Laporan</th>
                                <th>Status Pelapor</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (count($reporters) > 0): ?>
                                <?php foreach ($reporters as $reporter): ?>
                                    <tr>
                                        <td><?= e($reporter['id']) ?></td>
                                        <td><strong><?= e($reporter['nama']) ?></strong></td>
                                        <td><?= e($reporter['email']) ?></td>
                                        <td><?= e($reporter['alamat']) ?></td>
                                        <td><?= e((string) $reporter['total_laporan']) ?> Laporan</td>
                                        <td>
                                            <span class="status-badge <?= $reporter['status'] === 'aktif' ? 'badge-success' : 'badge-warning' ?>">
                                                <?= e(ucfirst($reporter['status'])) ?>
                                            </span>                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php else: ?>
                                <tr>
                                    <td colspan="6" style="text-align: center; color: var(--muted); padding: 32px;">
                                        Data pelapor tidak ditemukan.
                                    </td>
                                </tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </section>
                <?php render_footer(); ?>
            
        </div>
    </main>
</div>

</body>
</html>