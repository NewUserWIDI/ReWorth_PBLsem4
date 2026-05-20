<?php

declare(strict_types=1);

if (!function_exists('badge_status')) {
    function badge_status(string $status): void
    {
        ?>
        <span class="status-badge <?= e(status_badge_class($status)) ?>"><?= e(status_label($status)) ?></span>
        <?php
    }
}
