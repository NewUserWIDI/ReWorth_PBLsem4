<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';

// ==================== HELPER PAGINATION ====================

function admin_paginate(array $rows, int $page, int $perPage = 10): array
{
    $page = max(1, $page);
    $perPage = max(1, $perPage);
    $total = count($rows);
    $totalPages = max(1, (int) ceil($total / $perPage));
    $slice = array_slice($rows, ($page - 1) * $perPage, $perPage);

    return [
        'items' => $slice,
        'page' => min($page, $totalPages),
        'per_page' => $perPage,
        'total' => $total,
        'total_pages' => $totalPages,
    ];
}

// ==================== USER MANAGEMENT ====================

function admin_users(array $filters = []): array
{
    $query = ['select' => '*'];
    
    if (!empty($filters['role']) && $filters['role'] !== 'semua') {
        $roleMap = [
            'masyarakat' => 'user',
            'admin' => 'admin',
            'dlh' => 'dlh',
            'seller' => 'seller',
        ];
        $dbRole = $roleMap[$filters['role']] ?? $filters['role'];
        $query['role'] = 'eq.' . $dbRole;
    }
    
    if (!empty($filters['q'])) {
        $query['or'] = '(nama_lengkap.ilike.%' . $filters['q'] . '%,email.ilike.%' . $filters['q'] . '%)';
    }
    
    $result = supabase_fetch('profiles', '*', $query);
    
    if (!is_array($result)) {
        return [];
    }
    
    return array_map(function ($user) {
        return [
            'id_user' => substr($user['id'] ?? '', 0, 8) . '...',
            'nama' => $user['nama_lengkap'] ?? $user['nama'] ?? '-',
            'email' => $user['email'] ?? '-',
            'role' => ($user['role'] ?? 'user') === 'user' ? 'masyarakat' : ($user['role'] ?? 'masyarakat'),
            'status' => 'aktif',
            'tanggal_bergabung' => format_date($user['created_at'] ?? null),
            'total_laporan' => (int) ($user['total_laporan_valid'] ?? 0),
            'total_poin' => (int) ($user['total_poin'] ?? 0),
        ];
    }, $result);
}

function admin_user_by_id(string $id): ?array
{
    $result = supabase_fetch('profiles', '*', ['id' => 'eq.' . $id, 'limit' => 1]);
    
    if (empty($result) || !is_array($result)) {
        return null;
    }
    
    $user = $result[0];
    return [
        'id_user' => $user['id'] ?? '',
        'nama' => $user['nama_lengkap'] ?? $user['nama'] ?? '-',
        'email' => $user['email'] ?? '-',
        'role' => ($user['role'] ?? 'user') === 'user' ? 'masyarakat' : ($user['role'] ?? 'masyarakat'),
        'status' => 'aktif',
        'tanggal_bergabung' => format_date($user['created_at'] ?? null),
        'total_laporan' => (int) ($user['total_laporan_valid'] ?? 0),
        'total_poin' => (int) ($user['total_poin'] ?? 0),
        'no_telp' => $user['no_telp'] ?? '-',
        'foto_profil' => $user['foto_profil'] ?? null,
        'status_pengajuan_seller' => $user['status_pengajuan_seller'] ?? 'Belum Daftar',
    ];
}

// ==================== SELLER MANAGEMENT ====================

