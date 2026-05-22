<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';

require_active_seller();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    set_flash('success', 'Produk disimpan ke mock data.');
    redirect('app/modules/seller/products.php');
}

render_layout('Tambah Produk', function (): void {
    ?>
    <section class="panel">
        <div class="panel-header"><h2>Form Produk</h2></div>
        <form method="post">
            <label class="form-field"><span>Nama Produk</span><input name="nama" required></label>
            <label class="form-field"><span>Kategori</span><input name="kategori" required></label>
            <label class="form-field"><span>Harga</span><input name="harga" type="number" required></label>
            <label class="form-field"><span>Stok</span><input name="stok" type="number" required></label>
            <label class="form-field"><span>Deskripsi</span><textarea name="deskripsi" required></textarea></label>
            <button class="btn btn-primary" type="submit">Simpan Produk</button>
        </form>
    </section>
    <?php
});

