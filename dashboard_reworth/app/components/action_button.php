<?php

declare(strict_types=1);

function action_button(string $label, string $href, string $variant = 'primary'): void
{
    ?>
    <a class="btn btn-<?= e($variant) ?>" href="<?= e(url($href)) ?>"><?= e($label) ?></a>
    <?php
}

