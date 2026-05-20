<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';

require_role('dlh');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect('dashboard.php?role=dlh&page=reports');
}

$id = $_POST['id'] ?? '';
$action = $_POST['action'] ?? '';
$reason = trim($_POST['reason'] ?? '');

if ($action === 'reject' && $reason === '') {
    set_flash('danger', 'Alasan penolakan wajib diisi.');
    redirect('dashboard.php?role=dlh&page=report_detail&id=' . urlencode($id));
}

if ($action === 'valid') {
    set_flash('success', 'Laporan ' . $id . ' divalidasi. User mendapat 10 poin dan streak +1 (mock).');
} else {
    set_flash('success', 'Laporan ' . $id . ' ditolak dengan alasan: ' . $reason . ' (mock).');
}

redirect('dashboard.php?role=dlh&page=reports');
