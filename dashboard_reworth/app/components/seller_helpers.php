<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';

const SELLER_PRODUCT_BUCKET = 'product-images';

function seller_supabase_access_issue(): ?string
{
    return null;
}

function seller_demo_categories(): array
{
    return [
        ['id_kategori' => 1, 'nama_kategori' => 'Kerajinan Daur Ulang', 'deskripsi' => 'Produk handmade dari limbah yang sudah dipilah.'],
        ['id_kategori' => 2, 'nama_kategori' => 'Dekorasi Rumah', 'deskripsi' => 'Produk dekorasi dan utilitas rumah ramah lingkungan.'],
        ['id_kategori' => 3, 'nama_kategori' => 'Kompos', 'deskripsi' => 'Produk olahan organik dan pupuk kompos.'],
    ];
}

function seller_demo_products(string $sellerUserId = ''): array
{
    $today = new DateTimeImmutable('today');
    $updated = $today->format('Y-m-d\TH:i:sP');
    $createdOne = $today->modify('-18 days')->format('Y-m-d');
    $createdTwo = $today->modify('-11 days')->format('Y-m-d');
    $sellerName = 'Eco Craft';

    return [
        [
            'id' => '101',
            'id_produk' => 101,
            'id_kategori' => 1,
            'nama' => 'Tempat Pensil Daur Ulang',
            'nama_produk' => 'Tempat Pensil Daur Ulang',
            'seller' => $sellerName,
            'kategori' => 'Kerajinan Daur Ulang',
            'harga' => 25000,
            'stok' => 21,
            'status' => 'aktif',
            'status_produk' => 'aktif',
            'deskripsi' => 'Wadah meja kerja dari bahan daur ulang yang ringan, rapi, dan awet dipakai.',
            'bahan' => 'Kertas daur ulang dan karton tebal',
            'manfaat' => 'Merapikan meja dan mengurangi limbah sekali pakai',
            'cara_pakai' => 'Letakkan alat tulis ke dalam wadah dan simpan di meja kerja.',
            'eco_value' => 'Reusable, low waste',
            'berat_gram' => 180,
            'rating' => 4.8,
            'foto' => url('assets/logo_reworth.jpeg'),
            'images' => [[
                'id_gambar' => 1011,
                'storage_path' => '',
                'public_url' => url('assets/logo_reworth.jpeg'),
                'is_primary' => true,
            ]],
            'sku' => 'RWT-00101',
            'tanggal_dibuat' => $createdOne,
            'terakhir_diperbarui' => $updated,
        ],
        [
            'id' => '102',
            'id_produk' => 102,
            'id_kategori' => 2,
            'nama' => 'Kaca Kerang',
            'nama_produk' => 'Kaca Kerang',
            'seller' => $sellerName,
            'kategori' => 'Dekorasi Rumah',
            'harga' => 20000,
            'stok' => 1,
            'status' => 'aktif',
            'status_produk' => 'aktif',
            'deskripsi' => 'Cermin dekoratif dengan aksen kerang dan tali alami untuk mempercantik ruangan.',
            'bahan' => 'Cermin kaca, kerang, dan tali alami',
            'manfaat' => 'Menambah nilai dekoratif ruang rumah',
            'cara_pakai' => 'Gantung di dinding ruangan yang ingin dipercantik.',
            'eco_value' => 'Upcycled decor',
            'berat_gram' => 320,
            'rating' => 4.7,
            'foto' => url('assets/ilustrasi.png'),
            'images' => [[
                'id_gambar' => 1021,
                'storage_path' => '',
                'public_url' => url('assets/ilustrasi.png'),
                'is_primary' => true,
            ]],
            'sku' => 'RWT-00102',
            'tanggal_dibuat' => $createdTwo,
            'terakhir_diperbarui' => $updated,
        ],
    ];
}

function seller_demo_order_summaries(string $sellerUserId = ''): array
{
    $today = new DateTimeImmutable('today');
    $products = [];
    foreach (seller_demo_products($sellerUserId) as $product) {
        $products[(int) $product['id_produk']] = $product;
    }

    $makeItem = static function (array $product, int $quantity): array {
        $subtotal = (float) ($product['harga'] ?? 0) * $quantity;
        $feeItem = round($subtotal * 0.04, 2);
        return [
            'id_produk' => (int) ($product['id_produk'] ?? 0),
            'nama_produk' => (string) ($product['nama_produk'] ?? ''),
            'qty' => $quantity,
            'quantity' => $quantity,
            'harga' => (float) ($product['harga'] ?? 0),
            'subtotal' => $subtotal,
            'fee_platform_item' => $feeItem,
            'pendapatan_seller' => round($subtotal - $feeItem, 2),
        ];
    };

    $orders = [
        [
            'id_pesanan' => 9001,
            'id' => '9001',
            'kode_pesanan' => 'ORD-9001',
            'pembeli' => 'Fatma Azzahra',
            'buyer_email' => 'fatma@mail.com',
            'buyer_id' => 'USR-1001',
            'tanggal' => $today->modify('-2 days')->format('Y-m-d H:i:s'),
            'status' => 'diproses',
            'status_pesanan' => 'diproses',
            'subtotal_seller' => 25000.0,
            'subtotal_bruto_seller' => 25000.0,
            'fee_platform_seller' => 1000.0,
            'biaya_layanan' => 500.0,
            'fee_platform_order' => 1000.0,
            'total' => 24000.0,
            'pendapatan_seller' => 24000.0,
            'total_order' => 25000.0,
            'total_qty' => 1,
            'id_alamat' => 1,
            'id_kartu' => 1,
            'payment_status' => 'paid',
            'items' => [$makeItem($products[101], 1)],
        ],
        [
            'id_pesanan' => 9002,
            'id' => '9002',
            'kode_pesanan' => 'ORD-9002',
            'pembeli' => 'Bima Saputra',
            'buyer_email' => 'bima@mail.com',
            'buyer_id' => 'USR-1002',
            'tanggal' => $today->modify('-4 days')->format('Y-m-d H:i:s'),
            'status' => 'dikemas',
            'status_pesanan' => 'dikemas',
            'subtotal_seller' => 45000.0,
            'subtotal_bruto_seller' => 45000.0,
            'fee_platform_seller' => 1800.0,
            'biaya_layanan' => 500.0,
            'fee_platform_order' => 1800.0,
            'total' => 43200.0,
            'pendapatan_seller' => 43200.0,
            'total_order' => 45000.0,
            'total_qty' => 2,
            'id_alamat' => 2,
            'id_kartu' => 1,
            'payment_status' => 'paid',
            'items' => [$makeItem($products[101], 1), $makeItem($products[102], 1)],
        ],
        [
            'id_pesanan' => 9003,
            'id' => '9003',
            'kode_pesanan' => 'ORD-9003',
            'pembeli' => 'Nadia Putri',
            'buyer_email' => 'nadia@mail.com',
            'buyer_id' => 'USR-1003',
            'tanggal' => $today->modify('-8 days')->format('Y-m-d H:i:s'),
            'status' => 'selesai',
            'status_pesanan' => 'selesai',
            'subtotal_seller' => 20000.0,
            'subtotal_bruto_seller' => 20000.0,
            'fee_platform_seller' => 800.0,
            'biaya_layanan' => 500.0,
            'fee_platform_order' => 800.0,
            'total' => 19200.0,
            'pendapatan_seller' => 19200.0,
            'total_order' => 20000.0,
            'total_qty' => 1,
            'id_alamat' => 3,
            'id_kartu' => 1,
            'payment_status' => 'paid',
            'items' => [$makeItem($products[102], 1)],
        ],
        [
            'id_pesanan' => 9004,
            'id' => '9004',
            'kode_pesanan' => 'ORD-9004',
            'pembeli' => 'Dina Maharani',
            'buyer_email' => 'dina@mail.com',
            'buyer_id' => 'USR-1004',
            'tanggal' => $today->modify('-10 days')->format('Y-m-d H:i:s'),
            'status' => 'ditolak',
            'status_pesanan' => 'ditolak',
            'subtotal_seller' => 25000.0,
            'subtotal_bruto_seller' => 25000.0,
            'fee_platform_seller' => 0.0,
            'biaya_layanan' => 0.0,
            'fee_platform_order' => 0.0,
            'total' => 0.0,
            'pendapatan_seller' => 0.0,
            'total_order' => 25000.0,
            'total_qty' => 1,
            'id_alamat' => 4,
            'id_kartu' => 1,
            'payment_status' => 'rejected',
            'items' => [$makeItem($products[101], 1)],
        ],
    ];

    return $orders;
}

