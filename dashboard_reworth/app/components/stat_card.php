<?php

declare(strict_types=1);

function stat_card(string $label, string|int $value, string $hint = '', string $variant = ''): void
{
    $class = trim('stat-card ' . ($variant !== '' ? 'is-' . $variant : ''));
    ?>
    <article class="<?= e($class) ?>">
        <span class="stat-label"><?= e($label) ?></span>
        <strong class="stat-value"><?= e($value) ?></strong>
        <?php if ($hint !== ''): ?>
            <small class="stat-desc"><?= e($hint) ?></small>
        <?php endif; ?>
    </article>
    <?php
}
