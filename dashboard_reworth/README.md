# ReWorth Dashboard V1

Dashboard web ReWorth memakai PHP Native, 1 login, 1 layout utama, dan 3 role: `admin`, `dlh`, `seller`.

## Menjalankan Lokal
Dashboard membutuhkan PHP.

### Konfigurasi Supabase lokal

File `app/config/supabase.local.php` berisi secret dan sengaja tidak disimpan
di Git. Minta secret key kepada pengelola project melalui pesan pribadi, lalu
jalankan dari root repository:

```powershell
powershell -ExecutionPolicy Bypass -File dashboard_reworth/scripts/setup-supabase-local.ps1 -SecretKey "ISI_SECRET_KEY"
```

Jangan mengirim secret key melalui commit, issue, atau grup publik.

Jika PHP sudah terpasang dan bisa dipanggil dari terminal:
```bash
php -S localhost:8000 -t dashboard_reworth
```

Buka:
```text
http://localhost:8000/public/login.php
```

Jika memakai XAMPP/Laragon dan project ada di subfolder, buka contoh:
```text
http://localhost/ReWorth_PBLsem4/dashboard_reworth/public/login.php
```

Lalu sesuaikan `APP_BASE_URL` di `app/config/app.php`, misalnya:
```php
const APP_BASE_URL = '/ReWorth_PBLsem4/dashboard_reworth/';
```

## Akun Demo
```text
Admin: admin1 / admin1
DLH: petugasdlh1 / petugasdlh1
Seller demo: ecocraft / seller123
```

## Catatan
- Login dashboard membaca data Supabase.
- Seller hanya dapat login setelah pengajuannya disetujui admin.
- Semua halaman dashboard memakai layout reusable dari `app/layout/main_layout.php`.
