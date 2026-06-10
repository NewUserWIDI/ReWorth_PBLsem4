<?php

declare(strict_types=1);

require_once __DIR__ . '/../config/supabase.php';
require_once __DIR__ . '/admin_helpers.php';

const ADMIN_UPLOAD_BUCKET = 'product-images';

function admin_now_iso(): string
{
    return gmdate('c');
}

function admin_in_filter(array $values): ?string
{
    $formatted = [];
    foreach ($values as $value) {
        if ($value === null || $value === '') {
            continue;
        }

        if (is_int($value) || is_float($value) || ctype_digit((string) $value)) {
            $formatted[] = (string) $value;
            continue;
        }

        $escaped = str_replace('"', '\"', (string) $value);
        $formatted[] = '"' . $escaped . '"';
    }

    if ($formatted === []) {
        return null;
    }

    return 'in.(' . implode(',', $formatted) . ')';
}

function admin_detect_mime_type(string $tmpPath): string
{
    if (function_exists('finfo_open')) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        if ($finfo !== false) {
            $mime = finfo_file($finfo, $tmpPath) ?: 'application/octet-stream';
            finfo_close($finfo);
            return (string) $mime;
        }
    }

    if (function_exists('mime_content_type')) {
        $mime = mime_content_type($tmpPath);
        if (is_string($mime) && $mime !== '') {
            return $mime;
        }
    }

    return 'application/octet-stream';
}

function admin_normalize_uploaded_file(mixed $file): ?array
{
    if (!is_array($file) || !isset($file['name'])) {
        return null;
    }

    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
        return null;
    }

    return $file;
}

function admin_upload_image(mixed $file, string $folder): array
{
    $upload = admin_normalize_uploaded_file($file);
    if ($upload === null) {
        return ['success' => false, 'message' => 'Tidak ada file yang diunggah.'];
    }

    $tmpPath = (string) ($upload['tmp_name'] ?? '');
    if ($tmpPath === '' || !is_file($tmpPath)) {
        return ['success' => false, 'message' => 'File upload tidak valid.'];
    }

    $mime = admin_detect_mime_type($tmpPath);
    if (!str_starts_with($mime, 'image/')) {
        return ['success' => false, 'message' => 'File harus berupa gambar.'];
    }

    $size = (int) ($upload['size'] ?? 0);
    if ($size > 2 * 1024 * 1024) {
        return ['success' => false, 'message' => 'Ukuran gambar maksimal 2MB.'];
    }

    $originalName = (string) ($upload['name'] ?? 'image.jpg');
    $safeName = preg_replace('/[^A-Za-z0-9._-]/', '_', $originalName) ?: 'image.jpg';
    $path = trim($folder, '/') . '/' . time() . '_' . bin2hex(random_bytes(4)) . '_' . $safeName;
    $binary = file_get_contents($tmpPath);

    if ($binary === false) {
        return ['success' => false, 'message' => 'Gagal membaca file upload.'];
    }

    if (!supabase_storage_upload(ADMIN_UPLOAD_BUCKET, $path, $binary, $mime)) {
        return ['success' => false, 'message' => supabase_last_error() ?? 'Upload gambar gagal.'];
    }

    return [
        'success' => true,
        'url' => supabase_storage_public_url(ADMIN_UPLOAD_BUCKET, $path),
        'path' => $path,
    ];
}

function admin_fetch_dashboard_user_by_id(string $dashboardUserId): ?array
{
    if ($dashboardUserId === '') {
        return null;
    }

    return supabase_fetch_one('dashboard_users', '*', ['id' => 'eq.' . $dashboardUserId]);
}

function admin_find_dashboard_user_for_profile(array $profile, string $role): ?array
{
    $profileId = trim((string) ($profile['id'] ?? ''));
    if ($profileId !== '') {
        $dashboardUser = supabase_fetch_one('dashboard_users', '*', [
            'profile_id' => 'eq.' . $profileId,
            'limit' => '1',
        ]);
        if (is_array($dashboardUser)) {
            return $dashboardUser;
        }
    }

    $email = trim((string) ($profile['email'] ?? ''));
    if ($email !== '') {
        $dashboardUser = supabase_fetch_one('dashboard_users', '*', [
            'email' => 'eq.' . $email,
            'role' => 'eq.' . $role,
            'limit' => '1',
        ]);
        if (is_array($dashboardUser)) {
            return $dashboardUser;
        }
    }

    return null;
}

