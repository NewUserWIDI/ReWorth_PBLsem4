<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';
require_once __DIR__ . '/../data/mock_data.php';

function admin_market_products(array $filters = []): array
{
    $products = supabase_market_products();
    if ($products === null) {
        return admin_market_filter_rows(mock_admin_products(), $filters);
    }

    return admin_market_filter_rows($products, $filters);
}

function admin_market_product_by_id(string $id): ?array
{
    $products = supabase_market_products();
    $rows = $products ?? mock_admin_products();

    foreach ($rows as $row) {
        if ((string) ($row['id_produk'] ?? '') === $id) {
            return $row;
        }
    }

    return null;
}

function admin_market_unique_values(array $rows, string $field): array
{
    $values = array_values(array_unique(array_map(
        static fn (array $row): string => trim((string) ($row[$field] ?? '')),
        $rows
    )));
    $values = array_values(array_filter($values, static fn (string $value): bool => $value !== ''));
    sort($values);
    return $values;
}

function admin_market_data_source_label(): string
{
    return supabase_market_products() !== null ? 'Supabase' : 'Mock Data';
}

function supabase_market_products(): ?array
{
    static $cache = null;
    static $loaded = false;

    if ($loaded) {
        return $cache;
    }

    $loaded = true;

    $productRows = supabase_fetch('produk', '*', ['order' => 'id_produk.asc']);
    if ($productRows === [] && supabase_last_error() !== null) {
        $cache = null;
        return $cache;
    }

    $imageRows = supabase_fetch('gambar_produk', '*');
    if ($imageRows === [] && supabase_last_error() !== null) {
        $imageRows = [];
    }

    $categoryRows = supabase_fetch('kategori_produk', '*');
    if ($categoryRows === [] && supabase_last_error() !== null) {
        $categoryRows = [];
    }

    $sellerRows = supabase_fetch('profiles', 'id,nama_lengkap,nama');
    if ($sellerRows === [] && supabase_last_error() !== null) {
        $sellerRows = [];
    }

    $primaryImages = [];
    foreach ($imageRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $productId = supabase_market_to_int($row['id_produk'] ?? null);
        $url = trim((string) ($row['public_url'] ?? ''));
        if ($productId === null || $url === '') {
            continue;
        }

        $isPrimary = ($row['is_primary'] ?? false) === true;
        if (!isset($primaryImages[$productId]) || $isPrimary) {
            $primaryImages[$productId] = $url;
        }
    }

    $categoryMap = [];
    foreach ($categoryRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $categoryId = supabase_market_to_int($row['id_kategori'] ?? $row['kategori_id'] ?? null);
        $name = trim((string) ($row['nama_kategori'] ?? ''));
        if ($categoryId !== null && $name !== '') {
            $categoryMap[$categoryId] = $name;
        }
    }

    $sellerMap = [];
    foreach ($sellerRows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $id = trim((string) ($row['id'] ?? ''));
        $name = trim((string) ($row['nama_lengkap'] ?? $row['nama'] ?? ''));
        if ($id !== '' && $name !== '') {
            $sellerMap[$id] = $name;
        }
    }

    $cache = array_map(static function (array $row) use ($primaryImages, $categoryMap, $sellerMap): array {
        $productId = (string) ($row['id_produk'] ?? '');
        $numericProductId = supabase_market_to_int($row['id_produk'] ?? null);
        $sellerId = trim((string) ($row['id_seller'] ?? ''));
        $categoryId = supabase_market_to_int(
            $row['id_kategori'] ?? $row['kategori_id'] ?? $row['id_category'] ?? null
        );

        $name = supabase_market_first_string($row, ['nama_produk', 'nama']) ?? 'Produk';
        $status = strtolower(supabase_market_first_string($row, ['status_produk', 'status']) ?? 'aktif');
        $createdAt = supabase_market_first_string($row, ['created_at', 'tanggal_dibuat']) ?? '-';
        $description = supabase_market_first_string($row, ['deskripsi', 'deskripsi_produk', 'description']) ?? '-';

        return [
            'id_produk' => $productId,
            'foto' => $numericProductId !== null ? ($primaryImages[$numericProductId] ?? '') : '',
            'nama_produk' => $name,
            'seller' => $sellerMap[$sellerId] ?? 'Seller ReWorth',
            'kategori' => $categoryId !== null ? ($categoryMap[$categoryId] ?? 'Tanpa Kategori') : 'Tanpa Kategori',
            'harga' => (int) round(supabase_market_to_float($row['harga'] ?? $row['harga_produk'] ?? 0) ?? 0),
            'stok' => supabase_market_to_int($row['stok'] ?? $row['stock'] ?? 0) ?? 0,
            'status_produk' => $status,
            'tanggal_dibuat' => $createdAt,
            'deskripsi' => $description,
        ];
    }, array_values(array_filter($productRows, 'is_array')));

    return $cache;
}

function admin_market_filter_rows(array $rows, array $filters): array
{
    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $kategori = trim((string) ($filters['kategori'] ?? ''));
    $seller = trim((string) ($filters['seller'] ?? ''));
    $status = trim((string) ($filters['status_produk'] ?? ''));

    return array_values(array_filter($rows, static function (array $row) use ($q, $kategori, $seller, $status): bool {
        if ($kategori !== '' && (string) ($row['kategori'] ?? '') !== $kategori) {
            return false;
        }
        if ($seller !== '' && (string) ($row['seller'] ?? '') !== $seller) {
            return false;
        }
        if ($status !== '' && strtolower((string) ($row['status_produk'] ?? '')) !== strtolower($status)) {
            return false;
        }
        if ($q === '') {
            return true;
        }

        $haystack = strtolower(implode(' ', [
            (string) ($row['id_produk'] ?? ''),
            (string) ($row['nama_produk'] ?? ''),
            (string) ($row['seller'] ?? ''),
            (string) ($row['kategori'] ?? ''),
        ]));

        return str_contains($haystack, $q);
    }));
}

function supabase_market_first_string(array $row, array $keys): ?string
{
    foreach ($keys as $key) {
        $value = $row[$key] ?? null;
        if ($value === null) {
            continue;
        }

        $text = trim((string) $value);
        if ($text !== '') {
            return $text;
        }
    }

    return null;
}

function supabase_market_to_int(mixed $value): ?int
{
    if ($value === null || $value === '') {
        return null;
    }
    if (is_int($value)) {
        return $value;
    }
    if (is_numeric($value)) {
        return (int) $value;
    }
    return null;
}

function supabase_market_to_float(mixed $value): ?float
{
    if ($value === null || $value === '') {
        return null;
    }
    if (is_float($value)) {
        return $value;
    }
    if (is_int($value) || is_numeric($value)) {
        return (float) $value;
    }
    return null;
}
