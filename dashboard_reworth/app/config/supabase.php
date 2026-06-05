<?php

declare(strict_types=1);

// ========== KONFIGURASI SUPABASE ==========
define('SUPABASE_URL', 'https://odtbyyhqyprczbfevflf.supabase.co');
define('SUPABASE_API_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kdGJ5eWhxeXByY3piZmV2ZmxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNTU4MjksImV4cCI6MjA5MzczMTgyOX0.Yx84RnYTa8h-RLYkxKO2wWY60ZcDSTYYO_vqB7Bqv14');

$GLOBALS['supabase_last_error'] = null;

function supabase_is_configured(): bool
{
    return SUPABASE_URL !== '' && SUPABASE_API_KEY !== '';
}

function supabase_set_last_error(?string $message): void
{
    $GLOBALS['supabase_last_error'] = $message;
}

function supabase_last_error(): ?string
{
    $value = $GLOBALS['supabase_last_error'] ?? null;
    return is_string($value) && $value !== '' ? $value : null;
}

function supabase_request(string $method, string $path, array $query = [], ?array $payload = null, array $headers = []): array
{
    supabase_set_last_error(null);

    if (!supabase_is_configured()) {
        supabase_set_last_error('Konfigurasi Supabase belum lengkap.');
        return ['status' => 0, 'data' => null, 'headers' => []];
    }

    $url = rtrim(SUPABASE_URL, '/') . '/rest/v1/' . ltrim($path, '/');
    if ($query !== []) {
        $url .= '?' . http_build_query($query, '', '&', PHP_QUERY_RFC3986);
    }

    $responseHeaders = [];
    $curlHeaders = array_merge([
        'apikey: ' . SUPABASE_API_KEY,
        'Authorization: Bearer ' . SUPABASE_API_KEY,
        'Content-Type: application/json',
        'Accept: application/json',
    ], $headers);

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, strtoupper($method));
    curl_setopt($ch, CURLOPT_HTTPHEADER, $curlHeaders);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    curl_setopt($ch, CURLOPT_HEADERFUNCTION, static function ($curl, string $line) use (&$responseHeaders): int {
        $trimmed = trim($line);
        if ($trimmed === '' || !str_contains($trimmed, ':')) {
            return strlen($line);
        }

        [$name, $value] = explode(':', $trimmed, 2);
        $responseHeaders[strtolower(trim($name))] = trim($value);
        return strlen($line);
    });

    if ($payload !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    }

    $raw = curl_exec($ch);
    $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($raw === false || $curlError !== '') {
        supabase_set_last_error('cURL error: ' . $curlError);
        return ['status' => 0, 'data' => null, 'headers' => $responseHeaders];
    }

    $decoded = json_decode($raw, true);
    if ($httpCode < 200 || $httpCode >= 300) {
        if (is_array($decoded) && isset($decoded['message'])) {
            supabase_set_last_error('Supabase error: ' . (string) $decoded['message']);
        } else {
            supabase_set_last_error('Supabase error HTTP ' . $httpCode);
        }
        return ['status' => $httpCode, 'data' => $decoded, 'headers' => $responseHeaders];
    }

    return [
        'status' => $httpCode,
        'data' => $decoded,
        'headers' => $responseHeaders,
    ];
}

function supabase_fetch(string $table, string $select = '*', array $query = []): array
{
    if (strpos($table, '?') !== false) {
        $result = supabase_request('GET', $table, [], null);
    } else {
        $result = supabase_request(
            'GET',
            $table,
            array_merge(['select' => $select], $query),
            null
        );
    }

    $data = $result['data'] ?? [];

    return is_array($data) ? $data : [];
}

function supabase_fetch_one(string $table, string $select = '*', array $query = []): ?array
{
    $rows = supabase_fetch($table, $select, array_merge($query, ['limit' => '1']));
    if ($rows === []) {
        return null;
    }

    $first = $rows[0] ?? null;
    return is_array($first) ? $first : null;
}

function supabase_insert(string $table, array $payload): array
{
    $result = supabase_request('POST', $table, [], $payload, ['Prefer: return=representation']);
    $data = $result['data'] ?? [];
    return is_array($data) ? $data : [];
}

function supabase_update(string $table, array $payload, array $query): array
{
    $result = supabase_request('PATCH', $table, $query, $payload, ['Prefer: return=representation']);
    $data = $result['data'] ?? [];
    return is_array($data) ? $data : [];
}

function supabase_delete(string $table, array $query): bool
{
    $result = supabase_request('DELETE', $table, $query, null, ['Prefer: return=representation']);
    $status = (int) ($result['status'] ?? 0);
    return $status >= 200 && $status < 300;
}

function supabase_count(string $table, string $idColumn = 'id'): int
{
    $result = supabase_request(
        'GET',
        $table,
        ['select' => $idColumn, 'limit' => '1'],
        null,
        ['Prefer: count=exact']
    );

    $contentRange = $result['headers']['content-range'] ?? '';
    if (preg_match('~/(\d+)$~', $contentRange, $matches) === 1) {
        return (int) $matches[1];
    }

    $rows = $result['data'] ?? [];
    return is_array($rows) ? count($rows) : 0;
}