function admin_find_profile_for_staff(array $sessionUser, string $role): ?array
{
    $profileId = trim((string) ($sessionUser['profile_id'] ?? ''));
    if ($profileId !== '') {
        $profile = supabase_fetch_one('profiles', '*', ['id' => 'eq.' . $profileId, 'limit' => '1']);
        if (is_array($profile)) {
            return $profile;
        }
    }

    $dashboardUserId = trim((string) ($sessionUser['dashboard_user_id'] ?? ''));
    if ($dashboardUserId !== '') {
        $dashboardUser = admin_fetch_dashboard_user_by_id($dashboardUserId);
        if (is_array($dashboardUser)) {
            $linkedProfileId = trim((string) ($dashboardUser['profile_id'] ?? ''));
            if ($linkedProfileId !== '') {
                $profile = supabase_fetch_one('profiles', '*', ['id' => 'eq.' . $linkedProfileId, 'limit' => '1']);
                if (is_array($profile)) {
                    return $profile;
                }
            }
        }
    }

    $email = trim((string) ($sessionUser['email'] ?? ''));
    if ($email !== '') {
        $profile = supabase_fetch_one('profiles', '*', [
            'email' => 'eq.' . $email,
            'role' => 'eq.' . $role,
            'limit' => '1',
        ]);
        if (is_array($profile)) {
            return $profile;
        }
    }

    return null;
}

function admin_create_staff_profile(array $sessionUser, string $role): ?array
{
    $payload = [
        'nama_lengkap' => trim((string) (($sessionUser['nama_lengkap'] ?? $sessionUser['nama'] ?? '') ?: 'Petugas ReWorth')),
        'email' => trim((string) ($sessionUser['email'] ?? '')),
        'no_telp' => '',
        'role' => $role,
        'status_pengajuan_seller' => null,
        'created_at' => admin_now_iso(),
        'updated_at' => admin_now_iso(),
    ];

    $inserted = supabase_insert('profiles', $payload);
    $profile = is_array($inserted) && isset($inserted[0]) && is_array($inserted[0]) ? $inserted[0] : null;
    if (!is_array($profile)) {
        return null;
    }

    $dashboardUserId = trim((string) ($sessionUser['dashboard_user_id'] ?? ''));
    if ($dashboardUserId !== '') {
        supabase_update('dashboard_users', [
            'profile_id' => (string) ($profile['id'] ?? ''),
            'updated_at' => admin_now_iso(),
        ], ['id' => 'eq.' . $dashboardUserId]);
    }

    return $profile;
}

function admin_refresh_session_user(array $sessionUser, array $profile, ?array $dashboardUser = null): array
{
    $name = trim((string) (($profile['nama_lengkap'] ?? '') ?: ($dashboardUser['nama_lengkap'] ?? '') ?: ($sessionUser['nama_lengkap'] ?? $sessionUser['nama'] ?? '')));
    $email = trim((string) (($profile['email'] ?? '') ?: ($dashboardUser['email'] ?? '') ?: ($sessionUser['email'] ?? '')));

    $sessionUser['nama'] = $name;
    $sessionUser['nama_lengkap'] = $name;
    $sessionUser['email'] = $email;
    $sessionUser['profile_id'] = (string) ($profile['id'] ?? ($sessionUser['profile_id'] ?? ''));

    if (is_array($dashboardUser) && isset($dashboardUser['id'])) {
        $sessionUser['dashboard_user_id'] = (string) $dashboardUser['id'];
    }

    return $sessionUser;
}

function admin_setting_value(string $key, string $default = ''): string
{
    $result = supabase_fetch_one('pengaturan', 'setting_value', ['setting_key' => 'eq.' . $key]);
    return is_array($result) ? (string) ($result['setting_value'] ?? $default) : $default;
}

function admin_upsert_setting(string $key, string $value, string $type = 'text', string $description = '', ?string $updatedBy = null): bool
{
    $payload = [
        'setting_value' => $value,
        'setting_type' => $type,
        'description' => $description,
        'updated_at' => admin_now_iso(),
        'updated_by' => $updatedBy ?? '',
    ];

    $existing = supabase_fetch_one('pengaturan', 'id_setting', ['setting_key' => 'eq.' . $key]);
    if (is_array($existing) && isset($existing['id_setting'])) {
        supabase_update('pengaturan', $payload, ['setting_key' => 'eq.' . $key]);
        return supabase_last_error() === null;
    }

    $inserted = supabase_insert('pengaturan', array_merge($payload, ['setting_key' => $key]));
    return $inserted !== [] || supabase_last_error() === null;
}

