<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';

require_role('dlh');

$id = (string) ($_GET['id'] ?? '');
redirect('app/modules/dlh/laporan_detail.php?id=' . urlencode($id));

