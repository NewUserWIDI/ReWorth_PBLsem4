<?php

declare(strict_types=1);

require_once __DIR__ . '/../core/helpers.php';
require_once __DIR__ . '/../core/auth.php';
require_once __DIR__ . '/../config/supabase.php';
require_once __DIR__ . '/sidebar.php';
require_once __DIR__ . '/topbar.php';
require_once __DIR__ . '/footer.php';

function render_layout(string $title, callable $content): void
{
    $user = current_user();
    $flash = get_flash();
    ?>
    <!doctype html>
    <html lang="id">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e($title) ?> - <?= e(APP_NAME) ?></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= url('public/assets/css/app.css') ?>">
    <link rel="stylesheet" href="<?= url('public/assets/css/dashboard.css') ?>">
    </head>
    <body>
        <div class="dashboard-shell">
            <?php render_sidebar($user ?? []); ?>
            <main class="main-area">
                <?php render_topbar($title, $user ?? []); ?>

                <?php if ($flash): ?>
                    <div class="flash flash-<?= e($flash['type']) ?>"><?= e($flash['message']) ?></div>
                <?php endif; ?>

                <section class="page-content">
                    <?php $content(); ?>
                </section>

                <?php render_footer(); ?>
            </main>
        </div>
        <script src="<?= e(url('public/assets/js/app.js')) ?>"></script>
    </body>
    </html>
    <?php
}