function admin_save_admin_profile(array $sessionUser, array $post, array $files): array
{
    $nama = trim((string) ($post['nama_admin'] ?? ''));
    $email = trim((string) ($post['email_admin'] ?? ''));
    $noTelp = trim((string) ($post['no_telp_admin'] ?? ''));

    if ($nama === '' || $email === '') {
        return ['success' => false, 'message' => 'Nama dan email admin wajib diisi.'];
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return ['success' => false, 'message' => 'Format email admin tidak valid.'];
    }

    $dashboardUser = admin_fetch_dashboard_user_by_id(trim((string) ($sessionUser['dashboard_user_id'] ?? '')));
    $profile = admin_find_profile_for_staff($sessionUser, 'admin');
    if ($profile === null) {
        $profile = admin_create_staff_profile($sessionUser, 'admin');
        if ($profile === null) {
            return ['success' => false, 'message' => 'Gagal menyiapkan profil admin.'];
        }
    }

    $profilePayload = [
        'nama_lengkap' => $nama,
        'email' => $email,
        'no_telp' => $noTelp,
        'role' => 'admin',
        'updated_at' => admin_now_iso(),
    ];

    $photoUpload = admin_normalize_uploaded_file($files['foto_admin'] ?? null);
    if ($photoUpload !== null) {
        $uploaded = admin_upload_image($photoUpload, 'admin/profiles');
        if (!$uploaded['success']) {
            return ['success' => false, 'message' => (string) ($uploaded['message'] ?? 'Upload foto admin gagal.')];
        }
        $profilePayload['foto_profil'] = (string) ($uploaded['url'] ?? '');
    }

    supabase_update('profiles', $profilePayload, ['id' => 'eq.' . (string) ($profile['id'] ?? '')]);
    if (supabase_last_error() !== null) {
        return ['success' => false, 'message' => 'Gagal menyimpan profil admin: ' . supabase_last_error()];
    }

    if (is_array($dashboardUser)) {
        supabase_update('dashboard_users', [
            'profile_id' => (string) ($profile['id'] ?? ''),
            'nama_lengkap' => $nama,
            'email' => $email,
            'updated_at' => admin_now_iso(),
        ], ['id' => 'eq.' . (string) ($dashboardUser['id'] ?? '')]);
        $dashboardUser = admin_fetch_dashboard_user_by_id((string) ($dashboardUser['id'] ?? ''));
    }

    $updatedProfile = supabase_fetch_one('profiles', '*', ['id' => 'eq.' . (string) ($profile['id'] ?? '')]);

    return [
        'success' => true,
        'message' => 'Profil admin berhasil diperbarui.',
        'profile' => is_array($updatedProfile) ? $updatedProfile : $profile,
        'dashboard_user' => $dashboardUser,
    ];
}

function admin_save_system_settings(array $sessionUser, array $post, array $files): array
{
    $updatedBy = trim((string) (($sessionUser['dashboard_user_id'] ?? '') ?: ($sessionUser['id'] ?? '')));

    $success = true;
    $success = admin_upsert_setting('app_name', trim((string) ($post['nama_platform'] ?? 'ReWorth')), 'text', 'Nama aplikasi', $updatedBy) && $success;
    $success = admin_upsert_setting('contact_email', trim((string) ($post['email_kontak'] ?? '')), 'email', 'Email kontak', $updatedBy) && $success;
    $success = admin_upsert_setting('contact_phone', trim((string) ($post['telepon'] ?? '')), 'text', 'Nomor telepon kontak', $updatedBy) && $success;
    $success = admin_upsert_setting('app_description', trim((string) ($post['deskripsi'] ?? '')), 'textarea', 'Deskripsi platform', $updatedBy) && $success;

    $logoUpload = admin_normalize_uploaded_file($files['logo_platform'] ?? null);
    if ($logoUpload !== null) {
        $uploaded = admin_upload_image($logoUpload, 'admin/settings');
        if (!$uploaded['success']) {
            return ['success' => false, 'message' => (string) ($uploaded['message'] ?? 'Upload logo gagal.')];
        }

        $success = admin_upsert_setting('app_logo', (string) ($uploaded['url'] ?? ''), 'text', 'Logo aplikasi', $updatedBy) && $success;
    }

    if (!$success) {
        return ['success' => false, 'message' => 'Sebagian pengaturan sistem gagal disimpan.'];
    }

    return ['success' => true, 'message' => 'Pengaturan sistem berhasil disimpan.'];
}

function admin_dlh_list(array $filters = []): array
{
    $rows = supabase_fetch('profiles', '*', [
        'role' => 'eq.dlh',
        'order' => 'created_at.desc',
    ]);

    $items = [];
    foreach ($rows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $dashboardUser = admin_find_dashboard_user_for_profile($row, 'dlh');
        $items[] = [
            'id' => (string) ($row['id'] ?? ''),
            'nama' => (string) (($row['nama_lengkap'] ?? $row['nama'] ?? '-') ?: '-'),
            'email' => (string) ($row['email'] ?? '-'),
            'no_telp' => (string) (($row['no_telp'] ?? $row['nomor_hp'] ?? '-') ?: '-'),
            'username' => is_array($dashboardUser) ? (string) ($dashboardUser['username'] ?? '-') : '-',
            'status_akun' => is_array($dashboardUser) && (($dashboardUser['is_active'] ?? true) === false || ($dashboardUser['is_active'] ?? true) === 0) ? 'nonaktif' : 'aktif',
            'tanggal_bergabung' => format_date($row['created_at'] ?? null),
        ];
    }

    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    if ($q !== '') {
        $items = array_values(array_filter($items, static function (array $item) use ($q): bool {
            return str_contains(strtolower((string) $item['nama']), $q)
                || str_contains(strtolower((string) $item['email']), $q)
                || str_contains(strtolower((string) $item['no_telp']), $q)
                || str_contains(strtolower((string) $item['username']), $q);
        }));
    }

    return $items;
}

