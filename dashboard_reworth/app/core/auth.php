<?php

declare(strict_types=1);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/../config/supabase.php';
require_once __DIR__ . '/../components/seller_helpers.php';

function dashboard_authenticate_staff_user(string $identifier, string $password): array
{
    $identifier = trim($identifier);
    $password = trim($password);

    if ($identifier === '' || $password === '') {
        return ['success' => false, 'message' => 'Email/username dan password wajib diisi.'];
    }

    $rows = supabase_fetch(
        'dashboard_users',
        'id,profile_id,nama_lengkap,username,email,password_hash,role,is_active',
        ['limit' => '100']
    );

    if (!is_array($rows)) {
        return ['success' => false, 'message' => supabase_last_error() ?? 'Gagal membaca akun dashboard dari Supabase.'];
    }

    $identifierLower = strtolower($identifier);
    $row = null;
    foreach ($rows as $candidate) {
        if (!is_array($candidate)) {
            continue;
        }

        $username = strtolower(trim((string) ($candidate['username'] ?? '')));
        $email = strtolower(trim((string) ($candidate['email'] ?? '')));
        if ($username === $identifierLower || $email === $identifierLower) {
            $row = $candidate;
            break;
        }
    }

    if ($row === null) {
        return ['success' => false, 'message' => 'Email/username atau password salah.'];
    }

    if (($row['is_active'] ?? true) !== true) {
        return ['success' => false, 'message' => 'Akun dashboard nonaktif.'];
    }

    $storedHash = (string) ($row['password_hash'] ?? '');
    if ($storedHash === '' || !password_verify($password, $storedHash)) {
        return ['success' => false, 'message' => 'Email/username atau password salah.'];
    }

    $dashboardUserId = (string) ($row['id'] ?? '0');
    $user = [
        'id' => (string) (($row['profile_id'] ?? null) ?: ('staff-' . $dashboardUserId)),
        'user_id' => (string) (($row['profile_id'] ?? null) ?: ('staff-' . $dashboardUserId)),
        'dashboard_user_id' => $dashboardUserId,
        'profile_id' => (string) ($row['profile_id'] ?? ''),
        'nama' => (string) ($row['nama_lengkap'] ?? 'Petugas ReWorth'),
        'nama_lengkap' => (string) ($row['nama_lengkap'] ?? 'Petugas ReWorth'),
        'email' => (string) ($row['email'] ?? ''),
        'username' => (string) ($row['username'] ?? ''),
        'role' => (string) ($row['role'] ?? ''),
        'status' => 'aktif',
    ];

    return [
        'success' => true,
        'message' => 'Login berhasil',
        'user' => $user,
    ];
}

function login_dashboard_user(string $identifier, string $password): array
{
    $staffResult = dashboard_authenticate_staff_user($identifier, $password);
    if (($staffResult['success'] ?? false) === true) {
        $_SESSION['dashboard_user'] = $staffResult['user'];
        return $staffResult;
    }

    $sellerResult = seller_authenticate_dashboard_user($identifier, $password);
    if (($sellerResult['success'] ?? false) === true) {
        $_SESSION['dashboard_user'] = $sellerResult['user'];
        return $sellerResult;
    }

    $staffMessage = (string) ($staffResult['message'] ?? '');
    if ($staffMessage !== '' && $staffMessage !== 'Email/username atau password salah.') {
        return $staffResult;
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

