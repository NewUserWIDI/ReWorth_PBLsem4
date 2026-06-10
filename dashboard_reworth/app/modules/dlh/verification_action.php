<?php

declare(strict_types=1);
require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../components/dlh_helpers.php';
require_once __DIR__ . '/../../core/middleware.php';

require_role('dlh');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect('app/modules/dlh/laporan.php');
}

$id = trim((string) ($_POST['id_laporan'] ?? ''));
$action = trim((string) ($_POST['action'] ?? ''));
$reason = trim((string) ($_POST['alasan_ditolak'] ?? ''));

if ($id === '' || $action === '') {
    set_flash('danger', 'Aksi laporan tidak valid.');
    redirect('app/modules/dlh/laporan.php');
}

if ($action === 'reject') {

    if (mb_strlen(trim($reason)) < 10) {
        set_flash('danger', 'Alasan penolakan minimal 10 karakter.');
        redirect('app/modules/dlh/laporan_detail.php?id=' . urlencode($id));
    }

    $laporan = dlh_find_report((int) $id);
    if ($laporan === null) {
        set_flash('danger', 'Laporan tidak ditemukan.');
        redirect('app/modules/dlh/laporan.php');
    }

    $rejectedPoints = 3;
    dlh_update_status((int)$id, 'rejected', $reason, $rejectedPoints);

    $userId = (string) ($laporan['id_masyarakat'] ?? '');
    if ($userId !== '') {
        $profile = supabase_fetch_one(
            'profiles',
            'total_poin',
            ['id' => 'eq.' . $userId]
        );

        if ($profile !== null) {
            $currentPoint = (int) ($profile['total_poin'] ?? 0);
            supabase_update(
                'profiles',
                [
                    'total_poin' => $currentPoint + $rejectedPoints,
                    'updated_at' => date('Y-m-d H:i:s'),
                ],
                [
                    'id' => 'eq.' . $userId,
                ]
            );
        }
    }

    set_flash('success', 'Laporan berhasil ditolak.');
    redirect('app/modules/dlh/riwayat.php');
}

if ($action === 'accept') {

    dlh_update_status((int)$id, 'processing');

    set_flash('success', 'Laporan berhasil diverifikasi.');
    redirect('app/modules/dlh/monitoring.php');
}

if ($action === 'finish') {

    $laporan = dlh_find_report((int)$id);

    if ($laporan === null) {
        set_flash('danger', 'Laporan tidak ditemukan.');
        redirect('app/modules/dlh/laporan.php');
    }

    if (($laporan['status_laporan'] ?? '') === 'completed') {
        set_flash('warning', 'Laporan sudah pernah diselesaikan.');
        redirect('app/modules/dlh/riwayat.php');
    }

    // Hitung poin berdasarkan tingkat keparahan
    $poin = match ($laporan['tingkat_keparahan']) {
        'Ringan' => 10,
        'Sedang' => 20,
        'Berat'  => 30,
        default  => 10,
    };

    // Update status laporan + simpan poin yang diberikan
    dlh_update_status(
        (int)$id,
        'completed',
        null,
        $poin
    );

    $userId = (string) ($laporan['id_masyarakat'] ?? '');
    $profile = supabase_fetch_one(
        'profiles',
        'total_poin,total_laporan_valid',
        ['id' => 'eq.' . $userId]
    );

    if ($profile !== null) {
        $timezone = new DateTimeZone('Asia/Jakarta');
        $now = new DateTimeImmutable('now', $timezone);
        $startOfDay = $now->setTime(0, 0, 0);
        $startOfNextDay = $startOfDay->modify('+1 day');
        $startOfDayTs = $startOfDay->getTimestamp();
        $startOfNextDayTs = $startOfNextDay->getTimestamp();

        $completedReports = supabase_fetch(
            'laporan_sampah',
            'id_laporan,updated_at',
            [
                'id_masyarakat' => 'eq.' . $userId,
                'status_laporan' => 'in.(completed,selesai,valid,diterima,approved)',
                'limit' => '1000',
            ]
        );

        $todayCompletedCount = 0;
        foreach ($completedReports as $completedReport) {
            $updatedAtRaw = (string) ($completedReport['updated_at'] ?? '');
            if ($updatedAtRaw === '') {
                continue;
            }

            $updatedAtTs = strtotime($updatedAtRaw);
            if ($updatedAtTs === false) {
                continue;
            }

            if ($updatedAtTs >= $startOfDayTs && $updatedAtTs < $startOfNextDayTs) {
                $todayCompletedCount++;
            }
        }

        $bonusHistory = supabase_fetch(
            'riwayat_poin',
            'tanggal',
            [
                'id_masyarakat' => 'eq.' . $userId,
                'jenis_transaksi' => 'eq.Masuk',
                'sumber_poin' => 'eq.Bonus Streak 7 Laporan',
                'limit' => '1000',
            ]
        );

        $todayBonusCount = 0;
        foreach ($bonusHistory as $bonusRow) {
            $bonusDateRaw = (string) ($bonusRow['tanggal'] ?? '');
            if ($bonusDateRaw === '') {
                continue;
            }

            $bonusDateTs = strtotime($bonusDateRaw);
            if ($bonusDateTs === false) {
                continue;
            }

            if ($bonusDateTs >= $startOfDayTs && $bonusDateTs < $startOfNextDayTs) {
                $todayBonusCount++;
            }
        }

        $currentPoint = (int) ($profile['total_poin'] ?? 0);
        $currentValid = (int) ($profile['total_laporan_valid'] ?? 0);
        $streakBonus = ($todayCompletedCount >= 7 && $todayBonusCount === 0) ? 25 : 0;
        $newTotalPoint = $currentPoint + $poin + $streakBonus;

        supabase_update(
            'profiles',
            [
                'total_laporan_valid' => $currentValid + 1,
                'streak_poin' => min(7, $todayCompletedCount),
                'total_poin' => $newTotalPoint,
            ],
            [
                'id' => 'eq.' . $userId
            ]
        );

        if ($streakBonus > 0) {
            try {
                supabase_insert('riwayat_poin', [
                    'id_masyarakat' => $userId,
                    'jenis_transaksi' => 'Masuk',
                    'sumber_poin' => 'Bonus Streak 7 Laporan',
                    'jumlah_poin' => $streakBonus,
                    'saldo_setelah' => $newTotalPoint,
                    'keterangan' => 'Bonus streak 7 laporan berhasil didapatkan.',
                    'tanggal' => $now->format(DATE_ATOM),
                ]);
            } catch (Throwable $e) {
                // riwayat bonus bersifat opsional
            }
        }
    }

    set_flash('success', 'Laporan berhasil diselesaikan. Poin telah diberikan kepada pelapor.');
    redirect('app/modules/dlh/riwayat.php');
}
