<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';

require_role('admin');

render_layout('Data User', function (): void {
    $rows = [
        ['USR-001', 'Fatma Azzahra', 'fatma@mail.com', '181 poin', '7 laporan valid'],
        ['USR-002', 'Bima Saputra', 'bima@mail.com', '90 poin', '4 laporan valid'],
        ['USR-003', 'Nadia Putri', 'nadia@mail.com', '20 poin', '1 laporan valid'],
    ];
    ?>
    <section class="panel">
        <div class="panel-header"><h2>User Mobile</h2></div>
        <?php simple_table(['ID', 'Nama', 'Email', 'Poin', 'Aktivitas'], $rows); ?>
    </section>
    <?php
});

