<?php

declare(strict_types=1);

require_once __DIR__ . '/../app/core/auth.php';

logout_dashboard_user();
redirect('public/login.php');