function admin_dlh_by_id(string $profileId): ?array
{
    if ($profileId === '') {
        return null;
    }

    $profile = supabase_fetch_one('profiles', '*', [
        'id' => 'eq.' . $profileId,
        'role' => 'eq.dlh',
        'limit' => '1',
    ]);

    if (!is_array($profile)) {
        return null;
    }

    $dashboardUser = admin_find_dashboard_user_for_profile($profile, 'dlh');

    return [
        'id' => (string) ($profile['id'] ?? ''),
        'nama' => (string) (($profile['nama_lengkap'] ?? $profile['nama'] ?? '-') ?: '-'),
        'email' => (string) ($profile['email'] ?? '-'),
        'no_telp' => (string) (($profile['no_telp'] ?? $profile['nomor_hp'] ?? '-') ?: '-'),
        'foto_profil' => (string) ($profile['foto_profil'] ?? ''),
        'tanggal_bergabung' => format_date($profile['created_at'] ?? null),
        'username' => is_array($dashboardUser) ? (string) ($dashboardUser['username'] ?? '') : '',
        'dashboard_user_id' => is_array($dashboardUser) ? (string) ($dashboardUser['id'] ?? '') : '',
        'is_active' => is_array($dashboardUser) ? (bool) ($dashboardUser['is_active'] ?? true) : true,
    ];
}

function admin_validate_dashboard_user_identity(string $username, string $email, ?string $ignoreDashboardId = null): ?string
{
    $username = trim($username);
    $email = trim($email);

    if ($username !== '') {
        $existingUsers = supabase_fetch('dashboard_users', 'id,username', [
            'username' => 'ilike.' . $username,
        ]);
        foreach ($existingUsers as $existingUsername) {
            if (
                is_array($existingUsername)
                && strcasecmp((string) ($existingUsername['username'] ?? ''), $username) === 0
                && (string) ($existingUsername['id'] ?? '') !== (string) $ignoreDashboardId
            ) {
                return 'Username dashboard sudah digunakan.';
            }
        }
    }

    if ($email !== '') {
        $existingUsers = supabase_fetch('dashboard_users', 'id,email', [
            'email' => 'ilike.' . $email,
        ]);
        foreach ($existingUsers as $existingEmail) {
            if (
                is_array($existingEmail)
                && strcasecmp((string) ($existingEmail['email'] ?? ''), $email) === 0
                && (string) ($existingEmail['id'] ?? '') !== (string) $ignoreDashboardId
            ) {
                return 'Email dashboard sudah digunakan.';
            }
        }
    }

    return null;
}