function admin_sellers(array $filters = []): array
{
    $result = [];
    
    $sellerQuery = ['select' => '*'];
    
    if (!empty($filters['status_verifikasi']) && $filters['status_verifikasi'] === 'terverifikasi') {
        $sellerQuery['status_verifikasi'] = 'eq.Disetujui';
    }
    
    if (!empty($filters['status_toko']) && $filters['status_toko'] === 'aktif') {
        $sellerQuery['aktif'] = 'eq.true';
    }
    if (!empty($filters['status_toko']) && $filters['status_toko'] === 'nonaktif') {
        $sellerQuery['aktif'] = 'eq.false';
    }
    
    $verifiedSellers = supabase_fetch('seller', '*', $sellerQuery);
    
    if (is_array($verifiedSellers)) {
        foreach ($verifiedSellers as $seller) {
            $profile = supabase_fetch_one('profiles', 'nama_lengkap,email', ['id' => 'eq.' . $seller['id_masyarakat']]);
            $isActive = ($seller['aktif'] ?? true);
            
            $result[] = [
                'id_seller' => (string) ($seller['id_seller'] ?? ''),
                'nama_toko' => $seller['nama_toko'] ?? '-',
                'pemilik' => is_array($profile) ? ($profile['nama_lengkap'] ?? '-') : '-',
                'email' => is_array($profile) ? ($profile['email'] ?? '-') : '-',
                'jumlah_produk' => count_produk_by_seller($seller['id_masyarakat']),
                'status_verifikasi' => $isActive ? 'terverifikasi' : 'nonaktif',
                'status_toko' => $isActive ? 'aktif' : 'nonaktif',
                'tanggal_bergabung' => format_date($seller['tanggal_disetujui'] ?? $seller['created_at'] ?? null),
                'alasan_penolakan' => '',
                'is_pengajuan' => false,
            ];
        }
    }
    
    $pendingQuery = ['select' => '*', 'status_pengajuan' => 'eq.Pending'];
    
    if (!empty($filters['q'])) {
        $pendingQuery['or'] = '(nama_toko_usulan.ilike.%' . $filters['q'] . '%,username_usulan.ilike.%' . $filters['q'] . '%)';
    }
    
    $pendingSellers = supabase_fetch('pengajuan_seller', '*', $pendingQuery);
    
    if (is_array($pendingSellers)) {
        foreach ($pendingSellers as $pengajuan) {
            $profile = supabase_fetch_one('profiles', 'nama_lengkap,email', ['id' => 'eq.' . $pengajuan['id_masyarakat']]);
            
            $result[] = [
                'id_seller' => 'PEN-' . ($pengajuan['id_pengajuan'] ?? ''),
                'nama_toko' => $pengajuan['nama_toko_usulan'] ?? '-',
                'pemilik' => is_array($profile) ? ($profile['nama_lengkap'] ?? '-') : '-',
                'email' => is_array($profile) ? ($profile['email'] ?? '-') : '-',
                'jumlah_produk' => 0,
                'status_verifikasi' => 'menunggu',
                'status_toko' => 'pending',
                'tanggal_bergabung' => format_date($pengajuan['tanggal_pengajuan'] ?? null),
                'alasan_penolakan' => $pengajuan['alasan_penolakan'] ?? '',
                'is_pengajuan' => true,
                'id_pengajuan' => $pengajuan['id_pengajuan'],
            ];
        }
    }
    
    if (!empty($filters['q'])) {
        $q = strtolower($filters['q']);
        $result = array_filter($result, function($item) use ($q) {
            return str_contains(strtolower($item['nama_toko']), $q) ||
                   str_contains(strtolower($item['pemilik']), $q) ||
                   str_contains(strtolower($item['email']), $q);
        });
    }
    
    if (!empty($filters['status_verifikasi']) && $filters['status_verifikasi'] !== 'semua') {
        $result = array_filter($result, function($item) use ($filters) {
            return $item['status_verifikasi'] === $filters['status_verifikasi'];
        });
    }
    
    if (!empty($filters['status_toko']) && $filters['status_toko'] !== 'semua') {
        $result = array_filter($result, function($item) use ($filters) {
            return $item['status_toko'] === $filters['status_toko'];
        });
    }
    
    return array_values($result);
}

function count_produk_by_seller(string $sellerId): int
{
    $products = supabase_fetch('produk', 'id_produk', ['id_seller' => 'eq.' . $sellerId]);
    return is_array($products) ? count($products) : 0;
}

