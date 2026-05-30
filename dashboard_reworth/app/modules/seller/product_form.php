<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';

require_active_seller();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    set_flash('success', 'Produk berhasil disimpan. Koneksi Supabase tinggal disambungkan ke schema produk.');
    redirect('app/modules/seller/products.php');
}

render_layout(isset($_GET['id']) ? 'Edit Produk' : 'Tambah Produk', function (): void {
    $isEdit = isset($_GET['id']);
    ?>
    <form method="post" class="form-stack" enctype="multipart/form-data">
        <section class="form-card">
            <div class="panel-header">
                <div>
                    <h2>Informasi Produk</h2>
                    <p>Pastikan nama dan kategori mudah dipahami pembeli.</p>
                </div>
            </div>
            <div class="form-grid">
                <label class="form-field"><span>Nama Produk</span><input name="nama" value="<?= $isEdit ? 'Tas Daur Ulang' : '' ?>" required></label>
                <label class="form-field"><span>Kategori</span><select name="kategori" required><option>Kerajinan Daur Ulang</option><option>Kompos</option><option>Eco Living</option></select></label>
                <label class="form-field"><span>Jenis Sampah / Material</span><input name="material" value="<?= $isEdit ? 'Plastik kemasan' : '' ?>" required></label>
                <label class="form-field"><span>Status Produk</span><select name="status"><option>aktif</option><option>nonaktif</option></select></label>
            </div>
        </section>

        <section class="form-card">
            <div class="panel-header">
                <div>
                    <h2>Media Produk</h2>
                    <p>Minimal 1 foto, maksimal 5 foto. Upload ke Supabase Storage saat backend aktif.</p>
                </div>
            </div>
            <div class="upload-box">
                <div>
                    <strong>Klik untuk upload foto produk</strong>
                    <p class="panel-subtitle">PNG/JPG, tampilkan preview sebelum simpan.</p>
                    <input name="foto[]" type="file" accept="image/*" multiple>
                </div>
            </div>
        </section>

        <section class="form-card">
            <div class="panel-header"><h2>Harga & Stok</h2></div>
            <div class="form-grid">
                <label class="form-field"><span>Harga</span><input name="harga" type="number" value="<?= $isEdit ? '45000' : '' ?>" required></label>
                <label class="form-field"><span>Stok</span><input name="stok" type="number" value="<?= $isEdit ? '20' : '' ?>" required></label>
                <label class="form-field"><span>Berat</span><input name="berat" type="number" placeholder="Gram"></label>
                <label class="form-field"><span>Satuan</span><input name="satuan" placeholder="pcs / paket / kg"></label>
            </div>
        </section>

        <section class="form-card">
            <div class="panel-header"><h2>Deskripsi Produk</h2></div>
            <label class="form-field">
                <span>Detail Barang</span>
                <textarea name="deskripsi" required placeholder="Tuliskan bahan, manfaat, cara pakai, kondisi produk, dan cerita daur ulangnya."><?= $isEdit ? 'Tas daur ulang berbahan plastik kemasan pilihan, kuat untuk aktivitas harian.' : '' ?></textarea>
            </label>
        </section>

        <div class="toolbar">
            <a class="btn btn-secondary" href="<?= e(url('app/modules/seller/products.php')) ?>">Batal</a>
            <button class="btn btn-primary" type="submit"><?= $isEdit ? 'Simpan Perubahan' : 'Simpan Produk' ?></button>
        </div>
    </form>
    <?php
});

