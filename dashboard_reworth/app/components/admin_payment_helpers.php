<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';

function admin_payment_overview(): array
{
    $rows = admin_payment_verifications();
    $pending = 0;
    $verified = 0;
    $rejected = 0;
    $gross = 0.0;

    foreach ($rows as $row) {
        $status = strtolower((string) ($row['payment_status'] ?? ''));
        if (str_contains($status, 'menunggu')) {
            $pending++;
        } elseif ($status === 'terverifikasi') {
            $verified++;
        } elseif ($status === 'ditolak') {
            $rejected++;
        }

        $gross += (float) ($row['total_bayar'] ?? 0);
    }

    return [
        'total' => count($rows),
        'pending' => $pending,
        'verified' => $verified,
        'rejected' => $rejected,
        'gross' => $gross,
    ];
}

function admin_payment_verifications(array $filters = []): array
{
    [$payments, $orders, $profiles, $addresses, $detailsByOrder] = admin_payment_dataset();
    $rows = [];

    foreach ($payments as $payment) {
        $paymentId = (int) ($payment['id_pembayaran'] ?? 0);
        $orderId = (int) ($payment['id_pesanan'] ?? 0);
        $order = $orders[$orderId] ?? null;
        if ($paymentId <= 0 || !is_array($order)) {
            continue;
        }

        $buyerId = (string) ($order['id_masyarakat'] ?? '');
        $buyer = $profiles[$buyerId] ?? [];
        $addressId = (int) ($order['id_alamat'] ?? 0);
        $address = $addresses[$addressId] ?? [];
        $details = $detailsByOrder[$orderId] ?? [];

        $rows[] = [
            'id_pembayaran' => $paymentId,
            'id_pesanan' => $orderId,
            'kode_pesanan' => (string) ($order['kode_pesanan'] ?? ('ORD-' . $orderId)),
            'buyer_name' => (string) (($buyer['nama_lengkap'] ?? $buyer['nama'] ?? 'Pengguna ReWorth')),
            'buyer_email' => (string) ($buyer['email'] ?? '-'),
            'buyer_phone' => (string) (($buyer['no_telp'] ?? $buyer['nomor_hp'] ?? '-')),
            'payment_status' => (string) ($payment['status_pembayaran'] ?? ''),
            'order_status' => (string) ($order['status_pesanan'] ?? ''),
            'total_bayar' => (float) ($order['total_bayar'] ?? $payment['jumlah_bayar'] ?? 0),
            'subtotal_produk' => (float) ($order['subtotal_produk'] ?? $order['subtotal'] ?? 0),
            'fee_platform' => (float) ($order['fee_platform'] ?? $order['pajak'] ?? 0),
            'biaya_layanan' => (float) ($order['biaya_layanan'] ?? 0),
            'bukti_pembayaran_url' => (string) ($payment['bukti_pembayaran_url'] ?? ''),
            'metode_pembayaran' => (string) ($payment['metode_pembayaran'] ?? 'QRIS'),
            'tanggal_upload_bukti' => (string) ($payment['tanggal_upload_bukti'] ?? ''),
            'tanggal_verifikasi' => (string) ($payment['tanggal_verifikasi'] ?? ''),
            'diverifikasi_oleh' => (string) ($payment['diverifikasi_oleh'] ?? ''),
            'catatan_verifikasi' => (string) ($payment['catatan_verifikasi'] ?? ''),
            'alamat' => admin_payment_address_text($address),
            'items_count' => count($details),
            'items' => $details,
        ];
    }

    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $status = strtolower(trim((string) ($filters['status'] ?? '')));

    $rows = array_values(array_filter($rows, static function (array $row) use ($q, $status): bool {
        if ($status !== '') {
            $paymentStatus = strtolower((string) ($row['payment_status'] ?? ''));
            if ($paymentStatus !== $status) {
                return false;
            }
        }

        if ($q === '') {
            return true;
        }

        $haystack = strtolower(implode(' ', [
            (string) ($row['id_pembayaran'] ?? ''),
            (string) ($row['kode_pesanan'] ?? ''),
            (string) ($row['buyer_name'] ?? ''),
            (string) ($row['buyer_email'] ?? ''),
        ]));

        return str_contains($haystack, $q);
    }));

    usort($rows, static function (array $a, array $b): int {
        return strcmp((string) ($b['tanggal_upload_bukti'] ?? ''), (string) ($a['tanggal_upload_bukti'] ?? ''));
    });

    return $rows;
}

function admin_payment_verification_by_id(int $paymentId): ?array
{
    foreach (admin_payment_verifications() as $row) {
        if ((int) ($row['id_pembayaran'] ?? 0) === $paymentId) {
            return $row;
        }
    }

    return null;
}

