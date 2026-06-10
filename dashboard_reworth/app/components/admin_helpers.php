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

function admin_now(): DateTimeImmutable
{
    return new DateTimeImmutable('now');
}

function admin_today_start(): string
{
    return admin_now()->setTime(0, 0, 0)->format('Y-m-d\TH:i:s');
}

function admin_tomorrow_start(): string
{
    return admin_now()->modify('+1 day')->setTime(0, 0, 0)->format('Y-m-d\TH:i:s');
}

function admin_week_start(): string
{
    return admin_now()->modify('monday this week')->setTime(0, 0, 0)->format('Y-m-d\TH:i:s');
}

function admin_count_rows(string $table, string $idColumn = 'id', array $query = []): int
{
    return supabase_count($table, $idColumn, $query);
}

function admin_sum_column(string $table, string $column, array $query = []): int
{
    $rows = supabase_fetch($table, $column, $query);

    if (!is_array($rows)) {
        return 0;
    }

    return (int) array_sum(array_map(
        static fn (array $row): int => (int) ($row[$column] ?? 0),
        array_filter($rows, static fn ($row): bool => is_array($row))
    ));
}

function admin_count_recent(string $table, string $dateColumn, string $startIso, ?string $endIso = null, array $query = []): int
{
    $rows = supabase_fetch($table, $dateColumn, $query);

    if (!is_array($rows)) {
        return 0;
    }

    $startTs = strtotime($startIso) ?: 0;
    $endTs = $endIso !== null ? (strtotime($endIso) ?: 0) : null;

    return count(array_filter($rows, static function ($row) use ($dateColumn, $startTs, $endTs): bool {
        if (!is_array($row)) {
            return false;
        }

        $value = (string) ($row[$dateColumn] ?? '');
        $timestamp = strtotime($value);
        if ($timestamp === false) {
            return false;
        }

        if ($timestamp < $startTs) {
            return false;
        }

        if ($endTs !== null && $timestamp >= $endTs) {
            return false;
        }

        return true;
    }));
}

function admin_revenue_from_orders(array $orders, ?string $startIso = null, ?string $endIso = null): int
{
    $startTs = $startIso !== null ? (strtotime($startIso) ?: 0) : null;
    $endTs = $endIso !== null ? (strtotime($endIso) ?: 0) : null;
    $totalRevenue = 0.0;

    foreach ($orders as $order) {
        if (!is_array($order)) {
            continue;
        }

        $status = strtolower(trim((string) ($order['status_pesanan'] ?? '')));
        if (in_array($status, ['dibatalkan', 'cancelled', 'ditolak', 'gagal'], true)) {
            continue;
        }

        if ($startTs !== null) {
            $dateValue = (string) ($order['tanggal_pesanan'] ?? $order['created_at'] ?? '');
            $timestamp = strtotime($dateValue);
            if ($timestamp === false) {
                continue;
            }
            if ($timestamp < $startTs) {
                continue;
            }
            if ($endTs !== null && $timestamp >= $endTs) {
                continue;
            }
        }

        $feePlatform = null;
        if (isset($order['fee_platform']) && is_numeric($order['fee_platform'])) {
            $feePlatform = (float) $order['fee_platform'];
        } elseif (isset($order['subtotal_produk']) && is_numeric($order['subtotal_produk'])) {
            $feePlatform = (float) $order['subtotal_produk'] * 0.10;
        } elseif (isset($order['subtotal']) && is_numeric($order['subtotal'])) {
            $feePlatform = (float) $order['subtotal'] * 0.10;
        } elseif (isset($order['total_bayar']) && is_numeric($order['total_bayar'])) {
            $feePlatform = (float) $order['total_bayar'] * 0.10;
        }

        if ($feePlatform === null || $feePlatform <= 0) {
            continue;
        }

        $totalRevenue += $feePlatform;
    }

    return (int) round($totalRevenue);
}

// ==================== USER MANAGEMENT ====================