function seller_authenticate_dashboard_user(string $identifier, string $password): array
{
    $identifier = trim($identifier);
    $password = trim($password);

    if ($identifier === '' || $password === '') {
        return ['success' => false, 'message' => 'Username dan password wajib diisi.'];
    }

    $seller = supabase_fetch_one('seller', '*', [
        'username_dashboard' => 'eq.' . $identifier,
    ]);

    if ($seller === null) {
        $accessIssue = seller_supabase_access_issue();
        if ($accessIssue !== null) {
            return ['success' => false, 'message' => $accessIssue];
        }
        return ['success' => false, 'message' => 'Username atau password seller salah.'];
    }

    if (!seller_password_matches($password, (string) ($seller['password_hash_dashboard'] ?? ''))) {
        return ['success' => false, 'message' => 'Username atau password seller salah.'];
    }

    if (!seller_can_access_dashboard($seller)) {
        return ['success' => false, 'message' => 'Akun seller belum aktif atau belum disetujui admin.'];
    }

    $profile = seller_fetch_profile_row((string) ($seller['id_masyarakat'] ?? ''));
    $user = seller_session_payload($seller, $profile);

    return [
        'success' => true,
        'message' => 'Login seller berhasil',
        'user' => $user,
    ];
}

function seller_can_access_dashboard(array $seller): bool
{
    $status = strtolower(trim((string) ($seller['status_verifikasi'] ?? '')));
    $active = $seller['aktif'] ?? null;

    if ($active === false || $active === 0 || $active === 'f' || $active === 'false') {
        return false;
    }

    if ($status === '') {
        return true;
    }

    return in_array($status, ['terverifikasi', 'disetujui', 'approved', 'aktif'], true);
}

function seller_password_matches(string $plainPassword, string $storedHash): bool
{
    if ($storedHash === '') {
        return false;
    }

    if (password_verify($plainPassword, $storedHash)) {
        return true;
    }

    return hash_equals($storedHash, $plainPassword);
}

function seller_session_payload(array $seller, ?array $profile): array
{
    $sellerUserId = (string) ($seller['id_masyarakat'] ?? '');
    $email = trim((string) (($profile['email'] ?? '') ?: 'seller@reworth.app'));
    $ownerName = trim((string) (($profile['nama_lengkap'] ?? $profile['nama'] ?? '') ?: ($seller['nama_toko'] ?? 'Seller ReWorth')));

    return [
        'id' => $sellerUserId,
        'user_id' => $sellerUserId,
        'seller_id' => (string) ($seller['id_seller'] ?? ''),
        'seller_user_id' => $sellerUserId,
        'nama' => $ownerName,
        'email' => $email,
        'username' => (string) ($seller['username_dashboard'] ?? ''),
        'role' => 'seller',
        'status' => 'aktif',
        'nama_toko' => (string) ($seller['nama_toko'] ?? 'Toko ReWorth'),
        'foto_toko' => (string) ($seller['foto_toko'] ?? ''),
    ];
}

function seller_fetch_profile_row(string $sellerUserId): ?array
{
    if ($sellerUserId === '') {
        return null;
    }

    return supabase_fetch_one('profiles', '*', ['id' => 'eq.' . $sellerUserId]);
}

function seller_fetch_profile(string $sellerUserId): ?array
{
    $seller = supabase_fetch_one('seller', '*', ['id_masyarakat' => 'eq.' . $sellerUserId]);
    if ($seller === null) {
        if ($sellerUserId === '' || $sellerUserId === '5c16b203-0b61-49e9-afa9-b7a9b89d3bed') {
            return [
                'seller_id' => 'demo-seller',
                'seller_user_id' => $sellerUserId,
                'nama_toko' => 'Eco Craft',
                'deskripsi_toko' => 'Toko produk daur ulang ReWorth untuk seller demo dashboard.',
                'alamat_toko' => 'Alamat toko Eco Craft',
                'foto_toko' => '',
                'username_dashboard' => 'ecocraft',
                'status_verifikasi' => 'aktif',
                'aktif' => true,
                'owner_name' => 'Eco Craft',
                'email' => 'seller@reworth.app',
                'no_telp' => '081234567890',
                'total_poin' => 0,
                'rekening_bank' => null,
            ];
        }

        return null;
    }

    $profile = seller_fetch_profile_row($sellerUserId);
    $bankAccount = supabase_fetch_one('kartu_pembayaran', '*', [
        'id_masyarakat' => 'eq.' . $sellerUserId,
        'status_aktif' => 'eq.true',
        'order' => 'kartu_utama.desc,created_at.desc',
    ]);

    return [
        'seller_id' => (string) ($seller['id_seller'] ?? ''),
        'seller_user_id' => $sellerUserId,
        'nama_toko' => (string) ($seller['nama_toko'] ?? ''),
        'deskripsi_toko' => (string) ($seller['deskripsi_toko'] ?? ''),
        'alamat_toko' => (string) ($seller['alamat_toko'] ?? ''),
        'foto_toko' => (string) ($seller['foto_toko'] ?? ''),
        'username_dashboard' => (string) ($seller['username_dashboard'] ?? ''),
        'status_verifikasi' => (string) ($seller['status_verifikasi'] ?? ''),
        'aktif' => (bool) ($seller['aktif'] ?? false),
        'owner_name' => (string) ($profile['nama_lengkap'] ?? $profile['nama'] ?? ''),
        'email' => (string) ($profile['email'] ?? ''),
        'no_telp' => (string) ($profile['no_telp'] ?? $profile['nomor_hp'] ?? ''),
        'total_poin' => (int) ($profile['total_poin'] ?? 0),
        'rekening_bank' => is_array($bankAccount) ? [
            'id_kartu' => (string) ($bankAccount['id_kartu'] ?? ''),
            'nama_bank' => (string) ($bankAccount['nama_bank'] ?? ''),
            'nama_pemilik' => (string) ($bankAccount['nama_pemilik'] ?? ''),
            'last4_digit' => (string) ($bankAccount['last4_digit'] ?? ''),
            'jenis_kartu' => (string) ($bankAccount['jenis_kartu'] ?? 'Debit'),
            'kartu_utama' => (bool) ($bankAccount['kartu_utama'] ?? false),
        ] : null,
    ];
}

