<?php

declare(strict_types=1);

require_once __DIR__ . '/../app/core/auth.php';

$message = '';

if (is_logged_in()) {
    redirect_by_role(current_user()['role'] ?? '');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $result = login_dashboard_user($_POST['identifier'] ?? '', $_POST['password'] ?? '');

    if ($result['success']) {
        redirect_by_role($result['user']['role']);
    }

    $message = $result['message'];
}
?>
<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login - <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="<?= e(url('public/assets/css/app.css')) ?>">
</head>
<body class="login-page">
    <main class="login-card">
        <div class="login-brand">
            <div class="login-mark">R</div>
            <div>
                <h1>Masuk Dashboard</h1>
                <p>Admin, DLH, dan seller memakai satu halaman login.</p>
            </div>
        </div>

        <?php if ($message !== ''): ?>
            <div class="alert"><?= e($message) ?></div>
        <?php endif; ?>

        <form method="post">
            <label class="form-field">
                <span>Email atau Username</span>
                <input name="identifier" placeholder="admin@reworth.app" required>
            </label>
            <label class="form-field">
                <span>Password</span>
                <input name="password" type="password" placeholder="password123" required>
            </label>
            <button class="btn btn-primary" type="submit" style="width: 100%;">Login</button>
        </form>

        <p style="margin-top: 18px; font-size: 13px;">
            Demo: `admin@reworth.app`, `dlh@reworth.app`, `seller@reworth.app` dengan password `password123`.
        </p>
    </main>
</body>
</html>

