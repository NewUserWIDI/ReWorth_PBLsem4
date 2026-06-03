<?php

declare(strict_types=1);

/**
 * Optional local config file:
 * return [
 *   'url' => 'https://your-project.supabase.co',
 *   'service_role_key' => 'your-service-role-key',
 *   'anon_key' => 'your-anon-key',
 * ];
 */
$supabaseLocalConfig = [];
$supabaseLocalConfigPath = __DIR__ . '/supabase.local.php';
if (is_file($supabaseLocalConfigPath)) {
    $loadedConfig = require $supabaseLocalConfigPath;
    if (is_array($loadedConfig)) {
        $supabaseLocalConfig = $loadedConfig;
    }
}
$GLOBALS['supabase_local_config'] = $supabaseLocalConfig;

define(
    'SUPABASE_URL',
    (string) ($supabaseLocalConfig['url'] ?? getenv('SUPABASE_URL') ?? 'https://odtbyyhqyprczbfevflf.supabase.co')
);
define(
    'SUPABASE_API_KEY',
    (string) (
        $supabaseLocalConfig['service_role_key']
        ?? getenv('SUPABASE_SERVICE_ROLE_KEY')
        ?? $supabaseLocalConfig['anon_key']
        ?? getenv('SUPABASE_ANON_KEY')
        ?? 'sb_publishable_4b3SD4MijRDq3SgcojL41A_GFCgMjD_'
    )
);

$GLOBALS['supabase_last_error'] = null;

function supabase_is_configured(): bool
{
    return SUPABASE_URL !== '' && SUPABASE_API_KEY !== '';
}

function supabase_uses_service_role(): bool
{
    return getenv('SUPABASE_SERVICE_ROLE_KEY') !== false
        || (isset($GLOBALS['supabase_local_config']) && is_array($GLOBALS['supabase_local_config']) && !empty($GLOBALS['supabase_local_config']['service_role_key']));
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

function supabase_request(
    string $method,
    string $path,
    array $query = [],
    ?array $payload = null,
    array $headers = []
): array {
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
    $result = supabase_request('GET', $table, array_merge(['select' => $select], $query));
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

function supabase_storage_public_url(string $bucket, string $path): string
{
    $encodedPath = str_replace('%2F', '/', rawurlencode(ltrim($path, '/')));
    return rtrim(SUPABASE_URL, '/') . '/storage/v1/object/public/' . rawurlencode($bucket) . '/' . $encodedPath;
}

function supabase_storage_upload(string $bucket, string $path, string $binary, string $contentType = 'application/octet-stream'): bool
{
    supabase_set_last_error(null);

    $encodedPath = str_replace('%2F', '/', rawurlencode(ltrim($path, '/')));
    $url = rtrim(SUPABASE_URL, '/') . '/storage/v1/object/' . rawurlencode($bucket) . '/' . $encodedPath;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
    curl_setopt($ch, CURLOPT_POSTFIELDS, $binary);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'apikey: ' . SUPABASE_API_KEY,
        'Authorization: Bearer ' . SUPABASE_API_KEY,
        'Content-Type: ' . $contentType,
        'x-upsert: true',
    ]);

    $raw = curl_exec($ch);
    $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($raw === false || $curlError !== '') {
        supabase_set_last_error('Storage upload error: ' . $curlError);
        return false;
    }

    if ($httpCode < 200 || $httpCode >= 300) {
        $decoded = json_decode($raw, true);
        $message = is_array($decoded) && isset($decoded['message'])
            ? (string) $decoded['message']
            : 'Storage upload gagal HTTP ' . $httpCode;
        supabase_set_last_error($message);
        return false;
    }

    return true;
}

function supabase_storage_delete(string $bucket, string $path): bool
{
    supabase_set_last_error(null);

    $encodedPath = str_replace('%2F', '/', rawurlencode(ltrim($path, '/')));
    $url = rtrim(SUPABASE_URL, '/') . '/storage/v1/object/' . rawurlencode($bucket) . '/' . $encodedPath;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'apikey: ' . SUPABASE_API_KEY,
        'Authorization: Bearer ' . SUPABASE_API_KEY,
    ]);

    $raw = curl_exec($ch);
    $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($raw === false || $curlError !== '') {
        supabase_set_last_error('Storage delete error: ' . $curlError);
        return false;
    }

    if ($httpCode < 200 || $httpCode >= 300) {
        $decoded = json_decode($raw, true);
        $message = is_array($decoded) && isset($decoded['message'])
            ? (string) $decoded['message']
            : 'Storage delete gagal HTTP ' . $httpCode;
        supabase_set_last_error($message);
        return false;
    }

    return true;
}