function seller_fetch_categories(): array
{
    $rows = supabase_fetch('kategori_produk', '*', ['order' => 'nama_kategori.asc']);
    if ($rows === []) {
        return seller_demo_categories();
    }

    return array_values(array_map(static function (array $row): array {
        return [
            'id_kategori' => (int) ($row['id_kategori'] ?? 0),
            'nama_kategori' => (string) ($row['nama_kategori'] ?? 'Tanpa Kategori'),
            'deskripsi' => (string) ($row['deskripsi'] ?? ''),
        ];
    }, array_values(array_filter($rows, 'is_array'))));
}

function seller_category_map(): array
{
    $map = [];
    foreach (seller_fetch_categories() as $category) {
        $map[(int) $category['id_kategori']] = $category;
    }
    return $map;
}

function seller_fetch_products(string $sellerUserId, array $filters = []): array
{
    $rows = supabase_fetch('produk', '*', [
        'id_seller' => 'eq.' . $sellerUserId,
        'order' => 'created_at.desc',
    ]);

    $products = seller_normalize_products($rows, $sellerUserId);
    if ($products === []) {
        $products = seller_demo_products($sellerUserId);
    }

    return seller_filter_products($products, $filters);
}

function seller_fetch_product_by_id(string $sellerUserId, int $productId): ?array
{
    $rows = supabase_fetch('produk', '*', [
        'id_seller' => 'eq.' . $sellerUserId,
        'id_produk' => 'eq.' . $productId,
        'limit' => '1',
    ]);

    $products = seller_normalize_products($rows, $sellerUserId);
    if ($products !== []) {
        return $products[0];
    }

    foreach (seller_demo_products($sellerUserId) as $product) {
        if ((int) ($product['id_produk'] ?? 0) === $productId) {
            return $product;
        }
    }

    return null;
}

function seller_normalize_products(array $productRows, string $sellerUserId): array
{
    $productRows = array_values(array_filter($productRows, 'is_array'));
    if ($productRows === []) {
        return [];
    }

    $categoryMap = seller_category_map();
    $profile = seller_fetch_profile($sellerUserId);
    $storeName = (string) ($profile['nama_toko'] ?? 'Toko ReWorth');

    $productIds = array_values(array_filter(array_map(
        static fn (array $row): int => (int) ($row['id_produk'] ?? 0),
        $productRows
    )));

    $imageMap = seller_fetch_image_map($productIds);

    return array_values(array_map(static function (array $row) use ($categoryMap, $imageMap, $storeName): array {
        $productId = (int) ($row['id_produk'] ?? 0);
        $categoryId = (int) ($row['id_kategori'] ?? 0);
        $images = $imageMap[$productId] ?? [];
        $primaryImage = $images[0]['public_url'] ?? '';
        $createdAt = (string) ($row['created_at'] ?? '');
        $updatedAt = (string) ($row['updated_at'] ?? $createdAt);

        return [
            'id' => (string) $productId,
            'id_produk' => $productId,
            'id_kategori' => $categoryId,
            'nama' => (string) ($row['nama_produk'] ?? 'Produk'),
            'nama_produk' => (string) ($row['nama_produk'] ?? 'Produk'),
            'seller' => $storeName,
            'kategori' => (string) ($categoryMap[$categoryId]['nama_kategori'] ?? 'Tanpa Kategori'),
            'harga' => (int) round((float) ($row['harga'] ?? 0)),
            'stok' => (int) ($row['stok'] ?? 0),
            'status' => strtolower((string) ($row['status_produk'] ?? 'aktif')),
            'status_produk' => strtolower((string) ($row['status_produk'] ?? 'aktif')),
            'deskripsi' => (string) ($row['deskripsi'] ?? ''),
            'bahan' => (string) ($row['bahan'] ?? ''),
            'manfaat' => (string) ($row['manfaat'] ?? ''),
            'cara_pakai' => (string) ($row['cara_pakai'] ?? ''),
            'eco_value' => (string) ($row['eco_value'] ?? ''),
            'berat_gram' => (int) ($row['berat_gram'] ?? 0),
            'rating' => (float) ($row['rating'] ?? 0),
            'foto' => $primaryImage,
            'images' => $images,
            'sku' => (string) ($row['sku'] ?? ('RWT-' . str_pad((string) $productId, 5, '0', STR_PAD_LEFT))),
            'tanggal_dibuat' => $createdAt !== '' ? substr($createdAt, 0, 10) : '-',
            'terakhir_diperbarui' => $updatedAt !== '' ? $updatedAt : '-',
        ];
    }, $productRows));
}

function seller_fetch_image_map(array $productIds): array
{
    if ($productIds === []) {
        return [];
    }

    $inFilter = seller_in_filter($productIds);
    if ($inFilter === null) {
        return [];
    }

    $rows = supabase_fetch('gambar_produk', '*', [
        'id_produk' => $inFilter,
        'order' => 'is_primary.desc,created_at.asc',
    ]);

    $map = [];
    foreach ($rows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $productId = (int) ($row['id_produk'] ?? 0);
        if ($productId <= 0) {
            continue;
        }

        $map[$productId] ??= [];
        $map[$productId][] = [
            'id_gambar' => (int) ($row['id_gambar'] ?? 0),
            'storage_path' => (string) ($row['storage_path'] ?? ''),
            'public_url' => (string) ($row['public_url'] ?? ''),
            'is_primary' => (bool) ($row['is_primary'] ?? false),
        ];
    }

    return $map;
}

function seller_filter_products(array $products, array $filters): array
{
    $query = strtolower(trim((string) ($filters['q'] ?? '')));
    $category = trim((string) ($filters['kategori'] ?? ''));
    $status = strtolower(trim((string) ($filters['status'] ?? '')));

    return array_values(array_filter($products, static function (array $product) use ($query, $category, $status): bool {
        if ($category !== '' && (string) ($product['kategori'] ?? '') !== $category) {
            return false;
        }
        if ($status !== '' && strtolower((string) ($product['status_produk'] ?? '')) !== $status) {
            return false;
        }
        if ($query === '') {
            return true;
        }

        $haystack = strtolower(implode(' ', [
            (string) ($product['id_produk'] ?? ''),
            (string) ($product['nama_produk'] ?? ''),
            (string) ($product['kategori'] ?? ''),
            (string) ($product['deskripsi'] ?? ''),
        ]));

        return str_contains($haystack, $query);
    }));
}

