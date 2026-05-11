<?php

declare(strict_types=1);

function stat_card(string $label, string|int $value, string $hint = ''): void
{
    ?>
    <article class="stat-card">
        <span><?= e($label) ?></span>
        <strong><?= e($value) ?></strong>
        <?php if ($hint !== ''): ?>
            <small><?= e($hint) ?></small>
        <?php endif; ?>
    </article>
    <?php
}

