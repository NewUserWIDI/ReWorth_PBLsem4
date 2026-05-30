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

function mock_rewards(): array
{
    return [
        ['id' => 'RWD-001', 'user' => 'Fatma Azzahra', 'jenis' => 'Pulsa Rp10.000', 'poin' => 70, 'status' => 'diproses'],
        ['id' => 'RWD-002', 'user' => 'Bima Saputra', 'jenis' => 'Kuota WhatsApp 1GB', 'poin' => 30, 'status' => 'selesai'],
    ];
}

function mock_dlh_reports(): array
{
    return [
        [
            'id_laporan' => 1001,
            'id_masyarakat' => '6c19f9a0-7516-4ecb-94f7-ec8cf5ff1111',
            'pelapor' => 'Fatma Azzahra',
            'foto_sampah' => 'assets/logo_reworth.jpeg',
            'latitude' => -6.92390,
            'longitude' => 107.63740,
            'jalan' => 'Jl. Soekarno Hatta No. 45',
            'kelurahan' => 'Jatimulyo',
            'kecamatan' => 'Lowokwaru',
            'patokan' => 'Dekat minimarket pojok',
            'deskripsi' => 'Sampah menumpuk menutup setengah trotoar dan mulai bau.',
            'jenis_sampah' => 'anorganik',
            'tingkat_keparahan' => 'sedang',
            'status_laporan' => 'menunggu',
            'alasan_ditolak' => '',
            'poin_diberikan' => 0,
            'waktu_lapor' => '2026-05-30 08:15:00',
            'updated_at' => '2026-05-30 08:15:00',
        ],
        [
            'id_laporan' => 1002,
            'id_masyarakat' => '8d39f3d2-2d1d-4f5c-b3ce-ec8cf5ff2222',
            'pelapor' => 'Bima Saputra',
            'foto_sampah' => 'assets/logo_reworth.jpeg',
            'latitude' => -6.91870,
            'longitude' => 107.61600,
            'jalan' => 'Jl. Ahmad Yani No. 12',
            'kelurahan' => 'Cihapit',
            'kecamatan' => 'Bandung Wetan',
            'patokan' => 'Depan halte bus',
            'deskripsi' => 'Tumpukan sampah campuran mengganggu pejalan kaki.',
            'jenis_sampah' => 'campuran',
            'tingkat_keparahan' => 'parah',
            'status_laporan' => 'diproses',
            'alasan_ditolak' => '',
            'poin_diberikan' => 0,
            'waktu_lapor' => '2026-05-29 18:30:00',
            'updated_at' => '2026-05-30 09:05:00',
        ],
        [
            'id_laporan' => 1003,
            'id_masyarakat' => '32f3408f-79b2-47ac-8a8d-ec8cf5ff3333',
            'pelapor' => 'Nadia Putri',
            'foto_sampah' => 'assets/logo_reworth.jpeg',
            'latitude' => -6.91020,
            'longitude' => 107.62210,
            'jalan' => 'Jl. Asia Afrika No. 7',
            'kelurahan' => 'Braga',
            'kecamatan' => 'Sumur Bandung',
            'patokan' => 'Seberang museum',
            'deskripsi' => 'Sampah organik menumpuk di sisi drainase.',
            'jenis_sampah' => 'organik',
            'tingkat_keparahan' => 'ringan',
            'status_laporan' => 'selesai',
            'alasan_ditolak' => '',
            'poin_diberikan' => 10,
            'waktu_lapor' => '2026-05-28 07:45:00',
            'updated_at' => '2026-05-29 14:10:00',
        ],
        [
            'id_laporan' => 1004,
            'id_masyarakat' => '3400f8ff-7be8-4c62-bf6f-ec8cf5ff4444',
            'pelapor' => 'Rizki Aditya',
            'foto_sampah' => 'assets/logo_reworth.jpeg',
            'latitude' => -6.93260,
            'longitude' => 107.61160,
            'jalan' => 'Jl. Dipatiukur No. 77',
            'kelurahan' => 'Lebakgede',
            'kecamatan' => 'Coblong',
            'patokan' => 'Dekat kampus',
            'deskripsi' => 'Foto kurang jelas dan lokasi laporan tidak akurat.',
            'jenis_sampah' => 'lainnya',
            'tingkat_keparahan' => 'ringan',
            'status_laporan' => 'ditolak',
            'alasan_ditolak' => 'Foto tidak cukup jelas untuk verifikasi lapangan.',
            'poin_diberikan' => 0,
            'waktu_lapor' => '2026-05-27 12:21:00',
            'updated_at' => '2026-05-27 13:10:00',
        ],
        [
            'id_laporan' => 1005,
            'id_masyarakat' => '8a2fbe29-7ed2-4a30-9b4d-ec8cf5ff5555',
            'pelapor' => 'Dina Maharani',
            'foto_sampah' => 'assets/logo_reworth.jpeg',
            'latitude' => -6.94440,
            'longitude' => 107.61320,
            'jalan' => 'Jl. Terusan Jakarta No. 9',
            'kelurahan' => 'Antapani Tengah',
            'kecamatan' => 'Antapani',
            'patokan' => 'Samping pos ronda',
            'deskripsi' => 'Sampah plastik menumpuk dan hampir menutup saluran air.',
            'jenis_sampah' => 'anorganik',
            'tingkat_keparahan' => 'parah',
            'status_laporan' => 'menunggu',
            'alasan_ditolak' => '',
            'poin_diberikan' => 0,
            'waktu_lapor' => '2026-05-30 06:35:00',
            'updated_at' => '2026-05-30 06:35:00',
        ],
        [
            'id_laporan' => 1006,
            'id_masyarakat' => '22ec5ab2-e159-43eb-af58-ec8cf5ff6666',
            'pelapor' => 'Arman Siregar',
            'foto_sampah' => 'assets/logo_reworth.jpeg',
            'latitude' => -6.93520,
            'longitude' => 107.64010,
            'jalan' => 'Jl. Cikutra Barat No. 14',
            'kelurahan' => 'Neglasari',
            'kecamatan' => 'Cibeunying Kaler',
            'patokan' => 'Belakang sekolah',
            'deskripsi' => 'Sampah basah menimbulkan bau menyengat.',
            'jenis_sampah' => 'organik',
            'tingkat_keparahan' => 'sedang',
            'status_laporan' => 'diproses',
            'alasan_ditolak' => '',
            'poin_diberikan' => 0,
            'waktu_lapor' => '2026-05-30 11:11:00',
            'updated_at' => '2026-05-30 11:45:00',
        ],
        [
            'id_laporan' => 1007,
            'id_masyarakat' => 'a47f6f2c-2645-4cc8-a46f-ec8cf5ff7777',
            'pelapor' => 'Yuni Kartika',
            'foto_sampah' => 'assets/logo_reworth.jpeg',
            'latitude' => -6.90350,
            'longitude' => 107.60990,
            'jalan' => 'Jl. Merdeka No. 1',
            'kelurahan' => 'Babakan Ciamis',
            'kecamatan' => 'Sumur Bandung',
            'patokan' => 'Dekat taman kota',
            'deskripsi' => 'Laporan sudah ditangani petugas lapangan.',
            'jenis_sampah' => 'campuran',
            'tingkat_keparahan' => 'ringan',
            'status_laporan' => 'selesai',
            'alasan_ditolak' => '',
            'poin_diberikan' => 10,
            'waktu_lapor' => '2026-05-26 09:09:00',
            'updated_at' => '2026-05-27 17:02:00',
        ],
    ];
}

function mock_dlh_officers(): array
{
    return [
        ['id_petugas' => 'PTG-001', 'nama' => 'Rudi Hartono', 'tim' => 'Tim A', 'wilayah' => 'Lowokwaru', 'kontak' => '0812-1111-2222', 'status' => 'aktif'],
        ['id_petugas' => 'PTG-002', 'nama' => 'Siti Nurhaliza', 'tim' => 'Tim B', 'wilayah' => 'Antapani', 'kontak' => '0812-3333-4444', 'status' => 'aktif'],
        ['id_petugas' => 'PTG-003', 'nama' => 'Agus Sapri', 'tim' => 'Tim C', 'wilayah' => 'Coblong', 'kontak' => '0812-5555-6666', 'status' => 'nonaktif'],
        ['id_petugas' => 'PTG-004', 'nama' => 'Mira Dewi', 'tim' => 'Tim A', 'wilayah' => 'Bandung Wetan', 'kontak' => '0812-7777-8888', 'status' => 'aktif'],
    ];
}