function seller_create_product(string $sellerUserId, array $input, array $files): array
{
    $validation = seller_validate_product_input($input, false, $files);
    if (!$validation['valid']) {
        return ['success' => false, 'type' => 'danger', 'message' => $validation['message']];
    }

    $now = gmdate('c');
    $payload = [
        'id_seller' => $sellerUserId,
        'id_kategori' => $validation['data']['id_kategori'],
        'nama_produk' => $validation['data']['nama_produk'],
        'deskripsi' => $validation['data']['deskripsi'],
        'bahan' => $validation['data']['bahan'],
        'manfaat' => $validation['data']['manfaat'],
        'cara_pakai' => $validation['data']['cara_pakai'],
        'eco_value' => $validation['data']['eco_value'],
        'harga' => $validation['data']['harga'],
        'stok' => $validation['data']['stok'],
        'berat_gram' => $validation['data']['berat_gram'],
        'status_produk' => $validation['data']['status_produk'],
        'updated_at' => $now,
    ];

    $inserted = supabase_insert('produk', $payload);
    $row = is_array($inserted[0] ?? null) ? $inserted[0] : null;
    if ($row === null) {
        return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal menyimpan produk baru.')];
    }

    $productId = (int) ($row['id_produk'] ?? 0);
    $uploadResult = seller_sync_product_images($productId, $sellerUserId, $files['foto'] ?? null, true);

    if (!$uploadResult['success']) {
        return ['success' => true, 'type' => 'warning', 'message' => 'Produk berhasil dibuat, tetapi foto gagal diunggah: ' . $uploadResult['message']];
    }

    return ['success' => true, 'type' => 'success', 'message' => 'Produk berhasil ditambahkan.'];
}

function seller_update_product(string $sellerUserId, int $productId, array $input, array $files): array
{
    $validation = seller_validate_product_input($input, true, $files);
    if (!$validation['valid']) {
        return ['success' => false, 'type' => 'danger', 'message' => $validation['message']];
    }

    $payload = [
        'id_kategori' => $validation['data']['id_kategori'],
        'nama_produk' => $validation['data']['nama_produk'],
        'deskripsi' => $validation['data']['deskripsi'],
        'bahan' => $validation['data']['bahan'],
        'manfaat' => $validation['data']['manfaat'],
        'cara_pakai' => $validation['data']['cara_pakai'],
        'eco_value' => $validation['data']['eco_value'],
        'harga' => $validation['data']['harga'],
        'stok' => $validation['data']['stok'],
        'berat_gram' => $validation['data']['berat_gram'],
        'status_produk' => $validation['data']['status_produk'],
        'updated_at' => gmdate('c'),
    ];

    $updated = supabase_update('produk', $payload, [
        'id_produk' => 'eq.' . $productId,
        'id_seller' => 'eq.' . $sellerUserId,
    ]);

    if ($updated === [] && supabase_last_error() !== null) {
        return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal memperbarui produk.')];
    }

    $existing = seller_fetch_image_map([$productId]);
    $hasPrimary = !empty($existing[$productId]);
    $uploadResult = seller_sync_product_images($productId, $sellerUserId, $files['foto'] ?? null, !$hasPrimary);
    if (!$uploadResult['success']) {
        return ['success' => true, 'type' => 'warning', 'message' => 'Produk diperbarui, tetapi ada foto yang gagal diunggah: ' . $uploadResult['message']];
    }

    return ['success' => true, 'type' => 'success', 'message' => 'Produk berhasil diperbarui.'];
}

function seller_delete_product(string $sellerUserId, int $productId): array
{
    $product = seller_fetch_product_by_id($sellerUserId, $productId);
    if ($product === null) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Produk tidak ditemukan.'];
    }

    if (seller_product_has_dependencies($productId)) {
        supabase_update('produk', ['status_produk' => 'nonaktif', 'updated_at' => gmdate('c')], [
            'id_produk' => 'eq.' . $productId,
            'id_seller' => 'eq.' . $sellerUserId,
        ]);

        return [
            'success' => true,
            'type' => 'warning',
            'message' => 'Produk memiliki riwayat transaksi atau interaksi, jadi hanya dinonaktifkan.',
        ];
    }

    $images = seller_fetch_image_map([$productId]);
    foreach ($images[$productId] ?? [] as $image) {
        $path = trim((string) ($image['storage_path'] ?? ''));
        if ($path !== '') {
            supabase_storage_delete(SELLER_PRODUCT_BUCKET, $path);
        }
    }

    supabase_delete('gambar_produk', ['id_produk' => 'eq.' . $productId]);
    $deleted = supabase_delete('produk', [
        'id_produk' => 'eq.' . $productId,
        'id_seller' => 'eq.' . $sellerUserId,
    ]);

    if (!$deleted) {
        return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal menghapus produk.')];
    }

    return ['success' => true, 'type' => 'success', 'message' => 'Produk berhasil dihapus.'];
}

function seller_product_has_dependencies(int $productId): bool
{
    $tables = [
        ['table' => 'detail_pesanan', 'column' => 'id_produk'],
        ['table' => 'ulasan', 'column' => 'id_produk'],
        ['table' => 'wishlist', 'column' => 'id_produk'],
        ['table' => 'wishlist_item', 'column' => 'id_produk'],
        ['table' => 'keranjang', 'column' => 'id_produk'],
        ['table' => 'item_keranjang', 'column' => 'id_produk'],
    ];

    foreach ($tables as $config) {
        $row = supabase_fetch_one($config['table'], '*', [
            $config['column'] => 'eq.' . $productId,
        ]);
        if ($row !== null) {
            return true;
        }
    }

    return false;
}

function seller_validate_product_input(array $input, bool $isEdit, array $files = []): array
{
    $nama = trim((string) ($input['nama'] ?? ''));
    $kategori = (int) ($input['kategori'] ?? 0);
    $harga = (float) ($input['harga'] ?? 0);
    $stok = (int) ($input['stok'] ?? 0);
    $deskripsi = trim((string) ($input['deskripsi'] ?? ''));
    $status = strtolower(trim((string) ($input['status'] ?? 'aktif')));
    $allowedStatuses = ['aktif', 'nonaktif', 'pending', 'disembunyikan'];

    if ($nama === '' || $kategori <= 0 || $harga <= 0 || $stok < 0 || $deskripsi === '') {
        return ['valid' => false, 'message' => 'Nama, kategori, harga, stok, dan deskripsi wajib diisi.'];
    }

    if (!in_array($status, $allowedStatuses, true)) {
        return ['valid' => false, 'message' => 'Status produk tidak valid.'];
    }

    if (!$isEdit && seller_normalize_uploaded_files($files) === []) {
        return ['valid' => false, 'message' => 'Minimal 1 foto produk wajib diunggah saat membuat produk.'];
    }

    return [
        'valid' => true,
        'data' => [
            'nama_produk' => $nama,
            'id_kategori' => $kategori,
            'harga' => $harga,
            'stok' => $stok,
            'deskripsi' => $deskripsi,
            'bahan' => trim((string) ($input['material'] ?? '')),
            'manfaat' => trim((string) ($input['manfaat'] ?? '')),
            'cara_pakai' => trim((string) ($input['cara_pakai'] ?? '')),
            'eco_value' => trim((string) ($input['eco_value'] ?? '')),
            'berat_gram' => ($input['berat'] ?? '') === '' ? null : (int) $input['berat'],
            'status_produk' => $status,
        ],
    ];
}

