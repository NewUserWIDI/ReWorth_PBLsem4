<?php

declare(strict_types=1);

function mock_password_hash(): string
{
    static $hash = null;
    $hash ??= password_hash('password123', PASSWORD_DEFAULT);
    return $hash;
}

function mock_dashboard_users(): array
{
    return [
        [
            'id' => 1,
            'nama' => 'Admin ReWorth',
            'email' => 'admin@reworth.app',
            'username' => 'admin',
            'password_hash' => mock_password_hash(),
            'role' => 'admin',
            'status' => 'aktif',
        ],
        [
            'id' => 2,
            'nama' => 'Petugas DLH',
            'email' => 'dlh@reworth.app',
            'username' => 'dlh',
            'password_hash' => mock_password_hash(),
            'role' => 'dlh',
            'status' => 'aktif',
        ],
        [
            'id' => 3,
            'nama' => 'Seller Eco Craft',
            'email' => 'seller@reworth.app',
            'username' => 'seller',
            'password_hash' => mock_password_hash(),
            'role' => 'seller',
            'status' => 'aktif',
        ],
        [
            'id' => 4,
            'nama' => 'Seller Menunggu',
            'email' => 'sellerpending@reworth.app',
            'username' => 'sellerpending',
            'password_hash' => mock_password_hash(),
            'role' => 'seller',
            'status' => 'pending',
        ],
    ];
}

function mock_stats(): array
{
    return [
        'users' => 128,
        'reports_total' => 46,
        'reports_waiting' => 12,
        'reports_valid' => 28,
        'reports_rejected' => 6,
        'active_sellers' => 9,
        'seller_requests' => 4,
        'products' => 37,
        'orders' => 18,
        'rewards' => 21,
        'sales' => 2450000,
    ];
}

function mock_reports(): array
{
    return [
        [
            'id' => 'LPR-001',
            'pelapor' => 'Fatma Azzahra',
            'alamat' => 'Jl. Veteran, Lowokwaru',
            'jenis' => 'campuran',
            'keparahan' => 'tinggi',
            'status' => 'menunggu_verifikasi',
            'tanggal' => '2026-05-10',
            'deskripsi' => 'Tumpukan sampah mengganggu pejalan kaki dan menutup sebagian trotoar.',
            'alasan_penolakan' => '',
        ],
        [
            'id' => 'LPR-002',
            'pelapor' => 'Bima Saputra',
            'alamat' => 'Jl. Bendungan Sutami',
            'jenis' => 'anorganik',
            'keparahan' => 'sedang',
            'status' => 'valid',
            'tanggal' => '2026-05-09',
            'deskripsi' => 'Sampah plastik menyumbat drainase kecil di pinggir jalan.',
            'alasan_penolakan' => '',
        ],
        [
            'id' => 'LPR-003',
            'pelapor' => 'Nadia Putri',
            'alamat' => 'Jl. Soekarno Hatta',
            'jenis' => 'organik',
            'keparahan' => 'rendah',
            'status' => 'ditolak',
            'tanggal' => '2026-05-08',
            'deskripsi' => 'Satu botol plastik di taman.',
            'alasan_penolakan' => 'Objek laporan terlalu kecil dan tidak berdampak signifikan.',
        ],
    ];
}

function mock_seller_requests(): array
{
    return [
        ['id' => 'SLR-101', 'nama' => 'Kompos Lestari', 'kategori' => 'Kompos', 'status' => 'pending', 'tanggal' => '2026-05-10'],
        ['id' => 'SLR-102', 'nama' => 'Eco Bag Malang', 'kategori' => 'Kerajinan Daur Ulang', 'status' => 'pending', 'tanggal' => '2026-05-09'],
    ];
}