function admin_users(array $filters = []): array
{
    $query = ['select' => '*'];
    
    if (!empty($filters['role']) && $filters['role'] !== 'semua') {
        $normalizedRole = strtolower(trim((string) $filters['role']));
        if (in_array($normalizedRole, ['user', 'masyarakat'], true)) {
            $query['role'] = 'in.(user,masyarakat)';
        } else {
            $query['role'] = 'eq.' . $normalizedRole;
        }
    }
    
    if (!empty($filters['q'])) {
        $query['or'] = '(nama_lengkap.ilike.%' . $filters['q'] . '%,email.ilike.%' . $filters['q'] . '%)';
    }
    
    $result = supabase_fetch('profiles', '*', $query);
    
    if (!is_array($result)) {
        return [];
    }
    
    return array_map(function ($user) {
        $rawRole = strtolower(trim((string) ($user['role'] ?? 'user')));
        return [
            'id' => (string) ($user['id'] ?? ''),
            'id_user' => substr($user['id'] ?? '', 0, 8) . '...',
            'nama' => $user['nama_lengkap'] ?? $user['nama'] ?? '-',
            'email' => $user['email'] ?? '-',
            'no_telp' => $user['no_telp'] ?? $user['nomor_hp'] ?? '-',
            'role' => in_array($rawRole, ['user', 'masyarakat'], true) ? 'user' : $rawRole,
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
    $rawRole = strtolower(trim((string) ($user['role'] ?? 'user')));
    return [
        'id_user' => $user['id'] ?? '',
        'nama' => $user['nama_lengkap'] ?? $user['nama'] ?? '-',
        'email' => $user['email'] ?? '-',
        'no_telp' => $user['no_telp'] ?? $user['nomor_hp'] ?? '-',
        'role' => in_array($rawRole, ['user', 'masyarakat'], true) ? 'user' : $rawRole,
        'tanggal_bergabung' => format_date($user['created_at'] ?? null),
        'total_laporan' => (int) ($user['total_laporan_valid'] ?? 0),
        'total_poin' => (int) ($user['total_poin'] ?? 0),
        'foto_profil' => $user['foto_profil'] ?? null,
        'status_pengajuan_seller' => $user['status_pengajuan_seller'] ?? 'Belum Daftar',
        'laporan_valid' => (int) ($user['laporan_valid'] ?? 0),
        'setor_sampah_kg' => (float) ($user['setor_sampah_kg'] ?? 0),
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
            $profile = supabase_fetch_one('profiles', 'nama_lengkap,email,no_telp', ['id' => 'eq.' . $seller['id_masyarakat']]);
            $isActive = ($seller['aktif'] ?? true);
            
            $result[] = [
                'id_seller' => (string) ($seller['id_seller'] ?? ''),
                'nama_toko' => $seller['nama_toko'] ?? '-',
                'pemilik' => is_array($profile) ? ($profile['nama_lengkap'] ?? '-') : '-',
                'email' => is_array($profile) ? ($profile['email'] ?? '-') : '-',
                'no_telp' => is_array($profile) ? ($profile['no_telp'] ?? '-') : '-',
                'status_verifikasi' => $isActive ? 'terverifikasi' : 'nonaktif',
                'status_toko' => $isActive ? 'aktif' : 'nonaktif',
                'tanggal_bergabung' => format_date($seller['tanggal_disetujui'] ?? $seller['created_at'] ?? null),
                'alasan_penolakan' => '',
                'is_pengajuan' => false,
            ];
        }
    }

    if (!empty($filters['include_pending'])) {
        $pendingQuery = ['select' => '*', 'status_pengajuan' => 'eq.Pending'];

        if (!empty($filters['q'])) {
            $pendingQuery['or'] = '(nama_toko_usulan.ilike.%' . $filters['q'] . '%,username_usulan.ilike.%' . $filters['q'] . '%)';
        }

        $pendingSellers = supabase_fetch('pengajuan_seller', '*', $pendingQuery);

        if (is_array($pendingSellers)) {
            foreach ($pendingSellers as $pengajuan) {
                $profile = supabase_fetch_one('profiles', 'nama_lengkap,email,no_telp', ['id' => 'eq.' . $pengajuan['id_masyarakat']]);

                $result[] = [
                    'id_seller' => 'PEN-' . ($pengajuan['id_pengajuan'] ?? ''),
                    'nama_toko' => $pengajuan['nama_toko_usulan'] ?? '-',
                    'pemilik' => is_array($profile) ? ($profile['nama_lengkap'] ?? '-') : '-',
                    'email' => is_array($profile) ? ($profile['email'] ?? '-') : '-',
                    'no_telp' => is_array($profile) ? ($profile['no_telp'] ?? '-') : '-',
                    'status_verifikasi' => 'menunggu',
                    'status_toko' => 'pending',
                    'tanggal_bergabung' => format_date($pengajuan['tanggal_pengajuan'] ?? null),
                    'alasan_penolakan' => $pengajuan['alasan_penolakan'] ?? '',
                    'is_pengajuan' => true,
                    'id_pengajuan' => $pengajuan['id_pengajuan'],
                ];
            }
        }
    }
    
    if (!empty($filters['q'])) {
        $q = strtolower($filters['q']);
        $result = array_filter($result, function($item) use ($q) {
            return str_contains(strtolower($item['nama_toko']), $q) ||
                   str_contains(strtolower($item['pemilik']), $q) ||
                   str_contains(strtolower($item['email']), $q) ||
                   str_contains(strtolower((string) ($item['no_telp'] ?? '')), $q);
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
            'status_pengajuan' => (string) ($pengajuan['status_pengajuan'] ?? 'Pending'),
            'status_toko' => 'pending',
            'tanggal_bergabung' => format_date($pengajuan['tanggal_pengajuan'] ?? null),
            'tanggal_pengajuan' => format_date($pengajuan['tanggal_pengajuan'] ?? null),
            'tanggal_diproses' => format_date($pengajuan['tanggal_diproses'] ?? null),
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
    $pengajuan = null;
    if (!empty($seller['id_pengajuan'])) {
        $pengajuan = supabase_fetch_one('pengajuan_seller', '*', ['id_pengajuan' => 'eq.' . $seller['id_pengajuan']]);
    }
    
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
        'status_verifikasi_raw' => (string) ($seller['status_verifikasi'] ?? 'Pending'),
        'status_toko' => ($seller['aktif'] ?? true) ? 'aktif' : 'nonaktif',
        'tanggal_bergabung' => format_date($seller['tanggal_disetujui'] ?? $seller['created_at'] ?? null),
        'tanggal_disetujui' => format_date($seller['tanggal_disetujui'] ?? null),
        'tanggal_dibuat' => format_date($seller['created_at'] ?? null),
        'alasan_penolakan' => $seller['alasan_penolakan'] ?? '',
        'username_dashboard' => $seller['username_dashboard'] ?? '',
        'kategori_jualan' => is_array($pengajuan) ? (string) ($pengajuan['kategori_jualan'] ?? '') : '',
        'jenis_produk_jualan' => is_array($pengajuan) ? (string) ($pengajuan['jenis_produk_jualan'] ?? '') : '',
        'aktif' => (bool) ($seller['aktif'] ?? false),
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
    $todayStart = admin_today_start();
    $tomorrowStart = admin_tomorrow_start();
    $weekStart = admin_week_start();

    $totalUser = admin_count_rows('profiles', 'id', [
        'role' => 'in.(user,masyarakat)',
    ]);

    $newUsersToday = admin_count_recent('profiles', 'created_at', $todayStart, $tomorrowStart, [
        'role' => 'in.(user,masyarakat)',
    ]);

    $totalSeller = admin_count_rows('seller', 'id_seller');
    $newSellerWeek = admin_count_recent('seller', 'created_at', $weekStart);

    $totalLaporan = admin_count_rows('laporan_sampah', 'id_laporan');
    $newLaporanToday = admin_count_recent('laporan_sampah', 'waktu_lapor', $todayStart, $tomorrowStart);

    $totalTransaksi = admin_count_rows('pesanan', 'id_pesanan');
    $transaksiWeek = admin_count_recent('pesanan', 'tanggal_pesanan', $weekStart);

    $ordersForRevenue = supabase_fetch(
        'pesanan',
        'total_bayar,fee_platform,subtotal_produk,subtotal,status_pesanan,tanggal_pesanan,created_at',
        ['order' => 'tanggal_pesanan.desc']
    );
    if (!is_array($ordersForRevenue)) {
        $ordersForRevenue = [];
    }

    $totalPendapatan = admin_revenue_from_orders($ordersForRevenue);
    $pendapatanWeek = admin_revenue_from_orders($ordersForRevenue, $weekStart, null);

    return [
        'total_user' => $totalUser,
        'new_users_today' => $newUsersToday,
        'total_seller' => $totalSeller,
        'new_seller_week' => $newSellerWeek,
        'total_laporan_sampah' => $totalLaporan,
        'new_laporan_today' => $newLaporanToday,
        'total_transaksi' => $totalTransaksi,
        'transaksi_week' => $transaksiWeek,
        'total_pendapatan' => (int) $totalPendapatan,
        'pendapatan_week' => (int) $pendapatanWeek,
    ];
}

// ==================== SYSTEM ACTIVITIES ====================

function admin_month_start(): string
{
    return admin_now()->modify('first day of this month')->setTime(0, 0, 0)->format('Y-m-d\TH:i:s');
}

function admin_activity_in_filter(array $values): ?string
{
    $formatted = [];
    foreach ($values as $value) {
        if ($value === null || $value === '') {
            continue;
        }

        if (is_int($value) || is_float($value) || ctype_digit((string) $value)) {
            $formatted[] = (string) $value;
            continue;
        }

        $escaped = str_replace('"', '\"', (string) $value);
        $formatted[] = '"' . $escaped . '"';
    }

    if ($formatted === []) {
        return null;
    }

    return 'in.(' . implode(',', $formatted) . ')';
}

function admin_activity_time_value(?string $value): int
{
    if ($value === null || trim($value) === '') {
        return 0;
    }

    $timestamp = strtotime($value);
    return $timestamp === false ? 0 : $timestamp;
}

function admin_activity_role_label(string $role): string
{
    return match (strtolower(trim($role))) {
        'admin' => 'Admin',
        'dlh' => 'DLH',
        'seller' => 'Seller',
        'user', 'masyarakat' => 'Masyarakat',
        default => 'Sistem',
    };
}

function admin_activity_status_label(string $status): string
{
    $status = strtolower(trim($status));

    return match ($status) {
        'pending' => 'Menunggu',
        'processing', 'diproses' => 'Diproses',
        'completed', 'selesai' => 'Selesai',
        'disetujui', 'approved' => 'Disetujui',
        'ditolak', 'rejected' => 'Ditolak',
        'sukses', 'success' => 'Sukses',
        'gagal', 'failed' => 'Gagal',
        default => $status === '' ? '-' : ucfirst($status),
    };
}

function admin_activity_type_key(string $label): string
{
    return match ($label) {
        'Registrasi Akun' => 'registrasi',
        'Belanja Mini Market' => 'transaksi',
        'Pengajuan Seller' => 'pengajuan_seller',
        'Tukar Poin' => 'tukar_poin',
        'Lapor Sampah' => 'lapor_sampah',
        default => 'lainnya',
    };
}

function admin_activity_period_bounds(string $period): array
{
    $period = strtolower(trim($period));
    $start = null;

    if ($period === 'harian') {
        $start = admin_activity_time_value(admin_today_start());
    } elseif ($period === 'mingguan') {
        $start = admin_activity_time_value(admin_week_start());
    } elseif ($period === 'bulanan') {
        $start = admin_activity_time_value(admin_month_start());
    }

    return [
        'period' => in_array($period, ['harian', 'mingguan', 'bulanan'], true) ? $period : 'selamanya',
        'start' => $start,
        'end' => null,
    ];
}

function admin_activity_matches_period(int $timestamp, ?int $start, ?int $end): bool
{
    if ($timestamp <= 0) {
        return false;
    }

    if ($start !== null && $timestamp < $start) {
        return false;
    }

    if ($end !== null && $timestamp > $end) {
        return false;
    }

    return true;
}

function admin_activity_profiles_map(array $profileIds): array
{
    $profileIds = array_values(array_unique(array_filter(array_map(
        static fn ($id): string => trim((string) $id),
        $profileIds
    ))));

    if ($profileIds === []) {
        return [];
    }

    $filter = admin_activity_in_filter($profileIds);
    if ($filter === null) {
        return [];
    }

    $profiles = [];
    foreach (supabase_fetch('profiles', 'id,nama_lengkap,nama,email,no_telp,role', ['id' => $filter]) as $row) {
        if (!is_array($row)) {
            continue;
        }

        $profiles[(string) ($row['id'] ?? '')] = $row;
    }

    return $profiles;
}

function admin_activity_rewards_map(array $rewardIds): array
{
    $rewardIds = array_values(array_unique(array_filter(array_map(
        static fn ($id): int => (int) $id,
        $rewardIds
    ))));

    if ($rewardIds === []) {
        return [];
    }

    $filter = admin_activity_in_filter($rewardIds);
    if ($filter === null) {
        return [];
    }

    $rewards = [];
    foreach (supabase_fetch('reward', 'id_reward,nama_reward,jenis_reward,provider,nominal_reward', ['id_reward' => $filter]) as $row) {
        if (!is_array($row)) {
            continue;
        }

        $rewards[(int) ($row['id_reward'] ?? 0)] = $row;
    }

    return $rewards;
}

function admin_activity_actor_name(?array $profile, string $fallback = 'Pengguna ReWorth'): string
{
    if (!is_array($profile)) {
        return $fallback;
    }

    $name = trim((string) (($profile['nama_lengkap'] ?? $profile['nama'] ?? '') ?: ''));
    return $name !== '' ? $name : $fallback;
}

function admin_activities(array $filters = []): array
{
    $limit = max(1, (int) ($filters['limit'] ?? 100));
    $sourceLimit = max(30, min(500, $limit * 8));
    $periodBounds = admin_activity_period_bounds((string) ($filters['period'] ?? 'selamanya'));
    $startTs = $periodBounds['start'];
    $endTs = $periodBounds['end'];

    $dateFrom = trim((string) ($filters['date_from'] ?? ''));
    if ($dateFrom !== '') {
        $dateFromTs = admin_activity_time_value($dateFrom . ' 00:00:00');
        if ($dateFromTs > 0) {
            $startTs = $startTs !== null ? max($startTs, $dateFromTs) : $dateFromTs;
        }
    }

    $dateTo = trim((string) ($filters['date_to'] ?? ''));
    if ($dateTo !== '') {
        $dateToTs = admin_activity_time_value($dateTo . ' 23:59:59');
        if ($dateToTs > 0) {
            $endTs = $endTs !== null ? min($endTs, $dateToTs) : $dateToTs;
        }
    }

    $profileRows = supabase_fetch('profiles', 'id,nama_lengkap,nama,email,role,created_at', [
        'order' => 'created_at.desc',
        'limit' => (string) $sourceLimit,
    ]);
    $reportRows = supabase_fetch('laporan_sampah', 'id_laporan,id_masyarakat,deskripsi,status_laporan,kelurahan,kecamatan,waktu_lapor', [
        'order' => 'waktu_lapor.desc',
        'limit' => (string) $sourceLimit,
    ]);
    $orderRows = supabase_fetch('pesanan', 'id_pesanan,id_masyarakat,kode_pesanan,total_bayar,status_pesanan,tanggal_pesanan,created_at', [
        'order' => 'tanggal_pesanan.desc',
        'limit' => (string) $sourceLimit,
    ]);
    $sellerApplicationRows = supabase_fetch('pengajuan_seller', 'id_pengajuan,id_masyarakat,nama_toko_usulan,status_pengajuan,alasan_penolakan,tanggal_pengajuan,tanggal_diproses', [
        'order' => 'tanggal_pengajuan.desc',
        'limit' => (string) $sourceLimit,
    ]);
    $pointRedemptionRows = supabase_fetch('penukaran_poin', 'id_penukaran,id_masyarakat,id_reward,no_hp_tujuan,poin_terpakai,status_proses,kode_referensi,tanggal_penukaran,tanggal_diproses', [
        'order' => 'tanggal_penukaran.desc',
        'limit' => (string) $sourceLimit,
    ]);

    $profileIds = [];
    foreach ([$reportRows, $orderRows, $sellerApplicationRows, $pointRedemptionRows] as $rows) {
        foreach ($rows as $row) {
            if (is_array($row) && !empty($row['id_masyarakat'])) {
                $profileIds[] = (string) $row['id_masyarakat'];
            }
        }
    }
    foreach ($profileRows as $row) {
        if (is_array($row) && !empty($row['id'])) {
            $profileIds[] = (string) $row['id'];
        }
    }

    $rewardIds = [];
    foreach ($pointRedemptionRows as $row) {
        if (is_array($row) && !empty($row['id_reward'])) {
            $rewardIds[] = (int) $row['id_reward'];
        }
    }

    $profilesMap = admin_activity_profiles_map($profileIds);
    $rewardsMap = admin_activity_rewards_map($rewardIds);

    $activities = [];

    foreach ($profileRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $rawRole = strtolower(trim((string) ($row['role'] ?? '')));
        if (!in_array($rawRole, ['user', 'masyarakat'], true)) {
            continue;
        }

        $timestamp = admin_activity_time_value((string) ($row['created_at'] ?? ''));
        if (!admin_activity_matches_period($timestamp, $startTs, $endTs)) {
            continue;
        }

        $name = admin_activity_actor_name($row);
        $email = trim((string) ($row['email'] ?? ''));
        $activities[] = [
            'timestamp' => $timestamp,
            'waktu' => format_date($row['created_at'] ?? null),
            'aktor' => $name,
            'role' => 'Masyarakat',
            'aktivitas' => 'Registrasi Akun',
            'type_key' => 'registrasi',
            'modul' => 'Akun',
            'detail' => $email !== '' ? $name . ' mendaftar dengan email ' . $email . '.' : $name . ' membuat akun baru di ReWorth.',
        ];
    }

    foreach ($reportRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $timestamp = admin_activity_time_value((string) ($row['waktu_lapor'] ?? ''));
        if (!admin_activity_matches_period($timestamp, $startTs, $endTs)) {
            continue;
        }

        $profile = $profilesMap[(string) ($row['id_masyarakat'] ?? '')] ?? null;
        $name = admin_activity_actor_name($profile);
        $location = trim(implode(', ', array_filter([
            (string) ($row['kelurahan'] ?? ''),
            (string) ($row['kecamatan'] ?? ''),
        ])));
        $status = admin_activity_status_label((string) ($row['status_laporan'] ?? 'pending'));
        $detail = 'Laporan sampah #' . (string) ($row['id_laporan'] ?? '-') . ' dibuat';
        if ($location !== '') {
            $detail .= ' di ' . $location;
        }
        $detail .= ' dengan status ' . $status . '.';

        $activities[] = [
            'timestamp' => $timestamp,
            'waktu' => format_date($row['waktu_lapor'] ?? null),
            'aktor' => $name,
            'role' => admin_activity_role_label((string) (($profile['role'] ?? 'user'))),
            'aktivitas' => 'Lapor Sampah',
            'type_key' => 'lapor_sampah',
            'modul' => 'Laporan Sampah',
            'detail' => $detail,
        ];
    }

    foreach ($orderRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $timeValue = (string) (($row['tanggal_pesanan'] ?? '') !== '' ? $row['tanggal_pesanan'] : ($row['created_at'] ?? ''));
        $timestamp = admin_activity_time_value($timeValue);
        if (!admin_activity_matches_period($timestamp, $startTs, $endTs)) {
            continue;
        }

        $profile = $profilesMap[(string) ($row['id_masyarakat'] ?? '')] ?? null;
        $name = admin_activity_actor_name($profile);
        $orderCode = (string) (($row['kode_pesanan'] ?? '') ?: ('ORD-' . (string) ($row['id_pesanan'] ?? '-')));
        $status = admin_activity_status_label((string) ($row['status_pesanan'] ?? 'pending'));

        $activities[] = [
            'timestamp' => $timestamp,
            'waktu' => format_date($timeValue ?: null),
            'aktor' => $name,
            'role' => admin_activity_role_label((string) (($profile['role'] ?? 'user'))),
            'aktivitas' => 'Belanja Mini Market',
            'type_key' => 'transaksi',
            'modul' => 'Mini Market',
            'detail' => 'Pesanan ' . $orderCode . ' dibuat dengan total Rp ' . number_format((int) ($row['total_bayar'] ?? 0), 0, ',', '.') . ' dan status ' . $status . '.',
        ];
    }

    foreach ($sellerApplicationRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $status = (string) ($row['status_pengajuan'] ?? 'Pending');
        $isProcessed = trim((string) ($row['tanggal_diproses'] ?? '')) !== '' && strcasecmp($status, 'Pending') !== 0;
        $timeValue = $isProcessed ? (string) ($row['tanggal_diproses'] ?? '') : (string) ($row['tanggal_pengajuan'] ?? '');
        $timestamp = admin_activity_time_value($timeValue);
        if (!admin_activity_matches_period($timestamp, $startTs, $endTs)) {
            continue;
        }

        $profile = $profilesMap[(string) ($row['id_masyarakat'] ?? '')] ?? null;
        $name = admin_activity_actor_name($profile);
        $storeName = trim((string) ($row['nama_toko_usulan'] ?? 'Toko Baru'));
        $statusLabel = admin_activity_status_label($status);
        $detail = $isProcessed
            ? 'Pengajuan seller untuk toko ' . $storeName . ' telah ' . strtolower($statusLabel) . '.'
            : 'Pengguna mengajukan seller untuk toko ' . $storeName . '.';

        if (!$isProcessed && !empty($row['tanggal_pengajuan'])) {
            $detail .= ' Menunggu verifikasi admin.';
        }

        if ($isProcessed && !empty($row['alasan_penolakan']) && strcasecmp($status, 'Ditolak') === 0) {
            $detail .= ' Alasan: ' . trim((string) $row['alasan_penolakan']) . '.';
        }

        $activities[] = [
            'timestamp' => $timestamp,
            'waktu' => format_date($timeValue ?: null),
            'aktor' => $name,
            'role' => admin_activity_role_label((string) (($profile['role'] ?? 'user'))),
            'aktivitas' => 'Pengajuan Seller',
            'type_key' => 'pengajuan_seller',
            'modul' => 'Seller',
            'detail' => $detail,
        ];
    }

    foreach ($pointRedemptionRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $status = (string) ($row['status_proses'] ?? 'Pending');
        $isProcessed = trim((string) ($row['tanggal_diproses'] ?? '')) !== '' && strcasecmp($status, 'Pending') !== 0;
        $timeValue = $isProcessed ? (string) ($row['tanggal_diproses'] ?? '') : (string) ($row['tanggal_penukaran'] ?? '');
        $timestamp = admin_activity_time_value($timeValue);
        if (!admin_activity_matches_period($timestamp, $startTs, $endTs)) {
            continue;
        }

        $profile = $profilesMap[(string) ($row['id_masyarakat'] ?? '')] ?? null;
        $reward = $rewardsMap[(int) ($row['id_reward'] ?? 0)] ?? [];
        $name = admin_activity_actor_name($profile);
        $rewardName = trim((string) (($reward['nama_reward'] ?? $reward['nominal_reward'] ?? 'Reward') ?: 'Reward'));
        $statusLabel = admin_activity_status_label($status);

        $activities[] = [
            'timestamp' => $timestamp,
            'waktu' => format_date($timeValue ?: null),
            'aktor' => $name,
            'role' => admin_activity_role_label((string) (($profile['role'] ?? 'user'))),
            'aktivitas' => 'Tukar Poin',
            'type_key' => 'tukar_poin',
            'modul' => 'Reward',
            'detail' => 'Penukaran ' . number_format((int) ($row['poin_terpakai'] ?? 0), 0, ',', '.') . ' poin untuk ' . $rewardName . ' dengan status ' . $statusLabel . '.',
        ];
    }

    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $typeFilter = trim((string) ($filters['type'] ?? ''));
    $roleFilter = trim((string) ($filters['role'] ?? ''));

    $activities = array_values(array_filter($activities, static function (array $activity) use ($q, $typeFilter, $roleFilter): bool {
        if ($typeFilter !== '') {
            $matchesType = strcasecmp((string) ($activity['type_key'] ?? ''), $typeFilter) === 0
                || strcasecmp((string) ($activity['aktivitas'] ?? ''), $typeFilter) === 0;
            if (!$matchesType) {
                return false;
            }
        }

        if ($roleFilter !== '' && strcasecmp((string) ($activity['role'] ?? ''), $roleFilter) !== 0) {
            return false;
        }

        if ($q !== '') {
            $haystack = strtolower(implode(' ', [
                (string) ($activity['aktor'] ?? ''),
                (string) ($activity['aktivitas'] ?? ''),
                (string) ($activity['modul'] ?? ''),
                (string) ($activity['detail'] ?? ''),
            ]));

            if (!str_contains($haystack, $q)) {
                return false;
            }
        }

        return true;
    }));

    usort($activities, static fn (array $a, array $b): int => ((int) ($b['timestamp'] ?? 0)) <=> ((int) ($a['timestamp'] ?? 0)));

    $activities = array_slice($activities, 0, $limit);

    return array_values(array_map(static function (array $activity): array {
        $activity['type_key'] = (string) ($activity['type_key'] ?? admin_activity_type_key((string) ($activity['aktivitas'] ?? '')));
        return $activity;
    }, $activities));
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


