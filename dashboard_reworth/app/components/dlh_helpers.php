<?php

declare(strict_types=1);

require_once __DIR__ . '/../data/mock_data.php';

function dlh_reports(array $filters = []): array
{
    $reports = mock_dlh_reports();

    $status = trim((string) ($filters['status'] ?? ''));
    $severity = trim((string) ($filters['severity'] ?? ''));
    $kecamatan = trim((string) ($filters['kecamatan'] ?? ''));
    $query = strtolower(trim((string) ($filters['q'] ?? '')));
    $dateFrom = trim((string) ($filters['date_from'] ?? ''));
    $dateTo = trim((string) ($filters['date_to'] ?? ''));

    $filtered = array_values(array_filter($reports, function (array $report) use ($status, $severity, $kecamatan, $query, $dateFrom, $dateTo): bool {
        if ($status !== '' && ($report['status_laporan'] ?? '') !== $status) {
            return false;
        }

        if ($severity !== '' && ($report['tingkat_keparahan'] ?? '') !== $severity) {
            return false;
        }

        if ($kecamatan !== '' && strcasecmp((string) ($report['kecamatan'] ?? ''), $kecamatan) !== 0) {
            return false;
        }

        if ($query !== '') {
            $haystack = strtolower(implode(' ', [
                (string) ($report['id_laporan'] ?? ''),
                (string) ($report['pelapor'] ?? ''),
                (string) ($report['jalan'] ?? ''),
                (string) ($report['kelurahan'] ?? ''),
                (string) ($report['kecamatan'] ?? ''),
                (string) ($report['jenis_sampah'] ?? ''),
            ]));
            if (!str_contains($haystack, $query)) {
                return false;
            }
        }

        $waktuLapor = substr((string) ($report['waktu_lapor'] ?? ''), 0, 10);
        if ($dateFrom !== '' && $waktuLapor < $dateFrom) {
            return false;
        }

        if ($dateTo !== '' && $waktuLapor > $dateTo) {
            return false;
        }

        return true;
    }));

    usort($filtered, function (array $a, array $b): int {
        return strcmp((string) ($b['waktu_lapor'] ?? ''), (string) ($a['waktu_lapor'] ?? ''));
    });

    return $filtered;
}

function dlh_report_by_id(int $idLaporan): ?array
{
    foreach (mock_dlh_reports() as $report) {
        if ((int) ($report['id_laporan'] ?? 0) === $idLaporan) {
            return $report;
        }
    }

    return null;
}

function dlh_status_count(array $reports, string $status): int
{
    return count(array_filter($reports, fn (array $item): bool => ($item['status_laporan'] ?? '') === $status));
}

function dlh_severity_count(array $reports, string $severity): int
{
    return count(array_filter($reports, fn (array $item): bool => ($item['tingkat_keparahan'] ?? '') === $severity));
}

function dlh_active_reports(array $reports): array
{
    return array_values(array_filter($reports, function (array $item): bool {
        $status = $item['status_laporan'] ?? '';
        $lat = $item['latitude'] ?? null;
        $lng = $item['longitude'] ?? null;
        return in_array($status, ['menunggu', 'diproses'], true) && is_numeric($lat) && is_numeric($lng);
    }));
}

function dlh_unique_kecamatan(): array
{
    $kecamatan = array_values(array_unique(array_map(fn (array $item): string => (string) ($item['kecamatan'] ?? ''), mock_dlh_reports())));
    sort($kecamatan);
    return array_values(array_filter($kecamatan, fn (string $item): bool => $item !== ''));
}

function dlh_illustration_path(): string
{
    $candidates = glob(__DIR__ . '/../../assets/ilust_dlh/*.{png,jpg,jpeg,webp,svg}', GLOB_BRACE) ?: [];
    if ($candidates !== []) {
        $first = basename($candidates[0]);
        return 'assets/ilust_dlh/' . $first;
    }

    return 'assets/ilustrasi.png';
}

