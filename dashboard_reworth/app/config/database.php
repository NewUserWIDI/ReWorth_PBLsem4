<?php

declare(strict_types=1);

require_once __DIR__ . '/supabase.php';

/**
 * Mendapatkan koneksi Supabase yang sudah dikonfigurasi
 */
function db_connection(): ?object
{
    return null; // Supabase menggunakan REST API, bukan koneksi PDO
}

/**
 * Cek apakah Supabase terkonfigurasi dengan benar
 */
function is_database_connected(): bool
{
    return supabase_is_configured();
}

/**
 * Mendapatkan error terakhir dari database
 */
function db_last_error(): ?string
{
    return supabase_last_error();
}