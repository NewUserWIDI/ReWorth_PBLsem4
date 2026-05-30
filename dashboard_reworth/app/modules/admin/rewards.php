<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';

require_role('admin');
redirect('app/modules/admin/aktivitas.php');