function admin_save_dlh(array $data, ?string $profileId = null): array
{
    $nama = trim((string) ($data['nama_lengkap'] ?? ''));
    $email = trim((string) ($data['email'] ?? ''));
    $noTelp = trim((string) ($data['no_telp'] ?? ''));
    $username = trim((string) ($data['username'] ?? ''));
    $password = trim((string) ($data['password'] ?? ''));
    $passwordConfirmation = trim((string) ($data['password_confirmation'] ?? ''));

    if ($nama === '' || $email === '' || $noTelp === '' || $username === '') {
        return ['success' => false, 'message' => 'Nama, email, nomor telepon, dan username wajib diisi.'];
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return ['success' => false, 'message' => 'Format email tidak valid.'];
    }

    $existingProfiles = supabase_fetch('profiles', 'id,email,role', [
        'email' => 'ilike.' . $email,
    ]);
    foreach ($existingProfiles as $existingProfile) {
        if (
            is_array($existingProfile)
            && strcasecmp((string) ($existingProfile['email'] ?? ''), $email) === 0
            && (string) ($existingProfile['id'] ?? '') !== (string) ($profileId ?? '')
        ) {
            return ['success' => false, 'message' => 'Email profil sudah digunakan oleh akun lain.'];
        }
    }

    $existing = $profileId !== null ? admin_dlh_by_id($profileId) : null;
    $identityError = admin_validate_dashboard_user_identity($username, $email, $existing['dashboard_user_id'] ?? null);
    if ($identityError !== null) {
        return ['success' => false, 'message' => $identityError];
    }

    if ($profileId === null && mb_strlen($password) < 8) {
        return ['success' => false, 'message' => 'Password awal minimal 8 karakter.'];
    }

    if ($profileId === null && $password !== $passwordConfirmation) {
        return ['success' => false, 'message' => 'Konfirmasi password awal tidak cocok.'];
    }

    if ($profileId === null) {
        $authUser = supabase_auth_admin_create_user([
            'email' => $email,
            'password' => $password,
            'email_confirm' => true,
            'user_metadata' => [
                'nama_lengkap' => $nama,
                'no_telp' => $noTelp,
                'role' => 'dlh',
            ],
            'app_metadata' => [
                'role' => 'dlh',
            ],
        ]);

        $authUserId = (string) ($authUser['user']['id'] ?? $authUser['id'] ?? '');
        if ($authUserId === '') {
            return ['success' => false, 'message' => 'Gagal membuat akun Auth DLH: ' . (supabase_last_error() ?? 'unknown error')];
        }

        $profileInsert = supabase_insert('profiles', [
            'id' => $authUserId,
            'nama_lengkap' => $nama,
            'email' => $email,
            'no_telp' => $noTelp,
            'role' => 'dlh',
            'status_pengajuan_seller' => null,
            'total_poin' => 0,
            'total_laporan_valid' => 0,
            'created_at' => admin_now_iso(),
            'updated_at' => admin_now_iso(),
        ]);

        $profile = is_array($profileInsert) && isset($profileInsert[0]) && is_array($profileInsert[0]) ? $profileInsert[0] : null;
        if (!is_array($profile) || !isset($profile['id'])) {
            $message = supabase_last_error() ?? 'unknown error';
            if (str_contains(strtolower($message), 'duplicate')) {
                $message = 'Email profil sudah digunakan oleh akun lain.';
            }
            supabase_auth_admin_delete_user($authUserId);
            return ['success' => false, 'message' => 'Gagal membuat profil DLH: ' . $message];
        }

        $dashboardInsert = supabase_insert('dashboard_users', [
            'profile_id' => $authUserId,
            'nama_lengkap' => $nama,
            'username' => $username,
            'email' => $email,
            'password_hash' => password_hash($password, PASSWORD_DEFAULT),
            'role' => 'dlh',
            'is_active' => true,
            'created_at' => admin_now_iso(),
            'updated_at' => admin_now_iso(),
        ]);

        $dashboardUser = is_array($dashboardInsert) && isset($dashboardInsert[0]) && is_array($dashboardInsert[0]) ? $dashboardInsert[0] : null;
        if (!is_array($dashboardUser) || !isset($dashboardUser['id'])) {
            supabase_delete('profiles', ['id' => 'eq.' . $authUserId]);
            supabase_auth_admin_delete_user($authUserId);
            $message = supabase_last_error() ?? 'unknown error';
            if (str_contains(strtolower($message), 'duplicate')) {
                $message = 'Username atau email dashboard sudah digunakan.';
            }
            return ['success' => false, 'message' => 'Gagal membuat akun dashboard DLH: ' . $message];
        }

        return [
            'success' => true,
            'message' => 'Data DLH berhasil ditambahkan.',
            'id' => $authUserId,
        ];
    }

    $profile = supabase_update('profiles', [
        'nama_lengkap' => $nama,
        'email' => $email,
        'no_telp' => $noTelp,
        'updated_at' => admin_now_iso(),
    ], ['id' => 'eq.' . $profileId]);

    if ($profile === [] && supabase_last_error() !== null) {
        return ['success' => false, 'message' => 'Gagal memperbarui profil DLH: ' . supabase_last_error()];
    }

    $detail = admin_dlh_by_id($profileId);
    if ($detail !== null && ($detail['dashboard_user_id'] ?? '') !== '') {
        supabase_update('dashboard_users', [
            'nama_lengkap' => $nama,
            'username' => $username,
            'email' => $email,
            'updated_at' => admin_now_iso(),
        ], ['id' => 'eq.' . (string) ($detail['dashboard_user_id'] ?? '')]);

        if (supabase_last_error() !== null) {
            return ['success' => false, 'message' => 'Profil DLH tersimpan, tetapi akun dashboard gagal diperbarui: ' . supabase_last_error()];
        }
    }

    return [
        'success' => true,
        'message' => 'Data DLH berhasil diperbarui.',
        'id' => $profileId,
    ];
}

function admin_reset_dlh_password(string $profileId, string $newPassword): array
{
    if (mb_strlen($newPassword) < 8) {
        return ['success' => false, 'message' => 'Password baru minimal 8 karakter.'];
    }

    $detail = admin_dlh_by_id($profileId);
    if ($detail === null || ($detail['dashboard_user_id'] ?? '') === '') {
        return ['success' => false, 'message' => 'Akun dashboard DLH tidak ditemukan.'];
    }

    supabase_update('dashboard_users', [
        'password_hash' => password_hash($newPassword, PASSWORD_DEFAULT),
        'updated_at' => admin_now_iso(),
    ], ['id' => 'eq.' . (string) ($detail['dashboard_user_id'] ?? '')]);

    if (supabase_last_error() !== null) {
        return ['success' => false, 'message' => 'Reset password gagal: ' . supabase_last_error()];
    }

    return ['success' => true, 'message' => 'Password DLH berhasil direset.'];
}