function mock_sellers(): array
{
    return [
        ['id' => 'SEL-001', 'nama' => 'Eco Craft', 'produk' => 12, 'status' => 'aktif'],
        ['id' => 'SEL-002', 'nama' => 'Kompos Hijau', 'produk' => 8, 'status' => 'aktif'],
        ['id' => 'SEL-003', 'nama' => 'Daur Ulang Karya', 'produk' => 0, 'status' => 'nonaktif'],
    ];
}

function mock_products(): array
{
    return [
        ['id' => 'PRD-001', 'nama' => 'Tas Daur Ulang', 'seller' => 'Eco Craft', 'harga' => 45000, 'stok' => 20, 'status' => 'aktif'],
        ['id' => 'PRD-002', 'nama' => 'Kompos Organik 5kg', 'seller' => 'Kompos Hijau', 'harga' => 30000, 'stok' => 15, 'status' => 'aktif'],
        ['id' => 'PRD-003', 'nama' => 'Eco Enzyme', 'seller' => 'Kompos Hijau', 'harga' => 25000, 'stok' => 0, 'status' => 'nonaktif'],
    ];
}

function mock_orders(): array
{
    return [
        ['id' => 'ORD-001', 'pembeli' => 'Fatma Azzahra', 'total' => 90000, 'status' => 'baru', 'tanggal' => '2026-05-10'],
        ['id' => 'ORD-002', 'pembeli' => 'Bima Saputra', 'total' => 30000, 'status' => 'diproses', 'tanggal' => '2026-05-09'],
        ['id' => 'ORD-003', 'pembeli' => 'Nadia Putri', 'total' => 45000, 'status' => 'selesai', 'tanggal' => '2026-05-08'],
    ];
}

function mock_seller_weekly_revenue(): array
{
    return [
        ['label' => 'Sen', 'value' => 82000],
        ['label' => 'Sel', 'value' => 56000],
        ['label' => 'Rab', 'value' => 132000],
        ['label' => 'Kam', 'value' => 96000],
        ['label' => 'Jum', 'value' => 268000],
        ['label' => 'Sab', 'value' => 204000],
        ['label' => 'Min', 'value' => 118000],
    ];
}

function mock_seller_recent_orders(): array
{
    return [
        ['id' => 'ORD-1035', 'pembeli' => 'Maria Ulfa', 'total' => 78500, 'status' => 'diproses', 'tanggal' => '2026-05-12'],
        ['id' => 'ORD-1034', 'pembeli' => 'Lestari Dwi', 'total' => 117000, 'status' => 'baru', 'tanggal' => '2026-05-12'],
        ['id' => 'ORD-1033', 'pembeli' => 'Budi Santoso', 'total' => 134000, 'status' => 'baru', 'tanggal' => '2026-05-11'],
        ['id' => 'ORD-1032', 'pembeli' => 'Siti Nurhaliza', 'total' => 98000, 'status' => 'diproses', 'tanggal' => '2026-05-11'],
        ['id' => 'ORD-1031', 'pembeli' => 'Ahmad Saputra', 'total' => 145000, 'status' => 'baru', 'tanggal' => '2026-05-10'],
    ];
}

function mock_seller_low_stock(): array
{
    return [
        ['nama' => 'Pupuk Organik 50 ml', 'stok' => 0],
        ['nama' => 'Eco Enzyme 1Lt', 'stok' => 0],
        ['nama' => 'Pupuk Kompos 2Kg', 'stok' => 5],
        ['nama' => 'Maggot BSF', 'stok' => 6],
        ['nama' => 'Biogas Starter', 'stok' => 8],
    ];
}

function mock_rewards(): array
{
    return [
        ['id' => 'RWD-001', 'user' => 'Fatma Azzahra', 'jenis' => 'Pulsa Rp10.000', 'poin' => 70, 'status' => 'diproses'],
        ['id' => 'RWD-002', 'user' => 'Bima Saputra', 'jenis' => 'Kuota WhatsApp 1GB', 'poin' => 30, 'status' => 'selesai'],
    ];
}
