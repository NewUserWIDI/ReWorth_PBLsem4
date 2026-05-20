<?php

declare(strict_types=1);

function render_topbar(string $title, array $user): void
{
    $initials = strtoupper(substr((string) ($user['nama'] ?? 'R'), 0, 1));
    ?>
    <header class="topbar">
        <div>
            <p><?= e(status_label($user['role'] ?? '')) ?></p>
            <h1><?= e($title) ?></h1>
        </div>
        <div class="topbar-actions">
            <label class="topbar-search">
                <span>Cari</span>
                <input type="search" placeholder="Cari produk atau pesanan...">
            </label>
            <button class="notification-button" type="button" aria-label="Notifikasi">!</button>
            <div class="topbar-user">
                <span class="user-avatar"><?= e($initials) ?></span>
                <div>
                    <strong><?= e($user['nama'] ?? '-') ?></strong>
                    <span><?= e(status_label($user['role'] ?? '')) ?></span>
                </div>
            </div>
        </div>
    </header>
    <?php
}
