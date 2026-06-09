<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';
/**
 * Ambil data laporan dari Supabase
 */
function dlh_reports(array $filters = []): array

{
    // Ambil semua laporan tanpa batasan
    $response = supabase_request('GET', 'laporan_sampah', [
        'limit' => '1000',
        'order' => 'id_laporan.desc'
    ], null);
    
    if ($response['status'] !== 200) {
        return [];
    }
    
    $result = $response['data'];
    
    if (!is_array($result)) {
        return [];
    }
    
    // Kumpulkan semua id_masyarakat untuk diambil sekaligus (lebih efisien)
    $userIds = [];
    foreach ($result as $row) {
        if (!empty($row['id_masyarakat']) && !in_array($row['id_masyarakat'], $userIds)) {
            $userIds[] = $row['id_masyarakat'];
        }
    }
    
    // Ambil semua profiles sekaligus
    $profilesMap = [];
    if (!empty($userIds)) {
        $idsString = implode(',', array_map(function($id) { return "eq.$id"; }, $userIds));
        $profilesResponse = supabase_request('GET', 'profiles', [
            'id' => 'in.(' . implode(',', $userIds) . ')',
            'limit' => '1000'
        ], null);
        
        if ($profilesResponse['status'] === 200 && is_array($profilesResponse['data'])) {
            foreach ($profilesResponse['data'] as $profile) {
                $profilesMap[$profile['id']] = $profile;
            }
        }
    }
    
    // Bangun array laporan
    $reports = [];
    foreach ($result as $row) {
        $profile = $profilesMap[$row['id_masyarakat']] ?? [];
        
        $reports[] = [
            'id_laporan' => $row['id_laporan'] ?? null,
            'id_masyarakat' => $row['id_masyarakat'] ?? null,
            'poin_diberikan' => $row['poin_diberikan'] ?? 0,

            'foto_sampah' => $row['foto_sampah'] ?? '',
            'jalan' => $row['jalan'] ?? '',
            'kelurahan' => $row['kelurahan'] ?? '',
            'kecamatan' => $row['kecamatan'] ?? '',
            'patokan' => $row['patokan'] ?? '',
            'deskripsi' => $row['deskripsi'] ?? '',
            'jenis_sampah' => $row['jenis_sampah'] ?? '',
            'tingkat_keparahan' => $row['tingkat_keparahan'] ?? '',
            'status_laporan' => $row['status_laporan'] ?? '',
            'alasan_ditolak' => $row['alasan_ditolak'] ?? null,
            'waktu_lapor' => $row['waktu_lapor'] ?? '',
            'latitude' => $row['latitude'] ?? null,
            'longitude' => $row['longitude'] ?? null,
            'poin_diberikan' => $row['poin_diberikan'] ?? 0,
            'nama_pelapor' => $profile['nama_lengkap'] ?? $profile['nama'] ?? '-',
            'email_pelapor' => $profile['email'] ?? '-',
            'no_telp_pelapor' => $profile['no_telp'] ?? '-',
        ];
    }
    
    // Filter status
    if (!empty($filters['status'])) {
        $reports = array_filter($reports, function($report) use ($filters) {
            return strtolower($report['status_laporan']) === strtolower($filters['status']);
        });
    }
    
    // Filter tingkat keparahan
    if (!empty($filters['severity'])) {
        $reports = array_filter($reports, function($report) use ($filters) {
            return strtolower($report['tingkat_keparahan']) === strtolower($filters['severity']);
        });
    }
    
    // Filter kecamatan
    if (!empty($filters['kecamatan'])) {
        $reports = array_filter($reports, function($report) use ($filters) {
            return strtolower($report['kecamatan']) === strtolower($filters['kecamatan']);
        });
    }
    
    // Filter pencarian
    if (!empty($filters['q'])) {
        $q = strtolower($filters['q']);
        $reports = array_filter($reports, function($report) use ($q) {
            return str_contains(strtolower($report['jalan'] ?? ''), $q)
                || str_contains(strtolower($report['kecamatan'] ?? ''), $q)
                || str_contains(strtolower($report['nama_pelapor'] ?? ''), $q)
                || str_contains((string)($report['id_laporan'] ?? ''), $q);
        });
    }
    
    // Filter tanggal
    if (!empty($filters['date_from'])) {
        $reports = array_filter($reports, function($report) use ($filters) {
            $tanggal = substr($report['waktu_lapor'] ?? '', 0, 10);
            return $tanggal >= $filters['date_from'];
        });
    }
    if (!empty($filters['date_to'])) {
        $reports = array_filter($reports, function($report) use ($filters) {
            $tanggal = substr($report['waktu_lapor'] ?? '', 0, 10);
            return $tanggal <= $filters['date_to'];
        });
    }
    
    return array_values($reports);
}

/**
 * Ambil laporan berdasarkan ID
 */
