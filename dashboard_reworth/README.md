# ReWorth Dashboard V1

Dashboard web ReWorth memakai PHP Native, 1 login, 1 layout utama, dan 3 role: `admin`, `dlh`, `seller`.

## Menjalankan Lokal
Dashboard membutuhkan PHP.

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
Admin: admin@reworth.app / password123
DLH: dlh@reworth.app / password123
Seller aktif: seller@reworth.app / password123
Seller pending: sellerpending@reworth.app / password123
```

## Catatan
- Data masih mock-first di `app/data/mock_data.php`.
- Database disiapkan di `app/config/database.php`, tetapi belum diaktifkan.
- Semua halaman dashboard memakai layout reusable dari `app/layout/main_layout.php`.
