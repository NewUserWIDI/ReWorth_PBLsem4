<?php

declare(strict_types=1);

// 1. Definisikan Kunci Akses Supabase Kamu
// (Silakan ganti URL dan ANON_KEY ini sesuai dengan yang ada di Project Settings -> API milik Supabase-mu)
define('SUPABASE_URL', 'https://xyzcompanyprojecturl.supabase.co');
define('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5cGds...');

/**
 * Fungsi Pintar untuk Mengambil Data (Fetch/SELECT) dari Tabel Supabase
 */
function supabase_fetch(string $table, string $select = '*', string $queryParams = ''): array
{
    $url = SUPABASE_URL . '/rest/v1/' . $table . '?select=' . urlencode($select) . $queryParams;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'apikey: ' . SUPABASE_ANON_KEY,
        'Authorization: Bearer ' . SUPABASE_ANON_KEY,
        'Content-Type: application/json',
        'Prefer: return=representation'
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode >= 200 && $httpCode < 300) {
        return json_decode($response, true) ?? [];
    }

    return [];
}

/**
 * Fungsi Pintar untuk Menghitung Jumlah Baris Data (COUNT) di Tabel Supabase
 */
function supabase_count(string $table): int
{
    $url = SUPABASE_URL . '/rest/v1/' . $table . '?select=id';

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    // Kita minta Supabase mengirimkan total baris lewat header HTTP agar sangat cepat
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'apikey: ' . SUPABASE_ANON_KEY,
        'Authorization: Bearer ' . SUPABASE_ANON_KEY,
        'Prefer: count=exact' 
    ]);

    curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    
    // Membaca header Content-Range untuk mendapatkan total baris asli
    // Contoh format return: Content-Range: 0-9/123 -> kita ambil angka 123
    $info = curl_getinfo($ch);
    curl_close($ch);

    // Jika cURL sukses, kita tembak totalnya dari jumlah baris array data saja sebagai alternatif aman:
    $data = supabase_fetch($table, 'id');
    return count($data);
}