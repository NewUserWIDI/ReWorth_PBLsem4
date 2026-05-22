<?php

declare(strict_types=1);

function render_topbar(string $title, array $user): void
{
    ?>
    <header class="topbar">
        <div>
            <p><?= e(status_label($user['role'] ?? '')) ?></p>
            <h1><?= e($title) ?></h1>
        </div>
        <div class="topbar-user">
            <div>
                <strong><?= e($user['nama'] ?? '-') ?></strong>
                <span><?= e($user['email'] ?? '-') ?></span>
            </div>
            <a class="btn btn-secondary" href="<?= e(url('public/logout.php')) ?>">Logout</a>
        </div>
    </header>
    <?php
}