function admin_seller_by_id(string $id): ?array
{
    if (str_starts_with($id, 'PEN-')) {
        $pengajuanId = (int) str_replace('PEN-', '', $id);
        $pengajuan = supabase_fetch_one('pengajuan_seller', '*', ['id_pengajuan' => 'eq.' . $pengajuanId]);
        
        if (!$pengajuan || !is_array($pengajuan)) {
            return null;
        }
        
        $profile = supabase_fetch_one('profiles', '*', ['id' => 'eq.' . $pengajuan['id_masyarakat']]);
        
        return [
            'id_seller' => 'PEN-' . $pengajuan['id_pengajuan'],
            'id_pengajuan' => $pengajuan['id_pengajuan'],
            'id_masyarakat' => $pengajuan['id_masyarakat'],
            'nama_toko' => $pengajuan['nama_toko_usulan'] ?? '-',
            'deskripsi_toko' => $pengajuan['deskripsi_toko'] ?? '',
            'alamat_toko' => $pengajuan['alamat_toko'] ?? '',
            'foto_toko' => $pengajuan['foto_toko'] ?? null,
            'pemilik' => is_array($profile) ? ($profile['nama_lengkap'] ?? '-') : '-',
            'email' => is_array($profile) ? ($profile['email'] ?? '-') : '-',
            'no_telp' => is_array($profile) ? ($profile['no_telp'] ?? '-') : '-',
            'status_verifikasi' => 'menunggu',
            'status_toko' => 'pending',
            'tanggal_bergabung' => format_date($pengajuan['tanggal_pengajuan'] ?? null),
            'alasan_penolakan' => $pengajuan['alasan_penolakan'] ?? '',
            'username_usulan' => $pengajuan['username_usulan'] ?? '',
            'kategori_jualan' => $pengajuan['kategori_jualan'] ?? '',
            'jenis_produk_jualan' => $pengajuan['jenis_produk_jualan'] ?? '',
            'is_pengajuan' => true,
        ];
    }
    
    $seller = supabase_fetch_one('seller', '*', ['id_seller' => 'eq.' . $id]);
    
    if (!$seller && strpos($id, '-') !== false) {
        $seller = supabase_fetch_one('seller', '*', ['id_masyarakat' => 'eq.' . $id]);
    }
    
    if (!$seller || !is_array($seller)) {
        return null;
    }
    
    $profile = supabase_fetch_one('profiles', '*', ['id' => 'eq.' . $seller['id_masyarakat']]);
    
    return [
        'id_seller' => (string) ($seller['id_seller'] ?? ''),
        'id_masyarakat' => $seller['id_masyarakat'] ?? '',
        'nama_toko' => $seller['nama_toko'] ?? '-',
        'deskripsi_toko' => $seller['deskripsi_toko'] ?? '',
        'alamat_toko' => $seller['alamat_toko'] ?? '',
        'foto_toko' => $seller['foto_toko'] ?? null,
        'pemilik' => is_array($profile) ? ($profile['nama_lengkap'] ?? '-') : '-',
        'email' => is_array($profile) ? ($profile['email'] ?? '-') : '-',
        'no_telp' => is_array($profile) ? ($profile['no_telp'] ?? '-') : '-',
        'status_verifikasi' => map_verification_status($seller['status_verifikasi'] ?? 'Pending'),
        'status_toko' => ($seller['aktif'] ?? true) ? 'aktif' : 'nonaktif',
        'tanggal_bergabung' => format_date($seller['tanggal_disetujui'] ?? $seller['created_at'] ?? null),
        'alasan_penolakan' => $seller['alasan_penolakan'] ?? '',
        'username_dashboard' => $seller['username_dashboard'] ?? '',
        'is_pengajuan' => false,
    ];
}

// ==================== PRODUCT MANAGEMENT ====================

