param(
    [Parameter(Mandatory = $true)]
    [string]$SecretKey,

    [string]$SupabaseUrl = "https://odtbyyhqyprczbfevflf.supabase.co"
)

$configDirectory = Join-Path $PSScriptRoot "..\app\config"
$configPath = Join-Path $configDirectory "supabase.local.php"

if ([string]::IsNullOrWhiteSpace($SecretKey)) {
    throw "SecretKey wajib diisi."
}

$escapedUrl = $SupabaseUrl.Replace("'", "\'")
$escapedKey = $SecretKey.Replace("'", "\'")

$content = @"
<?php

declare(strict_types=1);

return [
    'url' => '$escapedUrl',
    'service_role_key' => '$escapedKey',
];
"@

$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText(
    [System.IO.Path]::GetFullPath($configPath),
    $content,
    $utf8WithoutBom
)
Write-Host "Konfigurasi lokal dibuat: $configPath"
Write-Host "File ini diabaikan Git dan tidak akan ikut ter-push."