function admin_rewards_list(array $filters = []): array
{
    $rows = supabase_fetch('reward', '*', ['order' => 'created_at.desc']);
    $items = array_values(array_map(static function (array $row): array {
        return [
            'id_reward' => (int) ($row['id_reward'] ?? 0),
            'nama_reward' => (string) ($row['nama_reward'] ?? '-'),
            'jenis_reward' => (string) ($row['jenis_reward'] ?? '-'),
            'provider' => (string) ($row['provider'] ?? '-'),
            'nominal_reward' => (string) ($row['nominal_reward'] ?? '-'),
            'poin_dibutuhkan' => (int) ($row['poin_dibutuhkan'] ?? 0),
            'status_reward' => (string) ($row['status_reward'] ?? 'Nonaktif'),
            'created_at' => format_date($row['created_at'] ?? null),
        ];
    }, array_values(array_filter($rows, 'is_array'))));

    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $jenis = trim((string) ($filters['jenis_reward'] ?? ''));
    $status = trim((string) ($filters['status_reward'] ?? ''));

    $items = array_values(array_filter($items, static function (array $item) use ($q, $jenis, $status): bool {
        if ($q !== '') {
            $haystack = strtolower(implode(' ', [
                (string) $item['nama_reward'],
                (string) $item['provider'],
                (string) $item['nominal_reward'],
            ]));
            if (!str_contains($haystack, $q)) {
                return false;
            }
        }

        if ($jenis !== '' && strcasecmp((string) $item['jenis_reward'], $jenis) !== 0) {
            return false;
        }

        if ($status !== '' && strcasecmp((string) $item['status_reward'], $status) !== 0) {
            return false;
        }

        return true;
    }));

    return $items;
}

function admin_reward_by_id(string $id): ?array
{
    if ($id === '' || !ctype_digit($id)) {
        return null;
    }

    $reward = supabase_fetch_one('reward', '*', ['id_reward' => 'eq.' . $id]);
    return is_array($reward) ? $reward : null;
}

function admin_save_reward(array $data, ?int $rewardId = null): array
{
    $nama = trim((string) ($data['nama_reward'] ?? ''));
    $jenis = trim((string) ($data['jenis_reward'] ?? ''));
    $provider = trim((string) ($data['provider'] ?? ''));
    $nominal = trim((string) ($data['nominal_reward'] ?? ''));
    $poin = (int) ($data['poin_dibutuhkan'] ?? 0);
    $status = trim((string) ($data['status_reward'] ?? 'Aktif'));

    if ($nama === '' || $jenis === '' || $provider === '' || $nominal === '' || $poin <= 0) {
        return ['success' => false, 'message' => 'Semua field reward wajib diisi dengan benar.'];
    }

    if (!in_array($jenis, ['Pulsa', 'Kuota'], true)) {
        return ['success' => false, 'message' => 'Jenis reward harus Pulsa atau Kuota.'];
    }

    if (!in_array($status, ['Aktif', 'Nonaktif'], true)) {
        return ['success' => false, 'message' => 'Status reward tidak valid.'];
    }

    $payload = [
        'nama_reward' => $nama,
        'jenis_reward' => $jenis,
        'provider' => $provider,
        'nominal_reward' => $nominal,
        'poin_dibutuhkan' => $poin,
        'status_reward' => $status,
        'updated_at' => admin_now_iso(),
    ];

    if ($rewardId === null) {
        $inserted = supabase_insert('reward', array_merge($payload, ['created_at' => admin_now_iso()]));
        if ($inserted === [] && supabase_last_error() !== null) {
            return ['success' => false, 'message' => 'Gagal menambah reward: ' . supabase_last_error()];
        }

        $row = is_array($inserted) && isset($inserted[0]) && is_array($inserted[0]) ? $inserted[0] : null;
        return [
            'success' => true,
            'message' => 'Reward berhasil ditambahkan.',
            'id' => (int) ($row['id_reward'] ?? 0),
        ];
    }

    supabase_update('reward', $payload, ['id_reward' => 'eq.' . $rewardId]);
    if (supabase_last_error() !== null) {
        return ['success' => false, 'message' => 'Gagal memperbarui reward: ' . supabase_last_error()];
    }

    return [
        'success' => true,
        'message' => 'Reward berhasil diperbarui.',
        'id' => $rewardId,
    ];
}

