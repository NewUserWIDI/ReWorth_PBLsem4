<?php

declare(strict_types=1);

function modal_placeholder(string $id, string $title): void
{
    ?>
    <dialog id="<?= e($id) ?>" class="modal">
        <h2><?= e($title) ?></h2>
        <p>Konten modal akan diisi saat fitur detail dibuat.</p>
        <form method="dialog">
            <button class="btn btn-secondary">Tutup</button>
        </form>
    </dialog>
    <?php
}