function admin_products(array $filters = []): array
{
    $query = ['select' => '*'];
    
    if (!empty($filters['status_produk']) && $filters['status_produk'] !== 'semua') {
        $query['status_produk'] = 'eq.' . $filters['status_produk'];
    }
    
    if (!empty($filters['kategori']) && $filters['kategori'] !== 'semua') {
        $query['id_kategori'] = 'eq.' . $filters['kategori'];
    }
    
    if (!empty($filters['q'])) {
        $query['or'] = '(nama_produk.ilike.%' . $filters['q'] . '%,deskripsi.ilike.%' . $filters['q'] . '%)';
    }
    
    $products = supabase_fetch('produk', '*', $query);
    
    if (!is_array($products)) {
        return [];
    }
    
    $result = [];
    foreach ($products as $product) {
        $seller = supabase_fetch_one('profiles', 'nama_lengkap', ['id' => 'eq.' . $product['id_seller']]);
        $kategori = supabase_fetch_one('kategori_produk', 'nama_kategori', ['id_kategori' => 'eq.' . ($product['id_kategori'] ?? 0)]);
        
        $result[] = [
            'id_produk' => (string) ($product['id_produk'] ?? ''),
            'foto' => get_product_primary_image($product['id_produk']),
            'nama_produk' => $product['nama_produk'] ?? '-',
            'seller' => is_array($seller) ? ($seller['nama_lengkap'] ?? '-') : '-',
            'kategori' => is_array($kategori) ? ($kategori['nama_kategori'] ?? '-') : '-',
            'harga' => (int) ($product['harga'] ?? 0),
            'stok' => (int) ($product['stok'] ?? 0),
            'status_produk' => $product['status_produk'] ?? 'draft',
            'tanggal_dibuat' => format_date($product['created_at'] ?? null),
        ];
    }
    
    return $result;
}

function admin_product_by_id(string $id): ?array
{
    $product = supabase_fetch_one('produk', '*', ['id_produk' => 'eq.' . $id]);
    
    if (!$product || !is_array($product)) {
        return null;
    }
    
    $seller = supabase_fetch_one('profiles', 'nama_lengkap,email,no_telp', ['id' => 'eq.' . $product['id_seller']]);
    
    return [
        'id_produk' => (string) ($product['id_produk'] ?? ''),
        'nama_produk' => $product['nama_produk'] ?? '-',
        'deskripsi' => $product['deskripsi'] ?? '',
        'harga' => (int) ($product['harga'] ?? 0),
        'stok' => (int) ($product['stok'] ?? 0),
        'berat_gram' => (int) ($product['berat_gram'] ?? 0),
        'status_produk' => $product['status_produk'] ?? 'draft',
        'rating' => (float) ($product['rating'] ?? 0),
        'seller' => is_array($seller) ? ($seller['nama_lengkap'] ?? '-') : '-',
        'seller_email' => is_array($seller) ? ($seller['email'] ?? '-') : '-',
        'tanggal_dibuat' => format_date($product['created_at'] ?? null),
        'gambar' => get_product_images($product['id_produk']),
    ];
}

function get_product_primary_image(int $productId): string
{
    $image = supabase_fetch_one('gambar_produk', 'public_url', [
        'id_produk' => 'eq.' . $productId,
        'is_primary' => 'eq.true',
        'limit' => 1
    ]);
    
    return (is_array($image) && isset($image['public_url'])) ? $image['public_url'] : 'assets/logo_reworth.jpeg';
}

function get_product_images(int $productId): array
{
    $images = supabase_fetch('gambar_produk', 'public_url', [
        'id_produk' => 'eq.' . $productId
    ]);
    
    return is_array($images) ? array_column($images, 'public_url') : [];
}

// ==================== TRANSACTION MANAGEMENT ====================