function admin_delete_reward(int $rewardId): array
{
    if ($rewardId <= 0) {
        return ['success' => false, 'message' => 'ID reward tidak valid.'];
    }

    if (!supabase_delete('reward', ['id_reward' => 'eq.' . $rewardId])) {
        return ['success' => false, 'message' => 'Gagal menghapus reward: ' . (supabase_last_error() ?? 'unknown error')];
    }

    return ['success' => true, 'message' => 'Reward berhasil dihapus.'];
}

function admin_toggle_reward_status(int $rewardId): array
{
    $reward = admin_reward_by_id((string) $rewardId);
    if (!is_array($reward)) {
        return ['success' => false, 'message' => 'Reward tidak ditemukan.'];
    }

    $nextStatus = strcasecmp((string) ($reward['status_reward'] ?? 'Aktif'), 'Aktif') === 0 ? 'Nonaktif' : 'Aktif';
    supabase_update('reward', [
        'status_reward' => $nextStatus,
        'updated_at' => admin_now_iso(),
    ], ['id_reward' => 'eq.' . $rewardId]);

    if (supabase_last_error() !== null) {
        return ['success' => false, 'message' => 'Gagal mengubah status reward: ' . supabase_last_error()];
    }

    return ['success' => true, 'message' => 'Status reward berhasil diubah menjadi ' . $nextStatus . '.'];
}

function admin_point_redemptions_list(array $filters = []): array
{
    $rows = supabase_fetch('penukaran_poin', '*', ['order' => 'tanggal_penukaran.desc']);
    $rows = array_values(array_filter($rows, 'is_array'));
    if ($rows === []) {
        return [];
    }

    $profileIds = array_values(array_unique(array_filter(array_map(
        static fn (array $row): string => (string) ($row['id_masyarakat'] ?? ''),
        $rows
    ))));
    $rewardIds = array_values(array_unique(array_filter(array_map(
        static fn (array $row): int => (int) ($row['id_reward'] ?? 0),
        $rows
    ))));

    $profiles = [];
    $profileFilter = admin_in_filter($profileIds);
    if ($profileFilter !== null) {
        foreach (supabase_fetch('profiles', 'id,nama_lengkap,email,no_telp', ['id' => $profileFilter]) as $profile) {
            if (is_array($profile)) {
                $profiles[(string) ($profile['id'] ?? '')] = $profile;
            }
        }
    }

    $rewards = [];
    $rewardFilter = admin_in_filter($rewardIds);
    if ($rewardFilter !== null) {
        foreach (supabase_fetch('reward', 'id_reward,nama_reward,jenis_reward,provider,nominal_reward', ['id_reward' => $rewardFilter]) as $reward) {
            if (is_array($reward)) {
                $rewards[(int) ($reward['id_reward'] ?? 0)] = $reward;
            }
        }
    }

    $items = [];
    foreach ($rows as $row) {
        $profile = $profiles[(string) ($row['id_masyarakat'] ?? '')] ?? [];
        $reward = $rewards[(int) ($row['id_reward'] ?? 0)] ?? [];

        $items[] = [
            'id_penukaran' => (int) ($row['id_penukaran'] ?? 0),
            'nama_user' => (string) (($profile['nama_lengkap'] ?? '-') ?: '-'),
            'email_user' => (string) (($profile['email'] ?? '-') ?: '-'),
            'no_hp_tujuan' => (string) ($row['no_hp_tujuan'] ?? '-'),
            'reward' => (string) (($reward['nama_reward'] ?? '-') ?: '-'),
            'jenis_reward' => (string) (($reward['jenis_reward'] ?? '-') ?: '-'),
            'provider' => (string) (($reward['provider'] ?? '-') ?: '-'),
            'nominal_reward' => (string) (($reward['nominal_reward'] ?? '-') ?: '-'),
            'poin_terpakai' => (int) ($row['poin_terpakai'] ?? 0),
            'status_proses' => (string) ($row['status_proses'] ?? 'Pending'),
            'kode_referensi' => (string) ($row['kode_referensi'] ?? ''),
            'tanggal_penukaran' => format_date($row['tanggal_penukaran'] ?? null),
            'tanggal_diproses' => format_date($row['tanggal_diproses'] ?? null),
        ];
    }

    $q = strtolower(trim((string) ($filters['q'] ?? '')));
    $status = trim((string) ($filters['status_proses'] ?? ''));

    $items = array_values(array_filter($items, static function (array $item) use ($q, $status): bool {
        if ($q !== '') {
            $haystack = strtolower(implode(' ', [
                (string) $item['nama_user'],
                (string) $item['email_user'],
                (string) $item['reward'],
                (string) $item['no_hp_tujuan'],
                (string) $item['kode_referensi'],
            ]));

            if (!str_contains($haystack, $q)) {
                return false;
            }
        }

        if ($status !== '' && strcasecmp((string) $item['status_proses'], $status) !== 0) {
            return false;
        }

        return true;
    }));

    return $items;
}

