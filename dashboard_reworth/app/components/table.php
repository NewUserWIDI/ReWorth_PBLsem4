<?php

declare(strict_types=1);

require_once __DIR__ . '/badge_status.php';

function simple_table(array $headers, array $rows, array $statusColumns = []): void
{
    ?>
    <div class="table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <?php foreach ($headers as $header): ?>
                        <th><?= e($header) ?></th>
                    <?php endforeach; ?>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($rows as $row): ?>
                    <tr>
                        <?php foreach ($row as $key => $value): ?>
                            <td>
                                <?php if (in_array($key, $statusColumns, true)): ?>
                                    <?php badge_status((string) $value); ?>
                                <?php else: ?>
                                    <?= e($value) ?>
                                <?php endif; ?>
                            </td>
                        <?php endforeach; ?>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    <?php
}

