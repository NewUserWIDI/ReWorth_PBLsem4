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

function mock_admin_overview(): array
{
    return [
        'total_user' => 1248,
        'total_seller' => 342,
        'total_laporan_sampah' => 756,
        'total_transaksi' => 2453,
        'total_pendapatan' => 45780000,
    ];
}

function mock_admin_users(): array
{
    return [
        ['id_user' => 'USR-1001', 'nama' => 'Fatma Azzahra', 'email' => 'fatma@mail.com', 'role' => 'masyarakat', 'status' => 'aktif', 'tanggal_bergabung' => '2026-02-01', 'total_laporan' => 7, 'total_poin' => 181],
        ['id_user' => 'USR-1002', 'nama' => 'Bima Saputra', 'email' => 'bima@mail.com', 'role' => 'masyarakat', 'status' => 'aktif', 'tanggal_bergabung' => '2026-02-03', 'total_laporan' => 4, 'total_poin' => 90],
        ['id_user' => 'USR-1003', 'nama' => 'Nadia Putri', 'email' => 'nadia@mail.com', 'role' => 'masyarakat', 'status' => 'suspend', 'tanggal_bergabung' => '2026-02-07', 'total_laporan' => 1, 'total_poin' => 20],
        ['id_user' => 'USR-1004', 'nama' => 'Dina Maharani', 'email' => 'dina@mail.com', 'role' => 'masyarakat', 'status' => 'aktif', 'tanggal_bergabung' => '2026-03-12', 'total_laporan' => 9, 'total_poin' => 240],
        ['id_user' => 'USR-1005', 'nama' => 'Arman Siregar', 'email' => 'arman@mail.com', 'role' => 'masyarakat', 'status' => 'aktif', 'tanggal_bergabung' => '2026-04-16', 'total_laporan' => 2, 'total_poin' => 32],
        ['id_user' => 'ADM-0001', 'nama' => 'Admin Utama', 'email' => 'admin@reworth.app', 'role' => 'admin', 'status' => 'aktif', 'tanggal_bergabung' => '2025-11-01', 'total_laporan' => 0, 'total_poin' => 0],
        ['id_user' => 'DLH-0001', 'nama' => 'Petugas DLH', 'email' => 'dlh@reworth.app', 'role' => 'dlh', 'status' => 'aktif', 'tanggal_bergabung' => '2025-11-10', 'total_laporan' => 0, 'total_poin' => 0],
    ];
}

function mock_admin_sellers(): array
{
    return [
        ['id_seller' => 'SEL-5001', 'nama_toko' => 'Toko Daur Fatma', 'pemilik' => 'Fatma Azzahra', 'email' => 'seller1@reworth.app', 'jumlah_produk' => 18, 'status_verifikasi' => 'menunggu', 'status_toko' => 'aktif', 'tanggal_bergabung' => '2026-05-26', 'alasan_penolakan' => ''],
        ['id_seller' => 'SEL-5002', 'nama_toko' => 'Hijau Bersih Store', 'pemilik' => 'Bima Saputra', 'email' => 'seller2@reworth.app', 'jumlah_produk' => 21, 'status_verifikasi' => 'menunggu', 'status_toko' => 'aktif', 'tanggal_bergabung' => '2026-05-25', 'alasan_penolakan' => ''],
        ['id_seller' => 'SEL-5003', 'nama_toko' => 'EcoCycle Shop', 'pemilik' => 'Nadia Putri', 'email' => 'seller3@reworth.app', 'jumlah_produk' => 9, 'status_verifikasi' => 'terverifikasi', 'status_toko' => 'aktif', 'tanggal_bergabung' => '2026-04-10', 'alasan_penolakan' => ''],
        ['id_seller' => 'SEL-5004', 'nama_toko' => 'Daur Ulang Kita', 'pemilik' => 'Rizki Aditya', 'email' => 'seller4@reworth.app', 'jumlah_produk' => 6, 'status_verifikasi' => 'ditolak', 'status_toko' => 'nonaktif', 'tanggal_bergabung' => '2026-04-12', 'alasan_penolakan' => 'Dokumen toko belum lengkap.'],
        ['id_seller' => 'SEL-5005', 'nama_toko' => 'Kompos Lestari', 'pemilik' => 'Sari Wulandari', 'email' => 'seller5@reworth.app', 'jumlah_produk' => 15, 'status_verifikasi' => 'terverifikasi', 'status_toko' => 'aktif', 'tanggal_bergabung' => '2026-03-05', 'alasan_penolakan' => ''],
    ];
}