function seller_sync_product_images(int $productId, string $sellerUserId, mixed $filesEntry, bool $setFirstAsPrimary): array
{
    $uploads = seller_normalize_uploaded_files($filesEntry);
    if ($uploads === []) {
        return ['success' => true, 'message' => 'Tidak ada foto baru.'];
    }

    $hasPrimary = !$setFirstAsPrimary;
    foreach ($uploads as $index => $upload) {
        $tmpPath = (string) ($upload['tmp_name'] ?? '');
        $originalName = (string) ($upload['name'] ?? 'image.jpg');
        if ($tmpPath === '' || !is_file($tmpPath)) {
            continue;
        }

        $safeName = preg_replace('/[^A-Za-z0-9._-]/', '_', $originalName) ?: ('image_' . ($index + 1) . '.jpg');
        $storagePath = 'products/' . $sellerUserId . '/' . $productId . '/' . time() . '_' . $safeName;
        $binary = file_get_contents($tmpPath);
        if ($binary === false) {
            return ['success' => false, 'message' => 'Gagal membaca file upload.'];
        }

        $contentType = seller_detect_mime_type($tmpPath);
        $uploaded = supabase_storage_upload(SELLER_PRODUCT_BUCKET, $storagePath, $binary, $contentType);
        if (!$uploaded) {
            return ['success' => false, 'message' => seller_supabase_message('Upload gambar produk gagal.')];
        }

        $inserted = supabase_insert('gambar_produk', [
            'id_produk' => $productId,
            'storage_path' => $storagePath,
            'public_url' => supabase_storage_public_url(SELLER_PRODUCT_BUCKET, $storagePath),
            'is_primary' => !$hasPrimary,
            'created_at' => gmdate('c'),
        ]);

        if ($inserted === [] && supabase_last_error() !== null) {
            return ['success' => false, 'message' => seller_supabase_message('Gagal menyimpan data gambar produk.')];
        }

        $hasPrimary = true;
    }

    return ['success' => true, 'message' => 'Foto produk tersinkron.'];
}

function seller_detect_mime_type(string $tmpPath): string
{
    if (function_exists('finfo_open')) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        if ($finfo !== false) {
            $mime = finfo_file($finfo, $tmpPath) ?: 'application/octet-stream';
            finfo_close($finfo);
            return (string) $mime;
        }
    }

    if (function_exists('mime_content_type')) {
        $mime = mime_content_type($tmpPath);
        if (is_string($mime) && $mime !== '') {
            return $mime;
        }
    }

    return 'application/octet-stream';
}