function admin_transactions(array $filters = []): array
{
    // Ambil semua data dari database
    $orders = supabase_fetch('pesanan', '*', ['order' => 'tanggal_pesanan.desc']);
    
    if (!is_array($orders)) {
        return [];
    }
    
    $result = [];
    foreach ($orders as $order) {
        // Ambil data pembeli
        $buyer = supabase_fetch_one('profiles', 'nama_lengkap', ['id' => 'eq.' . $order['id_masyarakat']]);
        
        // Ambil seller dari detail pesanan
        $detail = supabase_fetch_one('detail_pesanan', 'id_seller', ['id_pesanan' => 'eq.' . $order['id_pesanan'], 'limit' => 1]);
        $seller = null;
        if (is_array($detail) && isset($detail['id_seller'])) {
            $sellerProfile = supabase_fetch_one('profiles', 'nama_lengkap', ['id' => 'eq.' . $detail['id_seller']]);
            $seller = is_array($sellerProfile) ? ($sellerProfile['nama_lengkap'] ?? '-') : '-';
        }
        
        $result[] = [
            'id_transaksi' => $order['kode_pesanan'] ?? 'INV-' . $order['id_pesanan'],
            'kode_pesanan' => $order['kode_pesanan'] ?? '-',
            'pembeli' => is_array($buyer) ? ($buyer['nama_lengkap'] ?? '-') : '-',
            'seller' => $seller ?? '-',
            'total' => (int) ($order['total_bayar'] ?? 0),
            'status' => map_order_status($order['status_pesanan'] ?? 'Aktif'),
            'tanggal' => format_date($order['tanggal_pesanan'] ?? null, 'Y-m-d'),
            // Simpan data mentah untuk filter
            '_status_raw' => strtolower($order['status_pesanan'] ?? ''),
            '_tanggal_raw' => substr($order['tanggal_pesanan'] ?? '', 0, 10),
            '_kode_raw' => strtolower($order['kode_pesanan'] ?? ''),
            '_id_raw' => (string) $order['id_pesanan'],
            '_pembeli_raw' => strtolower(is_array($buyer) ? ($buyer['nama_lengkap'] ?? '') : ''),
        ];
    }
    
    // ========== TERAPKAN FILTER ==========
    $filtered = $result;
    
    // Filter status
    if (!empty($filters['status']) && $filters['status'] !== 'semua') {
        $filterStatus = strtolower($filters['status']);
        $filtered = array_filter($filtered, function($item) use ($filterStatus) {
            return str_contains($item['_status_raw'], $filterStatus);
        });
    }
    
    // Filter tanggal dari
    if (!empty($filters['date_from'])) {
        $filtered = array_filter($filtered, function($item) use ($filters) {
            return $item['_tanggal_raw'] >= $filters['date_from'];
        });
    }
    
    // Filter tanggal sampai
    if (!empty($filters['date_to'])) {
        $filtered = array_filter($filtered, function($item) use ($filters) {
            return $item['_tanggal_raw'] <= $filters['date_to'];
        });
    }
    
    // Filter pencarian (q)
    if (!empty($filters['q'])) {
        $q = strtolower($filters['q']);
        $filtered = array_filter($filtered, function($item) use ($q) {
            return str_contains($item['_kode_raw'], $q) || 
                   str_contains($item['_id_raw'], $q) ||
                   str_contains($item['_pembeli_raw'], $q);
        });
    }
    
    // Hapus data mentah sebelum dikembalikan
    $filtered = array_map(function($item) {
        unset($item['_status_raw'], $item['_tanggal_raw'], $item['_kode_raw'], $item['_id_raw'], $item['_pembeli_raw']);
        return $item;
    }, $filtered);
    
    return array_values($filtered);
}

