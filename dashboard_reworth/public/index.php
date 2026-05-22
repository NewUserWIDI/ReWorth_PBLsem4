<?php

declare(strict_types=1);

require_once __DIR__ . '/../app/core/auth.php';

if (!is_logged_in()) {
    redirect('public/login.php');
}

redirect_by_role(current_user()['role'] ?? '');