function dlh_report_by_id(int $idLaporan): ?array
{
    $response = supabase_request('GET', 'laporan_sampah', [
        'id_laporan' => 'eq.' . $idLaporan,
        'limit' => '1'
    ], null);
    
    if ($response['status'] !== 200 || empty($response['data'])) {
        return null;
    }
    
    $row = $response['data'][0];
    
    // Ambil data pelapor
    $profileResponse = supabase_request('GET', 'profiles', [
        'id' => 'eq.' . $row['id_masyarakat'],
        'limit' => '1'
    ], null);
    
    $profile = [];
    if ($profileResponse['status'] === 200 && !empty($profileResponse['data'])) {
        $profile = $profileResponse['data'][0];
    }
    
    return [
        'id_laporan' => $row['id_laporan'] ?? null,
        'foto_sampah' => $row['foto_sampah'] ?? '',
        'jalan' => $row['jalan'] ?? '',
        'kelurahan' => $row['kelurahan'] ?? '',
        'kecamatan' => $row['kecamatan'] ?? '',
        'patokan' => $row['patokan'] ?? '',
        'deskripsi' => $row['deskripsi'] ?? '',
        'jenis_sampah' => $row['jenis_sampah'] ?? '',
        'tingkat_keparahan' => $row['tingkat_keparahan'] ?? '',
        'status_laporan' => $row['status_laporan'] ?? '',
        'alasan_ditolak' => $row['alasan_ditolak'] ?? null,
        'waktu_lapor' => $row['waktu_lapor'] ?? '',
        'updated_at' => $row['updated_at'] ?? $row['waktu_lapor'] ?? '',  // ← TAMBAHKAN INI
        'latitude' => $row['latitude'] ?? null,
        'longitude' => $row['longitude'] ?? null,
        'poin_diberikan' => $row['poin_diberikan'] ?? 0,
        'nama_pelapor' => $profile['nama_lengkap'] ?? $profile['nama'] ?? '-',
        'email_pelapor' => $profile['email'] ?? '-',
        'no_telp_pelapor' => $profile['no_telp'] ?? '-',
    ];
}

/**
 * Hitung jumlah laporan berdasarkan status
 */
function dlh_status_count(array $reports, string $status): int
{
    return count(array_filter($reports, function ($item) use ($status) {
        return strtolower($item['status_laporan'] ?? '') === strtolower($status);
    }));
}

/**
 * Hitung jumlah laporan berdasarkan tingkat keparahan
 */
function dlh_severity_count(array $reports, string $severity): int
{
    return count(array_filter($reports, fn (array $item): bool => 
        strtolower($item['tingkat_keparahan'] ?? '') === strtolower($severity)
    ));
}

/**
 * Hitung total poin dari laporan yang valid
 */
function dlh_total_poin(array $reports): int
{
    return array_sum(array_column($reports, 'poin_diberikan'));
}

/**
 * Ambil laporan aktif (menunggu/diproses) yang memiliki koordinat
 */
function dlh_active_reports(array $reports): array
{
    return array_values(array_filter($reports, function (array $item): bool {
        $status = strtolower($item['status_laporan'] ?? '');
        $lat = $item['latitude'] ?? null;
        $lng = $item['longitude'] ?? null;

        return in_array($status, ['menunggu', 'diproses', 'pending', 'processing'], true)
            && is_numeric($lat)
            && is_numeric($lng);
    }));
}
/**
 * Ambil daftar kecamatan unik dari laporan
 */
function dlh_unique_kecamatan(): array
{
    $response = supabase_request('GET', 'laporan_sampah', [
        'select' => 'kecamatan',
        'limit' => '1000'
    ], null);
    
    $kecamatan = [];
    if ($response['status'] === 200 && is_array($response['data'])) {
        foreach ($response['data'] as $row) {
            $kec = $row['kecamatan'] ?? '';
            if (!empty($kec) && !in_array($kec, $kecamatan)) {
                $kecamatan[] = $kec;
            }
        }
    }
    sort($kecamatan);
    return $kecamatan;
}

/**
 * Update status laporan
 */
function dlh_update_status(int $id, string $status, ?string $alasan = null, ?int $poin = null): bool
{
    $data = [
        'status_laporan' => $status,
        'updated_at' => date('Y-m-d H:i:s')
    ];

    if ($alasan !== null) {
        $data['alasan_ditolak'] = $alasan;
    }

    if ($poin !== null) {
        $data['poin_diberikan'] = $poin;
    }

    $result = supabase_update(
        'laporan_sampah',
        $data,
        ['id_laporan' => 'eq.' . $id]
    );

    return is_array($result);
}

/**
 * Path ilustrasi DLH
 */
function dlh_illustration_path(): string
{
    $singleCandidates = ['assets/dlh.png', 'assets/dlh.jpg', 'assets/dlh.jpeg', 'assets/dlh.webp'];
    foreach ($singleCandidates as $path) {
        if (is_file(__DIR__ . '/../../' . $path)) { 
            return $path;
        }
    }

    $folderCandidates = glob(__DIR__ . '/../../assets/dlh/*.{png,jpg,jpeg,webp,svg}', GLOB_BRACE) ?: [];
    if ($folderCandidates !== []) {
        $first = basename($folderCandidates[0]);
        return 'assets/dlh/' . $first;
    }

    return 'assets/dlh.png';
}

/**
 * Path ilustrasi Admin
 */
function admin_illustration_path(): string
{
    $singleCandidates = ['assets/ilust_admin.png', 'assets/ilust_admin.jpg', 'assets/ilust_admin.jpeg', 'assets/ilust_admin.webp'];
    foreach ($singleCandidates as $path) {
        if (is_file(__DIR__ . '/../../' . $path)) {
            return $path;
        }
    }

    $folderCandidates = glob(__DIR__ . '/../../assets/ilust_admin/*.{png,jpg,jpeg,webp,svg}', GLOB_BRACE) ?: [];
    if ($folderCandidates !== []) {
        $first = basename($folderCandidates[0]);
        return 'assets/ilust_admin/' . $first;
    }

    return 'assets/ilust_admin.png';
}