function admin_transaction_by_id(string $id): ?array
{
    $order = supabase_fetch_one('pesanan', '*', ['id_pesanan' => 'eq.' . $id]);
    if (!$order || !is_array($order)) {
        $order = supabase_fetch_one('pesanan', '*', ['kode_pesanan' => 'eq.' . $id]);
    }
    
    if (!$order || !is_array($order)) {
        return null;
    }
    
    $buyer = supabase_fetch_one('profiles', 'nama_lengkap,email,no_telp', ['id' => 'eq.' . $order['id_masyarakat']]);
    $alamat = supabase_fetch_one('alamat', '*', ['id_alamat' => 'eq.' . $order['id_alamat']]);
    $payment = supabase_fetch_one('pembayaran', '*', ['id_pesanan' => 'eq.' . $order['id_pesanan']]);
    $details = supabase_fetch('detail_pesanan', '*', ['id_pesanan' => 'eq.' . $order['id_pesanan']]);
    
    $items = [];
    if (is_array($details)) {
        foreach ($details as $detail) {
            $product = supabase_fetch_one('produk', 'nama_produk,harga', ['id_produk' => 'eq.' . $detail['id_produk']]);
            $seller = supabase_fetch_one('profiles', 'nama_lengkap', ['id' => 'eq.' . $detail['id_seller']]);
            
            $items[] = [
                'nama_produk' => is_array($product) ? ($product['nama_produk'] ?? '-') : '-',
                'jumlah' => $detail['jumlah'],
                'harga_satuan' => (int) ($detail['harga_satuan'] ?? 0),
                'subtotal' => (int) ($detail['subtotal'] ?? 0),
                'seller' => is_array($seller) ? ($seller['nama_lengkap'] ?? '-') : '-',
            ];
        }
    }
    
    return [
        'id_transaksi' => $order['kode_pesanan'] ?? 'INV-' . $order['id_pesanan'],
        'kode_pesanan' => $order['kode_pesanan'] ?? '-',
        'pembeli' => [
            'nama' => is_array($buyer) ? ($buyer['nama_lengkap'] ?? '-') : '-',
            'email' => is_array($buyer) ? ($buyer['email'] ?? '-') : '-',
            'no_telp' => is_array($buyer) ? ($buyer['no_telp'] ?? '-') : '-',
        ],
        'alamat' => [
            'jalan' => is_array($alamat) ? ($alamat['jalan'] ?? '') : '',
            'kelurahan' => is_array($alamat) ? ($alamat['kelurahan'] ?? '') : '',
            'kecamatan' => is_array($alamat) ? ($alamat['kecamatan'] ?? '') : '',
            'kota' => is_array($alamat) ? ($alamat['kota'] ?? '') : '',
            'kode_pos' => is_array($alamat) ? ($alamat['kode_pos'] ?? '') : '',
            'penerima' => is_array($alamat) ? ($alamat['nama_penerima'] ?? '') : '',
        ],
        'items' => $items,
        'subtotal' => (int) ($order['subtotal'] ?? 0),
        'biaya_pengiriman' => (int) ($order['biaya_pengiriman'] ?? 0),
        'pajak' => (int) ($order['pajak'] ?? 0),
        'total_bayar' => (int) ($order['total_bayar'] ?? 0),
        'status' => map_order_status($order['status_pesanan'] ?? 'Aktif'),
        'tanggal_pesanan' => format_date($order['tanggal_pesanan'] ?? null),
        'pembayaran' => [
            'status' => is_array($payment) ? ($payment['status_pembayaran'] ?? 'Belum Upload') : 'Belum Upload',
            'metode' => is_array($payment) ? ($payment['metode_pembayaran'] ?? '-') : '-',
            'tanggal_bayar' => format_date(is_array($payment) ? ($payment['tanggal_bayar'] ?? null) : null),
            'bukti_url' => is_array($payment) ? ($payment['bukti_pembayaran_url'] ?? null) : null,
        ],
    ];
}

// ==================== DASHBOARD OVERVIEW ====================

