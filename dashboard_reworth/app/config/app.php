<?php
declare(strict_types=1);

define('APP_NAME', 'ReWorth Dashboard');
define('APP_ENV', 'mock');

$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$scriptName = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '');
$dashboardSegment = '/dashboard_reworth';
$segmentPosition = strpos($scriptName, $dashboardSegment);
$basePath = $segmentPosition === false
    ? ''
    : substr($scriptName, 0, $segmentPosition + strlen($dashboardSegment));

define('APP_BASE_URL', rtrim($scheme . '://' . $host . $basePath, '/') . '/');
