<?php

declare(strict_types=1);

function badge_status(string $status): void
{
    ?>
    <span class="status-badge <?= e(status_badge_class($status)) ?>"><?= e(status_label($status)) ?></span>
    <?php
}

