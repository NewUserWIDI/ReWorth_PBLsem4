<?php

declare(strict_types=1);

require_once __DIR__ . '/../../core/middleware.php';
require_once __DIR__ . '/../../layout/main_layout.php';
require_once __DIR__ . '/../../components/badge_status.php';
require_once __DIR__ . '/../../components/admin_payment_helpers.php';

require_role('admin');

$paymentId = (int) ($_GET['id'] ?? 0);
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $decision = (string) ($_POST['decision'] ?? '');
    $note = trim((string) ($_POST['catatan_verifikasi'] ?? ''));
    $actor = current_user()['email'] ?? current_user()['username'] ?? 'admin';
    $result = admin_payment_verification_action($paymentId, $decision, $note, (string) $actor);
    set_flash((string) ($result['type'] ?? 'success'), (string) ($result['message'] ?? 'Aksi selesai.'));
    redirect('app/modules/admin/payment_verification_detail.php?id=' . $paymentId);
}

$payment = admin_payment_verification_by_id($paymentId);
if ($payment === null) {
    set_flash('warning', 'Data pembayaran tidak ditemukan.');
    redirect('app/modules/admin/payment_verifications.php');
}

render_layout('Detail Verifikasi Pembayaran', function () use ($payment): void {
    ?>
    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Pembayaran #<?= e((string) $payment['id_pembayaran']) ?></h2>
                <p>Pesanan <?= e((string) $payment['kode_pesanan']) ?> | Pembeli <?= e((string) $payment['buyer_name']) ?></p>
            </div>
            <div class="report-meta">
                <?php badge_status((string) $payment['payment_status']); ?>
                <?php badge_status((string) $payment['order_status']); ?>
            </div>
        </div>

        <div class="form-grid">
            <article class="form-card">
                <p><strong>Nama Pembeli:</strong> <?= e((string) $payment['buyer_name']) ?></p>
                <p><strong>Email:</strong> <?= e((string) $payment['buyer_email']) ?></p>
                <p><strong>No. HP:</strong> <?= e((string) $payment['buyer_phone']) ?></p>
                <p><strong>Alamat Kirim:</strong><br><?= nl2br(e((string) $payment['alamat'])) ?></p>
            </article>
            <article class="form-card">
                <p><strong>Total Bayar:</strong> Rp <?= e(number_format((int) $payment['total_bayar'], 0, ',', '.')) ?></p>
                <p><strong>Subtotal Produk:</strong> Rp <?= e(number_format((int) $payment['subtotal_produk'], 0, ',', '.')) ?></p>
                <p><strong>Fee Platform:</strong> Rp <?= e(number_format((int) $payment['fee_platform'], 0, ',', '.')) ?></p>
                <p><strong>Biaya Layanan:</strong> Rp <?= e(number_format((int) $payment['biaya_layanan'], 0, ',', '.')) ?></p>
                <p><strong>Upload Bukti:</strong> <?= e((string) ($payment['tanggal_upload_bukti'] !== '' ? substr((string) $payment['tanggal_upload_bukti'], 0, 19) : '-')) ?></p>
            </article>
        </div>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Bukti Pembayaran</h2>
                <p>Pastikan nominal dan akun pembayaran sesuai mutasi/QRIS masuk.</p>
            </div>
        </div>
        <?php if ((string) ($payment['bukti_pembayaran_url'] ?? '') !== ''): ?>
            <img src="<?= e((string) $payment['bukti_pembayaran_url']) ?>" alt="Bukti pembayaran" style="display:block;width:100%;max-width:520px;border-radius:20px;border:1px solid #e5e7eb;">
        <?php else: ?>
            <div class="empty-state" style="min-height:180px;">User belum mengunggah bukti pembayaran.</div>
        <?php endif; ?>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Item Pesanan</h2>
                <p>Rincian produk yang akan diteruskan ke seller setelah pembayaran diverifikasi.</p>
            </div>
        </div>
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr><th>Produk</th><th>Qty</th><th>Harga Satuan</th><th>Subtotal</th><th>Net Seller</th></tr>
                </thead>
                <tbody>
                    <?php foreach (($payment['items'] ?? []) as $item): ?>
                        <tr>
                            <td><?= e((string) ($item['nama_produk'] ?? 'Produk')) ?></td>
                            <td><?= e((string) ($item['jumlah'] ?? 0)) ?></td>
                            <td>Rp <?= e(number_format((int) ($item['harga_satuan'] ?? 0), 0, ',', '.')) ?></td>
                            <td>Rp <?= e(number_format((int) ($item['subtotal'] ?? 0), 0, ',', '.')) ?></td>
                            <td>Rp <?= e(number_format((int) ($item['pendapatan_seller'] ?? 0), 0, ',', '.')) ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </section>

    <section class="panel">
        <div class="panel-header">
            <div>
                <h2>Aksi Verifikasi</h2>
                <p>Approve jika dana benar-benar sudah masuk. Tolak jika bukti tidak valid atau nominal belum diterima.</p>
            </div>
        </div>
        <form class="form-stack" method="post">
            <label class="form-field">
                <span>Catatan Verifikasi</span>
                <textarea name="catatan_verifikasi" placeholder="Tulis catatan untuk audit internal atau alasan penolakan..."><?= e((string) ($payment['catatan_verifikasi'] ?? '')) ?></textarea>
            </label>
            <div class="card-actions">
                <button class="btn btn-primary" type="submit" name="decision" value="approve">Terima Pembayaran</button>
                <button class="btn btn-danger" type="submit" name="decision" value="reject">Tolak Pembayaran</button>
            </div>
        </form>
    </section>
    <?php
});
