<?php

declare(strict_types=1);

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
    if (mb_strlen(preg_replace('/\s+/', ' ', $reason)) < 10) {
        set_flash('danger', 'Alasan penolakan minimal 10 karakter.');
        redirect('app/modules/dlh/laporan_detail.php?id=' . urlencode($id));
    }

    set_flash('success', 'Laporan #' . $id . ' ditolak. Alasan: ' . $reason . ' (mock).');
    redirect('app/modules/dlh/riwayat.php');
}

if ($action === 'accept') {
    set_flash('success', 'Laporan #' . $id . ' berhasil diverifikasi dan diubah ke status diproses (mock).');
    redirect('app/modules/dlh/monitoring.php');
}

if ($action === 'finish') {
    set_flash('success', 'Laporan #' . $id . ' ditandai selesai (mock).');
    redirect('app/modules/dlh/riwayat.php');
}

set_flash('warning', 'Aksi belum didukung.');
redirect('app/modules/dlh/laporan.php');