function admin_point_redemption_by_id(string $id): ?array
{
    if ($id === '' || !ctype_digit($id)) {
        return null;
    }

    $row = supabase_fetch_one('penukaran_poin', '*', ['id_penukaran' => 'eq.' . $id]);
    if (!is_array($row)) {
        return null;
    }

    $profile = supabase_fetch_one('profiles', 'id,nama_lengkap,email,no_telp', ['id' => 'eq.' . (string) ($row['id_masyarakat'] ?? '')]);
    $reward = supabase_fetch_one('reward', '*', ['id_reward' => 'eq.' . (int) ($row['id_reward'] ?? 0)]);

    return [
        'id_penukaran' => (int) ($row['id_penukaran'] ?? 0),
        'status_proses' => (string) ($row['status_proses'] ?? 'Pending'),
        'kode_referensi' => (string) ($row['kode_referensi'] ?? ''),
        'tanggal_penukaran' => format_date($row['tanggal_penukaran'] ?? null),
        'tanggal_diproses' => format_date($row['tanggal_diproses'] ?? null),
        'raw_tanggal_penukaran' => (string) ($row['tanggal_penukaran'] ?? ''),
        'no_hp_tujuan' => (string) ($row['no_hp_tujuan'] ?? '-'),
        'poin_terpakai' => (int) ($row['poin_terpakai'] ?? 0),
        'alasan_gagal' => (string) ($row['alasan_gagal'] ?? ''),
        'user' => [
            'id' => (string) ($profile['id'] ?? ''),
            'nama' => (string) (($profile['nama_lengkap'] ?? '-') ?: '-'),
            'email' => (string) (($profile['email'] ?? '-') ?: '-'),
            'no_telp' => (string) (($profile['no_telp'] ?? '-') ?: '-'),
        ],
        'reward' => [
            'id_reward' => (int) ($reward['id_reward'] ?? 0),
            'nama_reward' => (string) (($reward['nama_reward'] ?? '-') ?: '-'),
            'jenis_reward' => (string) (($reward['jenis_reward'] ?? '-') ?: '-'),
            'provider' => (string) (($reward['provider'] ?? '-') ?: '-'),
            'nominal_reward' => (string) (($reward['nominal_reward'] ?? '-') ?: '-'),
            'status_reward' => (string) (($reward['status_reward'] ?? '-') ?: '-'),
        ],
    ];
}

function admin_update_point_redemption_status(int $id, array $data): array
{
    $detail = admin_point_redemption_by_id((string) $id);
    if ($detail === null) {
        return ['success' => false, 'message' => 'Transaksi tukar poin tidak ditemukan.'];
    }

    $status = trim((string) ($data['status_proses'] ?? ''));
    $kodeReferensi = trim((string) ($data['kode_referensi'] ?? ''));
    $alasanGagal = trim((string) ($data['alasan_gagal'] ?? ''));

    if (!in_array($status, ['Sukses', 'Gagal'], true)) {
        return ['success' => false, 'message' => 'Status proses harus Sukses atau Gagal.'];
    }

    if ($status === 'Sukses' && $kodeReferensi === '') {
        return ['success' => false, 'message' => 'Kode referensi wajib diisi untuk status sukses.'];
    }

    if ($status === 'Gagal' && $alasanGagal === '') {
        return ['success' => false, 'message' => 'Alasan gagal wajib diisi.'];
    }

    $payload = [
        'status_proses' => $status,
        'tanggal_diproses' => admin_now_iso(),
        'updated_at' => admin_now_iso(),
    ];

    if ($status === 'Sukses') {
        $payload['kode_referensi'] = $kodeReferensi;
    } else {
        $payload['kode_referensi'] = '';
    }

    supabase_update('penukaran_poin', $payload, ['id_penukaran' => 'eq.' . $id]);
    if (supabase_last_error() !== null) {
        return ['success' => false, 'message' => 'Gagal memperbarui transaksi: ' . supabase_last_error()];
    }

    if ($status === 'Gagal') {
        supabase_update('penukaran_poin', [
            'alasan_gagal' => $alasanGagal,
            'updated_at' => admin_now_iso(),
        ], ['id_penukaran' => 'eq.' . $id]);

        if (supabase_last_error() !== null) {
            return [
                'success' => true,
                'message' => 'Status transaksi berhasil diubah menjadi gagal, tetapi alasan gagal belum tersimpan karena kolom `alasan_gagal` belum tersedia di tabel `penukaran_poin`.',
            ];
        }
    }

    return [
        'success' => true,
        'message' => $status === 'Sukses'
            ? 'Status transaksi berhasil diubah menjadi sukses.'
            : 'Status transaksi berhasil diubah menjadi gagal.',
    ];
}