function seller_normalize_uploaded_files(mixed $filesEntry): array
{
    if (!is_array($filesEntry) || !isset($filesEntry['name'])) {
        return [];
    }

    if (!is_array($filesEntry['name'])) {
        return ($filesEntry['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_OK ? [$filesEntry] : [];
    }

    $normalized = [];
    foreach ($filesEntry['name'] as $index => $name) {
        if (($filesEntry['error'][$index] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            continue;
        }

        $normalized[] = [
            'name' => $name,
            'type' => $filesEntry['type'][$index] ?? '',
            'tmp_name' => $filesEntry['tmp_name'][$index] ?? '',
            'error' => $filesEntry['error'][$index] ?? UPLOAD_ERR_NO_FILE,
            'size' => $filesEntry['size'][$index] ?? 0,
        ];
    }

    return $normalized;
}

function seller_fetch_order_summaries(string $sellerUserId, array $filters = []): array
{
    $productRows = supabase_fetch('produk', 'id_produk,nama_produk,harga,id_seller', [
        'id_seller' => 'eq.' . $sellerUserId,
    ]);
    $productMap = [];
    foreach ($productRows as $row) {
        if (!is_array($row)) {
            continue;
        }
        $productMap[(int) ($row['id_produk'] ?? 0)] = $row;
    }

    $productIds = array_keys($productMap);
    if ($productIds === []) {
        return seller_filter_orders(seller_demo_order_summaries($sellerUserId), $filters);
    }

    $detailRows = supabase_fetch('detail_pesanan', '*', [
        'id_produk' => seller_in_filter($productIds),
        'order' => 'id_pesanan.asc',
    ]);

    if ($detailRows === []) {
        return seller_filter_orders(seller_demo_order_summaries($sellerUserId), $filters);
    }

    $grouped = [];
    foreach ($detailRows as $detail) {
        if (!is_array($detail)) {
            continue;
        }
        $orderId = (int) ($detail['id_pesanan'] ?? 0);
        $productId = (int) ($detail['id_produk'] ?? 0);
        if ($orderId <= 0 || !isset($productMap[$productId])) {
            continue;
        }

        $grouped[$orderId] ??= [
            'id_pesanan' => $orderId,
            'items' => [],
            'total_seller' => 0,
            'total_qty' => 0,
            'gross_subtotal' => 0,
        ];

        $subtotal = (float) ($detail['subtotal'] ?? 0);
        $qty = (int) ($detail['jumlah'] ?? 0);
        $grouped[$orderId]['items'][] = [
            'id_detail_pesanan' => (int) ($detail['id_detail_pesanan'] ?? 0),
            'id_produk' => $productId,
            'nama_produk' => (string) ($productMap[$productId]['nama_produk'] ?? 'Produk'),
            'jumlah' => $qty,
            'harga_satuan' => (float) ($detail['harga_satuan'] ?? 0),
            'subtotal' => $subtotal,
            'fee_platform_item' => isset($detail['fee_platform_item']) ? (float) $detail['fee_platform_item'] : null,
            'pendapatan_seller' => isset($detail['pendapatan_seller']) ? (float) $detail['pendapatan_seller'] : null,
            'status_pencairan' => (string) ($detail['status_pencairan'] ?? ''),
        ];
        $grouped[$orderId]['gross_subtotal'] += $subtotal;
        $grouped[$orderId]['total_qty'] += $qty;
    }

    $orderIds = array_keys($grouped);
    $orderRows = supabase_fetch('pesanan', '*', [
        'id_pesanan' => seller_in_filter($orderIds),
        'order' => 'tanggal_pesanan.desc',
    ]);

    $paymentRows = supabase_fetch('pembayaran', '*', [
        'id_pesanan' => seller_in_filter($orderIds),
    ]);
    $paymentMap = [];
    foreach ($paymentRows as $payment) {
        if (!is_array($payment)) {
            continue;
        }
        $paymentMap[(int) ($payment['id_pesanan'] ?? 0)] = $payment;
    }

    $buyerIds = [];
    foreach ($orderRows as $orderRow) {
        if (is_array($orderRow) && !empty($orderRow['id_masyarakat'])) {
            $buyerIds[] = (string) $orderRow['id_masyarakat'];
        }
    }
    $buyerIds = array_values(array_unique($buyerIds));

    $profileMap = [];
    if ($buyerIds !== []) {
        foreach (supabase_fetch('profiles', 'id,nama_lengkap,nama,email', [
            'id' => seller_in_filter($buyerIds),
        ]) as $profile) {
            if (!is_array($profile)) {
                continue;
            }
            $profileMap[(string) ($profile['id'] ?? '')] = $profile;
        }
    }

    $summaries = [];
    foreach ($orderRows as $order) {
        if (!is_array($order)) {
            continue;
        }

        $orderId = (int) ($order['id_pesanan'] ?? 0);
        if (!isset($grouped[$orderId])) {
            continue;
        }

        $buyerId = (string) ($order['id_masyarakat'] ?? '');
        $buyer = $profileMap[$buyerId] ?? [];
        $subtotalProduk = isset($order['subtotal_produk'])
            ? (float) $order['subtotal_produk']
            : (float) ($order['subtotal'] ?? $grouped[$orderId]['gross_subtotal']);
        $feePlatform = isset($order['fee_platform'])
            ? (float) $order['fee_platform']
            : (float) ($order['pajak'] ?? 0);
        $biayaLayanan = isset($order['biaya_layanan'])
            ? (float) $order['biaya_layanan']
            : 500.0;
        $items = seller_finalize_order_items(
            $grouped[$orderId]['items'],
            $subtotalProduk,
            $feePlatform
        );
        $pendapatanSeller = array_sum(array_map(
            static fn (array $item): float => (float) ($item['pendapatan_seller'] ?? 0),
            $items
        ));
        $feePlatformSeller = array_sum(array_map(
            static fn (array $item): float => (float) ($item['fee_platform_item'] ?? 0),
            $items
        ));
        $summary = [
            'id_pesanan' => $orderId,
            'id' => (string) $orderId,
            'kode_pesanan' => (string) ($order['kode_pesanan'] ?? ('ORD-' . $orderId)),
            'pembeli' => (string) ($buyer['nama_lengkap'] ?? $buyer['nama'] ?? 'Pembeli ReWorth'),
            'buyer_email' => (string) ($buyer['email'] ?? ''),
            'buyer_id' => $buyerId,
            'tanggal' => (string) ($order['tanggal_pesanan'] ?? ''),
            'status' => strtolower((string) ($order['status_pesanan'] ?? 'pending')),
            'status_pesanan' => strtolower((string) ($order['status_pesanan'] ?? 'pending')),
            'subtotal_seller' => (float) $grouped[$orderId]['gross_subtotal'],
            'subtotal_bruto_seller' => (float) $grouped[$orderId]['gross_subtotal'],
            'fee_platform_seller' => $feePlatformSeller,
            'biaya_layanan' => $biayaLayanan,
            'fee_platform_order' => $feePlatform,
            'total' => $pendapatanSeller,
            'pendapatan_seller' => $pendapatanSeller,
            'total_order' => (float) ($order['total_bayar'] ?? 0),
            'total_qty' => (int) $grouped[$orderId]['total_qty'],
            'id_alamat' => (int) ($order['id_alamat'] ?? 0),
            'id_kartu' => (int) ($order['id_kartu'] ?? 0),
            'payment_status' => strtolower((string) ($paymentMap[$orderId]['status_pembayaran'] ?? '')),
            'items' => $items,
        ];
        $summaries[] = $summary;
    }

    if ($summaries === []) {
        $summaries = seller_demo_order_summaries($sellerUserId);
    }

    return seller_filter_orders($summaries, $filters);
}

function seller_finalize_order_items(array $items, float $subtotalProduk, float $feePlatform): array
{
    if ($items === []) {
        return [];
    }

    $finalized = [];

    foreach ($items as $item) {
        $grossSubtotal = (float) ($item['subtotal'] ?? 0);
        $storedFee = $item['fee_platform_item'] ?? null;
        $storedNet = $item['pendapatan_seller'] ?? null;

        if ($storedFee !== null && $storedNet !== null) {
            $feeItem = (float) $storedFee;
            $netItem = (float) $storedNet;
        } else {
            // A checkout may contain products from multiple sellers, so each
            // seller item receives only its proportional share of the fee.
            $feeItem = seller_round_money(
                $subtotalProduk <= 0 ? 0 : $feePlatform * ($grossSubtotal / $subtotalProduk)
            );
            $netItem = seller_round_money($grossSubtotal - $feeItem);
        }

        $finalized[] = [
            ...$item,
            'fee_platform_item' => seller_round_money($feeItem),
            'pendapatan_seller' => seller_round_money($netItem),
        ];
    }

    return $finalized;
}

function seller_round_money(float $value): float
{
    return round($value, 2);
}

function seller_filter_orders(array $orders, array $filters): array
{
    $status = strtolower(trim((string) ($filters['status'] ?? '')));
    $query = strtolower(trim((string) ($filters['q'] ?? '')));

    return array_values(array_filter($orders, static function (array $order) use ($status, $query): bool {
        $orderStatus = strtolower((string) ($order['status_pesanan'] ?? ''));
        $paymentStatus = strtolower((string) ($order['payment_status'] ?? ''));

        $isWaitingPayment = in_array($orderStatus, ['menunggu pembayaran', 'menunggu verifikasi'], true)
            || in_array($paymentStatus, ['belum upload', 'menunggu pembayaran', 'belum dibayar', 'menunggu verifikasi'], true);
        if ($isWaitingPayment) {
            return false;
        }

        if ($status === 'aktif') {
            if (in_array($orderStatus, ['selesai', 'ditolak', 'dibatalkan'], true)) {
                return false;
            }
        } elseif ($status === 'riwayat') {
            if (!in_array($orderStatus, ['selesai', 'ditolak', 'dibatalkan'], true)) {
                return false;
            }
        } elseif ($status !== '' && $status !== 'semua' && $orderStatus !== $status) {
            return false;
        }
        if ($query === '') {
            return true;
        }

        $haystack = strtolower(implode(' ', [
            (string) ($order['kode_pesanan'] ?? ''),
            (string) ($order['pembeli'] ?? ''),
            (string) ($order['buyer_email'] ?? ''),
        ]));

        return str_contains($haystack, $query);
    }));
}

function seller_fetch_order_detail(string $sellerUserId, int $orderId): ?array
{
    $order = null;
    foreach (seller_fetch_order_summaries($sellerUserId) as $summary) {
        if ((int) ($summary['id_pesanan'] ?? 0) === $orderId) {
            $order = $summary;
            break;
        }
    }

    if ($order === null) {
        return null;
    }

    $address = supabase_fetch_one('alamat', '*', ['id_alamat' => 'eq.' . ((int) ($order['id_alamat'] ?? 0))]);
    $payment = supabase_fetch_one('pembayaran', '*', ['id_pesanan' => 'eq.' . $orderId]);

    return [
        'order' => $order,
        'address' => $address,
        'payment' => $payment,
    ];
}

function seller_update_order_status(string $sellerUserId, int $orderId, string $status, string $reason = ''): array
{
    $allowedStatuses = ['diproses', 'dikemas', 'dikirim', 'selesai', 'ditolak'];
    $status = strtolower(trim($status));
    $reason = trim($reason);
    if (!in_array($status, $allowedStatuses, true)) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Status pesanan tidak valid.'];
    }
    if ($status === 'ditolak' && mb_strlen($reason) < 10) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Alasan penolakan pesanan minimal 10 karakter.'];
    }

    $detail = seller_fetch_order_detail($sellerUserId, $orderId);
    if ($detail === null) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Pesanan tidak ditemukan untuk seller ini.'];
    }

    $now = gmdate('c');
    $updated = supabase_update('pesanan', [
        'status_pesanan' => $status,
        'updated_at' => $now,
    ], [
        'id_pesanan' => 'eq.' . $orderId,
    ]);

    if ($updated === [] && supabase_last_error() !== null) {
        return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal memperbarui status pesanan.')];
    }

    $payoutStatus = $status === 'selesai' ? 'tersedia' : 'tertahan';
    supabase_update('detail_pesanan', [
        'status_pencairan' => $payoutStatus,
        'tanggal_pencairan' => $status === 'selesai' ? $now : null,
    ], [
        'id_pesanan' => 'eq.' . $orderId,
        'id_seller' => 'eq.' . $sellerUserId,
    ]);

    if ($status === 'ditolak') {
        supabase_update('pembayaran', [
            'catatan_verifikasi' => $reason,
            'updated_at' => $now,
        ], [
            'id_pesanan' => 'eq.' . $orderId,
        ]);
    }

    return ['success' => true, 'type' => 'success', 'message' => 'Status pesanan berhasil diperbarui.'];
}