function admin_overview(): array
{
    $users = supabase_fetch('profiles', 'id');
    $totalUser = is_array($users) ? count($users) : 0;
    
    $sellers = supabase_fetch('seller', 'id_seller');
    $totalSeller = is_array($sellers) ? count($sellers) : 0;
    
    $reports = supabase_fetch('laporan_sampah', 'id_laporan');
    $totalLaporan = is_array($reports) ? count($reports) : 0;
    
    $orders = supabase_fetch('pesanan', 'id_pesanan');
    $totalTransaksi = is_array($orders) ? count($orders) : 0;
    
    $ordersWithTotal = supabase_fetch('pesanan', 'total_bayar');
    $totalPendapatan = 0;
    if (is_array($ordersWithTotal)) {
        $totalPendapatan = array_sum(array_column($ordersWithTotal, 'total_bayar'));
    }
    
    return [
        'total_user' => $totalUser,
        'total_seller' => $totalSeller,
        'total_laporan_sampah' => $totalLaporan,
        'total_transaksi' => $totalTransaksi,
        'total_pendapatan' => (int) $totalPendapatan,
    ];
}

// ==================== SYSTEM ACTIVITIES ====================

function admin_activities(array $filters = []): array
{
    $query = ['select' => '*', 'order' => 'tanggal.desc', 'limit' => '50'];
    
    if (!empty($filters['date_from'])) {
        $query['tanggal'] = 'gte.' . $filters['date_from'];
    }
    if (!empty($filters['date_to'])) {
        $query['tanggal'] = 'lte.' . $filters['date_to'] . ' 23:59:59';
    }
    
    $poinHistory = supabase_fetch('riwayat_poin', '*,profiles(nama_lengkap)', $query);
    
    $activities = [];
    if (is_array($poinHistory)) {
        foreach ($poinHistory as $history) {
            $profile = $history['profiles'] ?? [];
            $activities[] = [
                'waktu' => format_date($history['tanggal'] ?? null),
                'aktor' => is_array($profile) ? ($profile['nama_lengkap'] ?? '-') : '-',
                'role' => 'Masyarakat',
                'aktivitas' => 'Poin ' . ($history['jenis_transaksi'] ?? ''),
                'modul' => 'Rewards',
                'detail' => $history['keterangan'] ?? ($history['sumber_poin'] ?? 'Transaksi poin'),
            ];
        }
    }
    
    usort($activities, fn($a, $b) => strtotime($b['waktu']) - strtotime($a['waktu']));
    
    if (!empty($filters['q'])) {
        $q = strtolower($filters['q']);
        $activities = array_filter($activities, fn($act) => 
            str_contains(strtolower($act['aktor']), $q) || 
            str_contains(strtolower($act['aktivitas']), $q)
        );
    }
    
    return array_values($activities);
}

// ==================== HELPER FUNCTIONS ====================

function format_date($date, string $format = 'Y-m-d H:i:s'): string
{
    if (!$date) {
        return '-';
    }
    try {
        $timestamp = is_numeric($date) ? (int) $date : strtotime((string) $date);
        return date($format, $timestamp);
    } catch (Exception $e) {
        return '-';
    }
}

function map_role_display(string $role): string
{
    return match ($role) {
        'admin' => 'admin',
        'dlh' => 'dlh',
        'seller' => 'seller',
        'user' => 'masyarakat',
        default => 'masyarakat',
    };
}

function map_verification_status(string $status): string
{
    return match ($status) {
        'Pending' => 'menunggu',
        'Disetujui' => 'terverifikasi',
        'Ditolak' => 'ditolak',
        default => 'menunggu',
    };
}

function map_order_status(string $status): string
{
    $statusLower = strtolower(trim($status));
    
    return match ($statusLower) {
        'aktif', 'pending', 'menunggu pembayaran', 'menunggu verifikasi' => 'pending',
        'diproses' => 'diproses',
        'selesai', 'completed' => 'selesai',
        'ditolak', 'dibatalkan', 'cancelled' => 'ditolak',
        default => 'pending',
    };
}

function admin_unique_values(array $rows, string $field): array
{
    if (!is_array($rows)) {
        return [];
    }
    $values = array_values(array_unique(array_map(fn (array $row): string => (string) ($row[$field] ?? ''), $rows)));
    $values = array_values(array_filter($values, fn (string $value): bool => $value !== ''));
    sort($values);
    return $values;
}

// function admin_illustration_path(): string
// {
//     return 'assets/illustration_admin.svg';
// }


