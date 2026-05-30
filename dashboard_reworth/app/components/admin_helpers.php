<?php

declare(strict_types=1);

require_once __DIR__ . '/../data/mock_data.php';
require_once __DIR__ . '/dlh_helpers.php';

function admin_paginate(array $rows, int $page, int $perPage = 10): array
{
    $page = max(1, $page);
    $perPage = max(1, $perPage);
    $total = count($rows);
    $totalPages = max(1, (int) ceil($total / $perPage));
    $slice = array_slice($rows, ($page - 1) * $perPage, $perPage);

    return [
        'items' => $slice,
        'page' => min($page, $totalPages),
        'per_page' => $perPage,
        'total' => $total,
        'total_pages' => $totalPages,
    ];
}

function admin_users(array $filters = []): array
{
    $rows = mock_admin_users();
    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $role = trim((string) ($filters['role'] ?? ''));
    $status = trim((string) ($filters['status'] ?? ''));

    return array_values(array_filter($rows, function (array $row) use ($q, $role, $status): bool {
        if ($role !== '' && ($row['role'] ?? '') !== $role) {
            return false;
        }
        if ($status !== '' && ($row['status'] ?? '') !== $status) {
            return false;
        }
        if ($q === '') {
            return true;
        }
        $haystack = strtolower(implode(' ', [
            (string) ($row['id_user'] ?? ''),
            (string) ($row['nama'] ?? ''),
            (string) ($row['email'] ?? ''),
        ]));
        return str_contains($haystack, $q);
    }));
}

function admin_user_by_id(string $id): ?array
{
    foreach (mock_admin_users() as $row) {
        if (($row['id_user'] ?? '') === $id) {
            return $row;
        }
    }
    return null;
}

function admin_sellers(array $filters = []): array
{
    $rows = mock_admin_sellers();
    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $statusVerification = trim((string) ($filters['status_verifikasi'] ?? ''));
    $statusToko = trim((string) ($filters['status_toko'] ?? ''));

    return array_values(array_filter($rows, function (array $row) use ($q, $statusVerification, $statusToko): bool {
        if ($statusVerification !== '' && ($row['status_verifikasi'] ?? '') !== $statusVerification) {
            return false;
        }
        if ($statusToko !== '' && ($row['status_toko'] ?? '') !== $statusToko) {
            return false;
        }
        if ($q === '') {
            return true;
        }
        $haystack = strtolower(implode(' ', [
            (string) ($row['id_seller'] ?? ''),
            (string) ($row['nama_toko'] ?? ''),
            (string) ($row['pemilik'] ?? ''),
            (string) ($row['email'] ?? ''),
        ]));
        return str_contains($haystack, $q);
    }));
}

function admin_seller_by_id(string $id): ?array
{
    foreach (mock_admin_sellers() as $row) {
        if (($row['id_seller'] ?? '') === $id) {
            return $row;
        }
    }
    return null;
}

function admin_products(array $filters = []): array
{
    $rows = mock_admin_products();
    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $status = trim((string) ($filters['status_produk'] ?? ''));
    $kategori = trim((string) ($filters['kategori'] ?? ''));
    $seller = trim((string) ($filters['seller'] ?? ''));

    return array_values(array_filter($rows, function (array $row) use ($q, $status, $kategori, $seller): bool {
        if ($status !== '' && ($row['status_produk'] ?? '') !== $status) {
            return false;
        }
        if ($kategori !== '' && ($row['kategori'] ?? '') !== $kategori) {
            return false;
        }
        if ($seller !== '' && ($row['seller'] ?? '') !== $seller) {
            return false;
        }
        if ($q === '') {
            return true;
        }
        $haystack = strtolower(implode(' ', [
            (string) ($row['id_produk'] ?? ''),
            (string) ($row['nama_produk'] ?? ''),
            (string) ($row['seller'] ?? ''),
        ]));
        return str_contains($haystack, $q);
    }));
}

function admin_product_by_id(string $id): ?array
{
    foreach (mock_admin_products() as $row) {
        if (($row['id_produk'] ?? '') === $id) {
            return $row;
        }
    }
    return null;
}

function admin_transactions(array $filters = []): array
{
    $rows = mock_admin_transactions();
    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $status = trim((string) ($filters['status'] ?? ''));
    $dateFrom = trim((string) ($filters['date_from'] ?? ''));
    $dateTo = trim((string) ($filters['date_to'] ?? ''));

    return array_values(array_filter($rows, function (array $row) use ($q, $status, $dateFrom, $dateTo): bool {
        if ($status !== '' && ($row['status'] ?? '') !== $status) {
            return false;
        }
        if ($dateFrom !== '' && (string) ($row['tanggal'] ?? '') < $dateFrom) {
            return false;
        }
        if ($dateTo !== '' && (string) ($row['tanggal'] ?? '') > $dateTo) {
            return false;
        }
        if ($q === '') {
            return true;
        }
        $haystack = strtolower(implode(' ', [
            (string) ($row['id_transaksi'] ?? ''),
            (string) ($row['pembeli'] ?? ''),
            (string) ($row['seller'] ?? ''),
        ]));
        return str_contains($haystack, $q);
    }));
}

function admin_transaction_by_id(string $id): ?array
{
    foreach (mock_admin_transactions() as $row) {
        if (($row['id_transaksi'] ?? '') === $id) {
            return $row;
        }
    }
    return null;
}

function admin_activities(array $filters = []): array
{
    $rows = mock_admin_system_activities();
    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $role = trim((string) ($filters['role'] ?? ''));
    $type = trim((string) ($filters['type'] ?? ''));
    $dateFrom = trim((string) ($filters['date_from'] ?? ''));
    $dateTo = trim((string) ($filters['date_to'] ?? ''));

    return array_values(array_filter($rows, function (array $row) use ($q, $role, $type, $dateFrom, $dateTo): bool {
        if ($role !== '' && ($row['role'] ?? '') !== $role) {
            return false;
        }
        if ($type !== '' && strcasecmp((string) ($row['aktivitas'] ?? ''), $type) !== 0) {
            return false;
        }
        $date = substr((string) ($row['waktu'] ?? ''), 0, 10);
        if ($dateFrom !== '' && $date < $dateFrom) {
            return false;
        }
        if ($dateTo !== '' && $date > $dateTo) {
            return false;
        }
        if ($q === '') {
            return true;
        }
        $haystack = strtolower(implode(' ', [
            (string) ($row['aktor'] ?? ''),
            (string) ($row['aktivitas'] ?? ''),
            (string) ($row['modul'] ?? ''),
            (string) ($row['detail'] ?? ''),
        ]));
        return str_contains($haystack, $q);
    }));
}

function admin_unique_values(array $rows, string $field): array
{
    $values = array_values(array_unique(array_map(fn (array $row): string => (string) ($row[$field] ?? ''), $rows)));
    $values = array_values(array_filter($values, fn (string $value): bool => $value !== ''));
    sort($values);
    return $values;
}

