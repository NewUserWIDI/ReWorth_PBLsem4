<?php

declare(strict_types=1);

require_once __DIR__ . '/../app/core/middleware.php';

require_login();

$user = current_user();
$role = (string) ($_GET['role'] ?? ($user['role'] ?? ''));
$page = (string) ($_GET['page'] ?? 'dashboard');

if (($user['role'] ?? '') !== $role) {
    set_flash('warning', 'Akses ditolak. Anda diarahkan ke dashboard sesuai role.');
    redirect_by_role((string) ($user['role'] ?? ''));
}

$routes = [
    'admin' => [
        'dashboard' => __DIR__ . '/../app/modules/admin/dashboard.php',
        'users' => __DIR__ . '/../app/modules/admin/users.php',
        'reports' => __DIR__ . '/../app/modules/admin/reports.php',
        'seller_requests' => __DIR__ . '/../app/modules/admin/seller_requests.php',
        'sellers' => __DIR__ . '/../app/modules/admin/sellers.php',
        'products' => __DIR__ . '/../app/modules/admin/products.php',
        'orders' => __DIR__ . '/../app/modules/admin/orders.php',
        'rewards' => __DIR__ . '/../app/modules/admin/rewards.php',
    ],
    'dlh' => [
        'dashboard' => __DIR__ . '/../app/modules/dlh/dashboard.php',
        'reports' => __DIR__ . '/../app/modules/dlh/reports.php',
        'reporters' => __DIR__ . '/../app/modules/dlh/reporters.php',
        'report_detail' => __DIR__ . '/../app/modules/dlh/report_detail.php',
        'verification_action' => __DIR__ . '/../app/modules/dlh/verification_action.php',
    ],
    'seller' => [
        'dashboard' => __DIR__ . '/../app/modules/seller/dashboard.php',
        'store_profile' => __DIR__ . '/../app/modules/seller/store_profile.php',
        'products' => __DIR__ . '/../app/modules/seller/products.php',
        'product_form' => __DIR__ . '/../app/modules/seller/product_form.php',
        'orders' => __DIR__ . '/../app/modules/seller/orders.php',
        'transactions' => __DIR__ . '/../app/modules/seller/transactions.php',
    ],
];

$target = $routes[$role][$page] ?? $routes[$role]['dashboard'] ?? null;

if ($target === null || !is_file($target)) {
    redirect_by_role($role);
}

require $target;
