<?php

declare(strict_types=1);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/../data/mock_data.php';
require_once __DIR__ . '/../components/seller_helpers.php';

function login_dashboard_user(string $identifier, string $password): array
{
    $identifier = strtolower(trim($identifier));

    foreach (mock_dashboard_users() as $user) {
        $matched = strtolower($user['email']) === $identifier || strtolower($user['username']) === $identifier;

        if (!$matched || !password_verify($password, $user['password_hash'])) {
            continue;
        }

        if ($user['role'] === 'seller' && $user['status'] !== 'aktif') {
            return ['success' => false, 'message' => 'Akun seller belum aktif. Tunggu persetujuan admin.'];
        }

        unset($user['password_hash']);
        $_SESSION['dashboard_user'] = $user;

        return ['success' => true, 'message' => 'Login berhasil', 'user' => $user];
    }

    $sellerResult = seller_authenticate_dashboard_user($identifier, $password);
    if (($sellerResult['success'] ?? false) === true) {
        $_SESSION['dashboard_user'] = $sellerResult['user'];
        return $sellerResult;
    }

    return $sellerResult['message'] ?? '' !== ''
        ? $sellerResult
        : ['success' => false, 'message' => 'Email/username atau password salah.'];
}

function logout_dashboard_user(): void
{
    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
    }

    session_destroy();
}

function current_user(): ?array
{
    return $_SESSION['dashboard_user'] ?? null;
}

function is_logged_in(): bool
{
    return current_user() !== null;
}

function redirect_by_role(string $role): never
{
    match ($role) {
        'admin' => redirect('app/modules/admin/dashboard.php'),
        'dlh' => redirect('app/modules/dlh/dashboard.php'),
        'seller' => redirect('app/modules/seller/dashboard.php'),
        default => redirect('public/login.php'),
    };
}

