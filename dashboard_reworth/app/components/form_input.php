<?php

declare(strict_types=1);

function form_input(string $name, string $label, string $type = 'text', string $value = '', string $placeholder = ''): void
{
    ?>
    <label class="form-field">
        <span><?= e($label) ?></span>
        <input type="<?= e($type) ?>" name="<?= e($name) ?>" value="<?= e($value) ?>" placeholder="<?= e($placeholder) ?>" required>
    </label>
    <?php
}