function seller_fetch_dashboard_data(string $sellerUserId): array
{
    $products = seller_fetch_products($sellerUserId);
    $orders = seller_fetch_order_summaries($sellerUserId);
    $lowStock = array_values(array_filter($products, static fn (array $item): bool => (int) ($item['stok'] ?? 0) <= 5));
    $newOrders = array_values(array_filter($orders, static fn (array $item): bool => (string) ($item['status_pesanan'] ?? '') === 'diproses'));
    $completed = array_values(array_filter($orders, static fn (array $item): bool => (string) ($item['status_pesanan'] ?? '') === 'selesai'));
    $sales = array_sum(array_map(static fn (array $item): float => (float) ($item['total'] ?? 0), $completed));
    $salesChart = seller_build_sales_chart($completed, 30);

    return [
        'products' => $products,
        'orders' => $orders,
        'low_stock' => $lowStock,
        'new_orders' => $newOrders,
        'completed_orders' => $completed,
        'sales' => $sales,
        'sales_chart' => $salesChart,
    ];
}

function seller_build_sales_chart(array $completedOrders, int $days = 30): array
{
    $today = new DateTimeImmutable('today');
    $rows = [];

    for ($offset = max(1, $days) - 1; $offset >= 0; $offset--) {
        $date = $today->modify('-' . $offset . ' days');
        $key = $date->format('Y-m-d');
        $rows[$key] = [
            'date' => $key,
            'label' => $date->format('d M'),
            'amount' => 0.0,
            'orders' => 0,
        ];
    }

    foreach ($completedOrders as $order) {
        $timestamp = strtotime((string) ($order['tanggal'] ?? ''));
        if ($timestamp === false) {
            continue;
        }

        $key = date('Y-m-d', $timestamp);
        if (!isset($rows[$key])) {
            continue;
        }

        $rows[$key]['amount'] += (float) ($order['total'] ?? 0);
        $rows[$key]['orders']++;
    }

    $maxAmount = 0.0;
    foreach ($rows as $row) {
        $maxAmount = max($maxAmount, (float) $row['amount']);
    }

    return [
        'days' => array_values($rows),
        'max_amount' => $maxAmount,
        'total_amount' => array_sum(array_column($rows, 'amount')),
        'total_orders' => array_sum(array_column($rows, 'orders')),
    ];
}

function seller_build_demo_sales_chart(int $days = 30): array
{
    $days = max(1, $days);
    $today = new DateTimeImmutable('today');
    $rows = [];
    $pattern = [
        0,
        42000,
        78000,
        64000,
        108000,
        92000,
        56000,
        30000,
        84000,
        132000,
        101000,
        72000,
        54000,
        98000,
        145000,
        87000,
        63000,
        24000,
        76000,
        110000,
        96000,
        69000,
        51000,
        125000,
        148000,
        88000,
        64000,
        35000,
        91000,
        136000,
    ];

    for ($offset = $days - 1; $offset >= 0; $offset--) {
        $date = $today->modify('-' . $offset . ' days');
        $key = $date->format('Y-m-d');
        $index = ($days - 1) - $offset;
        $amount = (float) ($pattern[$index % count($pattern)] ?? 0);

        $rows[$key] = [
            'date' => $key,
            'label' => $date->format('d M'),
            'amount' => $amount,
            'orders' => $amount > 0 ? max(1, (int) round($amount / 45000)) : 0,
        ];
    }

    $maxAmount = 0.0;
    foreach ($rows as $row) {
        $maxAmount = max($maxAmount, (float) $row['amount']);
    }

    return [
        'days' => array_values($rows),
        'max_amount' => $maxAmount,
        'total_amount' => array_sum(array_column($rows, 'amount')),
        'total_orders' => array_sum(array_column($rows, 'orders')),
        'is_demo' => true,
    ];
}

function seller_fetch_customers(string $sellerUserId): array
{
    $orders = seller_fetch_order_summaries($sellerUserId);
    $customers = [];

    foreach ($orders as $order) {
        $buyerId = (string) ($order['buyer_id'] ?? '');
        $key = $buyerId !== '' ? $buyerId : strtolower((string) ($order['pembeli'] ?? ''));
        if ($key === '') {
            continue;
        }

        $customers[$key] ??= [
            'nama' => (string) ($order['pembeli'] ?? 'Pelanggan'),
            'email' => (string) ($order['buyer_email'] ?? ''),
            'orders' => 0,
            'total' => 0,
            'last' => (string) ($order['tanggal'] ?? ''),
        ];

        $customers[$key]['orders']++;
        $customers[$key]['total'] += (float) ($order['total'] ?? 0);

        $currentDate = strtotime((string) $customers[$key]['last']) ?: 0;
        $newDate = strtotime((string) ($order['tanggal'] ?? '')) ?: 0;
        if ($newDate > $currentDate) {
            $customers[$key]['last'] = (string) ($order['tanggal'] ?? '');
        }
    }

    usort($customers, static fn (array $a, array $b): int => strcmp((string) $b['last'], (string) $a['last']));
    return array_values($customers);
}

