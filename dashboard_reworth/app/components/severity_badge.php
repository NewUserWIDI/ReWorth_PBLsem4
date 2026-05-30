<?php

declare(strict_types=1);

function severity_badge(string $severity): void
{
    $value = strtolower(trim($severity));
    $class = match ($value) {
        'ringan' => 'severity-light',
        'sedang' => 'severity-medium',
        'parah' => 'severity-high',
        default => 'severity-light',
    };

    ?>
    <span class="severity-badge <?= e($class) ?>"><?= e(ucfirst($value)) ?></span>
    <?php
}