function mock_admin_products(): array
{
    return [
        ['id_produk' => 'PRD-9001', 'foto' => 'assets/logo_reworth.jpeg', 'nama_produk' => 'Tas Anyam Daur Ulang', 'seller' => 'Toko Daur Fatma', 'kategori' => 'Kerajinan', 'harga' => 125000, 'stok' => 14, 'status_produk' => 'aktif', 'tanggal_dibuat' => '2026-05-01'],
        ['id_produk' => 'PRD-9002', 'foto' => 'assets/logo_reworth.jpeg', 'nama_produk' => 'Pot Tanam Botol', 'seller' => 'Hijau Bersih Store', 'kategori' => 'Dekorasi', 'harga' => 55000, 'stok' => 9, 'status_produk' => 'pending', 'tanggal_dibuat' => '2026-05-03'],
        ['id_produk' => 'PRD-9003', 'foto' => 'assets/logo_reworth.jpeg', 'nama_produk' => 'Pupuk Kompos 5kg', 'seller' => 'Kompos Lestari', 'kategori' => 'Kompos', 'harga' => 40000, 'stok' => 40, 'status_produk' => 'aktif', 'tanggal_dibuat' => '2026-04-11'],
        ['id_produk' => 'PRD-9004', 'foto' => 'assets/logo_reworth.jpeg', 'nama_produk' => 'Dompet Kertas Daur', 'seller' => 'EcoCycle Shop', 'kategori' => 'Kerajinan', 'harga' => 70000, 'stok' => 5, 'status_produk' => 'disembunyikan', 'tanggal_dibuat' => '2026-04-20'],
        ['id_produk' => 'PRD-9005', 'foto' => 'assets/logo_reworth.jpeg', 'nama_produk' => 'Eco Brick Kit', 'seller' => 'Daur Ulang Kita', 'kategori' => 'Edukasi', 'harga' => 85000, 'stok' => 0, 'status_produk' => 'nonaktif', 'tanggal_dibuat' => '2026-03-28'],
    ];
}

function mock_admin_transactions(): array
{
    return [
        ['id_transaksi' => 'INV-7001', 'pembeli' => 'Fatma Azzahra', 'seller' => 'EcoCycle Shop', 'total' => 245000, 'status' => 'pending', 'tanggal' => '2026-05-30'],
        ['id_transaksi' => 'INV-7002', 'pembeli' => 'Bima Saputra', 'seller' => 'Kompos Lestari', 'total' => 40000, 'status' => 'diproses', 'tanggal' => '2026-05-30'],
        ['id_transaksi' => 'INV-7003', 'pembeli' => 'Nadia Putri', 'seller' => 'Toko Daur Fatma', 'total' => 125000, 'status' => 'selesai', 'tanggal' => '2026-05-29'],
        ['id_transaksi' => 'INV-7004', 'pembeli' => 'Dina Maharani', 'seller' => 'Hijau Bersih Store', 'total' => 55000, 'status' => 'dibatalkan', 'tanggal' => '2026-05-28'],
        ['id_transaksi' => 'INV-7005', 'pembeli' => 'Arman Siregar', 'seller' => 'Kompos Lestari', 'total' => 160000, 'status' => 'selesai', 'tanggal' => '2026-05-27'],
    ];
}

function mock_admin_system_activities(): array
{
    return [
        ['waktu' => '2026-05-30 10:12:00', 'aktor' => 'Admin Utama', 'role' => 'admin', 'aktivitas' => 'Verifikasi Seller', 'modul' => 'Manajemen Seller', 'detail' => 'Seller Toko Daur Fatma diverifikasi'],
        ['waktu' => '2026-05-30 09:44:00', 'aktor' => 'Fatma Azzahra', 'role' => 'masyarakat', 'aktivitas' => 'Laporan Masuk', 'modul' => 'Laporan Sampah', 'detail' => 'Laporan #1005 dibuat'],
        ['waktu' => '2026-05-30 09:05:00', 'aktor' => 'Petugas DLH', 'role' => 'dlh', 'aktivitas' => 'Status Laporan Berubah', 'modul' => 'Monitoring', 'detail' => 'Laporan #1002 diubah ke diproses'],
        ['waktu' => '2026-05-30 08:40:00', 'aktor' => 'Bima Saputra', 'role' => 'masyarakat', 'aktivitas' => 'Register', 'modul' => 'Auth', 'detail' => 'Akun baru terdaftar'],
        ['waktu' => '2026-05-29 20:10:00', 'aktor' => 'Nadia Putri', 'role' => 'masyarakat', 'aktivitas' => 'Transaksi Dibuat', 'modul' => 'Mini Market', 'detail' => 'Invoice INV-7003 berhasil dibuat'],
        ['waktu' => '2026-05-29 17:22:00', 'aktor' => 'EcoCycle Shop', 'role' => 'seller', 'aktivitas' => 'Produk Dibuat', 'modul' => 'Produk', 'detail' => 'Produk PRD-9004 ditambahkan'],
    ];
}

