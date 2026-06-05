<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';

/**
 * Ambil data laporan dari Supabase
 */
function dlh_reports(array $filters = []): array
{
    
    $result = supabase_fetch(
        'laporan_sampah?select=*,profiles(*)'
    );

    if (!is_array($result)) {
        return [];
    }

    

    $reports = [];

    foreach ($result as $row) {
        $reports[] = [
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
            'latitude' => $row['latitude'] ?? null,
            'longitude' => $row['longitude'] ?? null,

            'nama_pelapor' => $row['profiles']['nama_lengkap']
                ?? $row['profiles']['nama']
                ?? '-',

            'email' => $row['profiles']['email'] ?? '-',

            'no_telp' => $row['profiles']['no_telp']
                ?? $row['profiles']['nomor_hp']
                ?? '-',
        ];
    }

    // Filter status
if (!empty($filters['status'])) {
    $reports = array_filter($reports, function ($report) use ($filters) {
        return strtolower($report['status_laporan'])
            === strtolower($filters['status']);
    });
}

// Filter pencarian
if (!empty($filters['q'])) {
    $q = strtolower(trim($filters['q']));

    $reports = array_filter($reports, function ($report) use ($q) {
        return str_contains(strtolower($report['jalan'] ?? ''), $q)
            || str_contains(strtolower($report['kecamatan'] ?? ''), $q)
            || str_contains(strtolower($report['nama_pelapor'] ?? ''), $q)
            || str_contains((string)($report['id_laporan'] ?? ''), $q);
    });
}

// Filter tingkat keparahan
if (!empty($filters['severity'])) {
    $reports = array_filter($reports, function ($report) use ($filters) {
        return strtolower($report['tingkat_keparahan'])
            === strtolower($filters['severity']);
    });
}

// Filter kecamatan
if (!empty($filters['kecamatan'])) {
    $reports = array_filter($reports, function ($report) use ($filters) {
        return strtolower($report['kecamatan'])
            === strtolower($filters['kecamatan']);
    });
}

$reports = array_values($reports);

    return $reports;
}
/**
 * Ambil laporan berdasarkan ID
 */
function dlh_report_by_id(int $idLaporan): ?array
{
    $reports = dlh_reports(['id' => $idLaporan]);
    return $reports[0] ?? null;
}

/**
 * Hitung jumlah laporan berdasarkan status
 */
function dlh_status_count(array $reports, string $status): int
{
    return count(array_filter($reports, function ($item) use ($status) {
        return ($item['status_laporan'] ?? '') === $status;
    }));
}

/**
 * Hitung jumlah laporan berdasarkan tingkat keparahan
 */
function dlh_severity_count(array $reports, string $severity): int
{
    return count(array_filter($reports, fn (array $item): bool => ($item['tingkat_keparahan'] ?? '') === $severity));
}

/**
 * Ambil laporan aktif (menunggu/diproses) yang memiliki koordinat
 */
function dlh_active_reports(array $reports): array
{
    return array_values(array_filter($reports, function (array $item): bool {
        $status = $item['status_laporan'] ?? '';
        $lat = $item['latitude'] ?? null;
        $lng = $item['longitude'] ?? null;

        return in_array(
            $status,
            ['menunggu', 'diproses', 'pending', 'processing'],
            true
        )
        && is_numeric($lat)
        && is_numeric($lng);
    }));
}

/**
 * Ambil daftar kecamatan unik dari laporan
 */
function dlh_unique_kecamatan(): array
{
    $result = supabase_fetch('laporan_sampah?select=kecamatan');
    $kecamatan = [];
    foreach ($result as $row) {
        if (!empty($row['kecamatan']) && !in_array($row['kecamatan'], $kecamatan)) {
            $kecamatan[] = $row['kecamatan'];
        }
    }
    sort($kecamatan);
    return array_values(array_filter($kecamatan, fn (string $item): bool => $item !== ''));
}

/**
 * Update status laporan
 */
function dlh_update_status(int $id, string $status, ?string $alasan = null, ?int $poin = null): bool
{
    $data = [
        'status_laporan' => $status
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