function admin_payment_verification_action(int $paymentId, string $decision, string $note, string $actor): array
{
    $payment = admin_payment_verification_by_id($paymentId);
    if ($payment === null) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Data pembayaran tidak ditemukan.'];
    }

    $decision = strtolower(trim($decision));
    if (!in_array($decision, ['approve', 'reject'], true)) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Aksi verifikasi tidak valid.'];
    }

    $now = gmdate('c');
    $paymentStatus = $decision === 'approve' ? 'Terverifikasi' : 'Ditolak';
    $orderStatus = $decision === 'approve' ? 'Diproses' : 'Menunggu Pembayaran';

    $paymentUpdate = supabase_update('pembayaran', [
        'status_pembayaran' => $paymentStatus,
        'catatan_verifikasi' => $note,
        'diverifikasi_oleh' => $actor,
        'tanggal_verifikasi' => $now,
        'tanggal_bayar' => $decision === 'approve' ? $now : null,
        'updated_at' => $now,
    ], [
        'id_pembayaran' => 'eq.' . $paymentId,
    ]);

    if ($paymentUpdate === [] && supabase_last_error() !== null) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Gagal memperbarui pembayaran: ' . supabase_last_error()];
    }

    $orderUpdate = supabase_update('pesanan', [
        'status_pesanan' => $orderStatus,
        'updated_at' => $now,
    ], [
        'id_pesanan' => 'eq.' . (int) ($payment['id_pesanan'] ?? 0),
    ]);

    if ($orderUpdate === [] && supabase_last_error() !== null) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Gagal memperbarui status pesanan: ' . supabase_last_error()];
    }

    if ($decision === 'approve' && strtolower((string) ($payment['payment_status'] ?? '')) !== 'terverifikasi') {
        foreach (($payment['items'] ?? []) as $item) {
            $productId = (int) ($item['id_produk'] ?? 0);
            $qty = (int) ($item['jumlah'] ?? 0);
            $currentStock = (int) ($item['stok_produk'] ?? 0);
            if ($productId <= 0 || $qty <= 0) {
                continue;
            }

            supabase_update('produk', [
                'stok' => max(0, $currentStock - $qty),
                'updated_at' => $now,
            ], [
                'id_produk' => 'eq.' . $productId,
            ]);
        }
    }

    return [
        'success' => true,
        'type' => 'success',
        'message' => $decision === 'approve'
            ? 'Pembayaran berhasil diverifikasi dan pesanan diteruskan ke seller.'
            : 'Pembayaran ditolak. User perlu mengunggah ulang bukti pembayaran.',
    ];
}

function admin_payment_dataset(): array
{
    $payments = supabase_fetch('pembayaran', '*', ['order' => 'created_at.desc']);
    $orders = supabase_fetch('pesanan', '*');
    $profiles = supabase_fetch('profiles', '*');
    $addresses = supabase_fetch('alamat', '*');
    $details = supabase_fetch('detail_pesanan', '*');
    $products = supabase_fetch('produk', 'id_produk,nama_produk,stok');

    $ordersById = [];
    foreach ($orders as $row) {
        if (!is_array($row)) {
            continue;
        }
        $ordersById[(int) ($row['id_pesanan'] ?? 0)] = $row;
    }

    $profilesById = [];
    foreach ($profiles as $row) {
        if (!is_array($row)) {
            continue;
        }
        $profilesById[(string) ($row['id'] ?? '')] = $row;
    }

    $addressesById = [];
    foreach ($addresses as $row) {
        if (!is_array($row)) {
            continue;
        }
        $addressesById[(int) ($row['id_alamat'] ?? 0)] = $row;
    }

    $productsById = [];
    foreach ($products as $row) {
        if (!is_array($row)) {
            continue;
        }
        $productsById[(int) ($row['id_produk'] ?? 0)] = $row;
    }

    $detailsByOrder = [];
    foreach ($details as $row) {
        if (!is_array($row)) {
            continue;
        }
        $orderId = (int) ($row['id_pesanan'] ?? 0);
        if ($orderId <= 0) {
            continue;
        }
        $productId = (int) ($row['id_produk'] ?? 0);
        $product = $productsById[$productId] ?? [];
        $detailsByOrder[$orderId][] = [
            ...$row,
            'nama_produk' => (string) ($product['nama_produk'] ?? ('Produk #' . $productId)),
            'stok_produk' => (int) ($product['stok'] ?? 0),
        ];
    }

    return [$payments, $ordersById, $profilesById, $addressesById, $detailsByOrder];
}

function admin_payment_address_text(array $address): string
{
    if ($address === []) {
        return '-';
    }

    $parts = array_filter([
        (string) ($address['jalan'] ?? ''),
        (string) ($address['kelurahan'] ?? ''),
        (string) ($address['kecamatan'] ?? ''),
        (string) ($address['kota'] ?? ''),
        (string) ($address['provinsi'] ?? ''),
        (string) ($address['kode_pos'] ?? ''),
    ], static fn (string $value): bool => trim($value) !== '');

    $addressText = implode(', ', $parts);
    $landmark = trim((string) ($address['patokan'] ?? ''));
    if ($landmark !== '') {
        $addressText .= ($addressText !== '' ? "\nPatokan: " : 'Patokan: ') . $landmark;
    }

    return $addressText !== '' ? $addressText : '-';
}
