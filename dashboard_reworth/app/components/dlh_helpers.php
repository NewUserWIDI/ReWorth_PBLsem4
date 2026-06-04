<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';

/**
 * Ambil data laporan dari Supabase
 */
function dlh_reports(array $filters = []): array
{
    // Query dasar
    $query = 'laporan_sampah?select=*,profiles(nama_lengkap,nama,no_telp,email)&order=waktu_lapor.desc';
    
    $conditions = [];
    
    // Filter by ID
    if (!empty($filters['id'])) {
        $conditions[] = 'id_laporan=eq.' . intval($filters['id']);
    }
    
    // Filter search query
    if (!empty($filters['q'])) {
        $search = addslashes($filters['q']);
        $conditions[] = 'or=(jalan.ilike.%' . $search . '%,kelurahan.ilike.%' . $search . '%,kecamatan.ilike.%' . $search . '%)';
    }
    
    // Filter status
    if (!empty($filters['status'])) {
        $conditions[] = 'status_laporan=eq.' . $filters['status'];
    }
    
    // Filter severity
    if (!empty($filters['severity'])) {
        $conditions[] = 'tingkat_keparahan=eq.' . $filters['severity'];
    }
    
    // Filter kecamatan
    if (!empty($filters['kecamatan'])) {
        $conditions[] = 'kecamatan=eq.' . $filters['kecamatan'];
    }
    
    // Filter date range
    if (!empty($filters['date_from'])) {
        $conditions[] = 'waktu_lapor=gte.' . $filters['date_from'];
    }
    if (!empty($filters['date_to'])) {
        $conditions[] = 'waktu_lapor=lte.' . $filters['date_to'] . ' 23:59:59';
    }
    
    if (!empty($conditions)) {
        $query .= '&' . implode('&', $conditions);
    }
    
    $result = supabase_fetch($query);
    
    // Format data
    $reports = [];
    foreach ($result as $row) {
        $reports[] = [
            'id_laporan' => $row['id_laporan'],
            'foto_sampah' => $row['foto_sampah'],
            'jalan' => $row['jalan'],
            'kelurahan' => $row['kelurahan'],
            'kecamatan' => $row['kecamatan'],
            'patokan' => $row['patokan'],
            'deskripsi' => $row['deskripsi'],
            'jenis_sampah' => $row['jenis_sampah'],
            'tingkat_keparahan' => $row['tingkat_keparahan'],
            'status_laporan' => $row['status_laporan'],
            'alasan_ditolak' => $row['alasan_ditolak'],
            'waktu_lapor' => $row['waktu_lapor'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'nama_pelapor' => $row['profiles']['nama_lengkap'] ?? $row['profiles']['nama'] ?? '-',
            'no_telp' => $row['profiles']['no_telp'] ?? '-',
            'email' => $row['profiles']['email'] ?? '-',
        ];
    }
    
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
    return count(array_filter($reports, fn (array $item): bool => ($item['status_laporan'] ?? '') === $status));
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
        return in_array($status, ['menunggu', 'diproses', 'pending', 'processing'], true) && is_numeric($lat) && is_numeric($lng);
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
    $data = ['status_laporan' => $status];
    if ($alasan !== null) {
        $data['alasan_ditolak'] = $alasan;
    }
    if ($poin !== null) {
        $data['poin_diberikan'] = $poin;
    }
    
    $result = supabaseRequest('laporan_sampah?id_laporan=eq.' . $id, 'PATCH', $data);
    return $result['ok'] ?? false;
}

/**
 * Path ilustrasi DLH
 */
function dlh_illustration_path(): string
{
    $singleCandidates = ['assets/ilust_dlh.png', 'assets/ilust_dlh.jpg', 'assets/ilust_dlh.jpeg', 'assets/ilust_dlh.webp'];
    foreach ($singleCandidates as $path) {
        if (is_file(__DIR__ . '/../../' . $path)) {
            return $path;
        }
    }

    $folderCandidates = glob(__DIR__ . '/../../assets/ilust_dlh/*.{png,jpg,jpeg,webp,svg}', GLOB_BRACE) ?: [];
    if ($folderCandidates !== []) {
        $first = basename($folderCandidates[0]);
        return 'assets/ilust_dlh/' . $first;
    }

    return 'assets/ilust_dlh.png';
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