function seller_fetch_transactions(string $sellerUserId): array
{
    $orders = seller_fetch_order_summaries($sellerUserId, ['status' => 'selesai']);
    return array_values(array_map(static function (array $order): array {
        return [
            'tanggal' => (string) ($order['tanggal'] ?? ''),
            'deskripsi' => 'Penjualan ' . (string) ($order['kode_pesanan'] ?? $order['id_pesanan']),
            'tipe' => 'Masuk',
            'jumlah' => (float) ($order['total'] ?? 0),
            'status' => 'selesai',
        ];
    }, $orders));
}

function seller_update_store_profile(string $sellerUserId, string $tab, array $post, array $files): array
{
    $profile = seller_fetch_profile($sellerUserId);
    if ($profile === null) {
        return ['success' => false, 'type' => 'danger', 'message' => 'Profil seller tidak ditemukan.'];
    }

    if ($tab === 'profil') {
        $sellerPayload = [
            'nama_toko' => trim((string) ($post['nama_toko'] ?? '')),
            'deskripsi_toko' => trim((string) ($post['deskripsi'] ?? '')),
            'updated_at' => gmdate('c'),
        ];

        if ($sellerPayload['nama_toko'] === '') {
            return ['success' => false, 'type' => 'danger', 'message' => 'Nama toko wajib diisi.'];
        }

        $logoFile = $files['logo'] ?? null;
        $logoUploads = seller_normalize_uploaded_files(is_array($logoFile) ? $logoFile : []);
        if ($logoUploads !== []) {
            $logo = $logoUploads[0];
            $tmpPath = (string) ($logo['tmp_name'] ?? '');
            if ($tmpPath !== '' && is_file($tmpPath)) {
                $name = preg_replace('/[^A-Za-z0-9._-]/', '_', (string) ($logo['name'] ?? 'logo.jpg')) ?: 'logo.jpg';
                $storagePath = 'stores/' . $sellerUserId . '/' . time() . '_' . $name;
                $binary = file_get_contents($tmpPath);
                if ($binary !== false && supabase_storage_upload(SELLER_PRODUCT_BUCKET, $storagePath, $binary, seller_detect_mime_type($tmpPath))) {
                    $sellerPayload['foto_toko'] = supabase_storage_public_url(SELLER_PRODUCT_BUCKET, $storagePath);
                }
            }
        }

        $updated = supabase_update('seller', $sellerPayload, [
            'id_masyarakat' => 'eq.' . $sellerUserId,
        ]);
        if ($updated === [] && supabase_last_error() !== null) {
            return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal menyimpan profil toko.')];
        }

        $profilePayload = [
            'email' => trim((string) ($post['email'] ?? '')),
            'no_telp' => trim((string) ($post['telepon'] ?? '')),
            'updated_at' => gmdate('c'),
        ];
        supabase_update('profiles', $profilePayload, ['id' => 'eq.' . $sellerUserId]);

        $bankName = trim((string) ($post['bank_name'] ?? ''));
        $bankOwner = trim((string) ($post['bank_owner'] ?? ''));
        $bankAccountNumber = preg_replace('/\D+/', '', (string) ($post['bank_account_number'] ?? '')) ?? '';
        $hasAnyBankInput = $bankName !== '' || $bankOwner !== '' || $bankAccountNumber !== '';

        if ($hasAnyBankInput) {
            if ($bankName === '' || $bankOwner === '' || strlen($bankAccountNumber) < 6) {
                return ['success' => false, 'type' => 'danger', 'message' => 'Lengkapi data rekening: nama bank, nama pemilik, dan nomor rekening minimal 6 digit.'];
            }

            $last4 = strlen($bankAccountNumber) >= 4
                ? substr($bankAccountNumber, -4)
                : str_pad($bankAccountNumber, 4, '0', STR_PAD_LEFT);
            $existingBank = $profile['rekening_bank'] ?? null;
            $bankPayload = [
                'id_masyarakat' => $sellerUserId,
                'nama_bank' => $bankName,
                'jenis_kartu' => 'Debit',
                'nama_pemilik' => $bankOwner,
                'last4_digit' => $last4,
                'kartu_utama' => true,
                'status_aktif' => true,
                'updated_at' => gmdate('c'),
            ];

            if (is_array($existingBank) && ($existingBank['id_kartu'] ?? '') !== '') {
                $updatedBank = supabase_update('kartu_pembayaran', $bankPayload, [
                    'id_kartu' => 'eq.' . $existingBank['id_kartu'],
                    'id_masyarakat' => 'eq.' . $sellerUserId,
                ]);

                if ($updatedBank === [] && supabase_last_error() !== null) {
                    return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal memperbarui rekening bank.')];
                }
            } else {
                $bankPayload['created_at'] = gmdate('c');
                $insertedBank = supabase_insert('kartu_pembayaran', $bankPayload);
                if ($insertedBank === [] && supabase_last_error() !== null) {
                    return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal menambahkan rekening bank.')];
                }
            }
        }

        if (isset($_SESSION['dashboard_user']) && is_array($_SESSION['dashboard_user'])) {
            $_SESSION['dashboard_user']['nama_toko'] = $sellerPayload['nama_toko'];
            $_SESSION['dashboard_user']['email'] = $profilePayload['email'];
            if (isset($sellerPayload['foto_toko'])) {
                $_SESSION['dashboard_user']['foto_toko'] = $sellerPayload['foto_toko'];
            }
        }

        return ['success' => true, 'type' => 'success', 'message' => 'Profil toko berhasil diperbarui.'];
    }

    if ($tab === 'alamat') {
        $alamat = trim((string) ($post['alamat_toko'] ?? ''));
        if ($alamat === '') {
            return ['success' => false, 'type' => 'danger', 'message' => 'Alamat toko wajib diisi.'];
        }

        $updated = supabase_update('seller', [
            'alamat_toko' => $alamat,
            'updated_at' => gmdate('c'),
        ], [
            'id_masyarakat' => 'eq.' . $sellerUserId,
        ]);

        if ($updated === [] && supabase_last_error() !== null) {
            return ['success' => false, 'type' => 'danger', 'message' => seller_supabase_message('Gagal menyimpan alamat toko.')];
        }

        return ['success' => true, 'type' => 'success', 'message' => 'Alamat toko berhasil diperbarui.'];
    }

    return ['success' => true, 'type' => 'warning', 'message' => 'Tab ini belum memiliki tabel khusus di database seller.'];
}

function seller_in_filter(array $values): ?string
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

function seller_supabase_message(string $fallback): string
{
    $error = supabase_last_error();
    return $error !== null ? $fallback . ' ' . $error : $fallback;
}
