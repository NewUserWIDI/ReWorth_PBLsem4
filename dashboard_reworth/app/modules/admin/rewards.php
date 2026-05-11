<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/table.php';
require_once __DIR__ . '/../../data/mock_data.php';

require_role('admin');

render_layout('Monitoring Reward', function (): void {
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Penukaran Pulsa/Kuota</h2></div>
        <?php simple_table(['ID', 'User', 'Jenis Reward', 'Poin', 'Status'], mock_rewards(), ['status']); ?>
    </section>
    <?php
});

