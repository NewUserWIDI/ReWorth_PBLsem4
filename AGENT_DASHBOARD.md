# AGENT_DASHBOARD.md - ReWorth Dashboard V1

## 1) Ringkasan
Dokumen ini menjadi arahan untuk AI/tim yang mengerjakan dashboard web ReWorth.
Dashboard dibuat terpisah dari mobile di folder `dashboard_reworth`, memakai **PHP Native**, dan mengikuti pola dashboard PHP klasik seperti repo referensi `jsofiah/PBL-LabSE`, tetapi dibuat lebih rapi dengan:
- 1 sistem login,
- 1 layout/template utama,
- 3 role dashboard: `admin`, `seller`, dan `dlh`.

Referensi struktur lama:
https://github.com/jsofiah/PBL-LabSE

## 2) Prinsip Utama
- Dashboard web bukan bagian dari folder `mobile_reworth`.
- Dashboard dibuat sebagai aplikasi web sendiri di folder `dashboard_reworth`.
- Login hanya 1 halaman untuk semua role.
- Setelah login, user diarahkan berdasarkan role.
- Template dashboard hanya 1, tetapi sidebar/menu/konten berubah sesuai role.
- Jangan membuat 3 project dashboard terpisah.
- Jangan membuat dashboard mobile user di sini; user masyarakat tetap memakai aplikasi Flutter.
- Gunakan mock data dulu agar UI dan flow bisa diuji sebelum database tersambung.

## 2.1) Status Implementasi Saat Ini
Struktur awal dashboard ReWorth sudah dibuat di folder `dashboard_reworth`.

Yang sudah tersedia:
- struktur folder dashboard PHP Native,
- login tunggal untuk `admin`, `dlh`, dan `seller`,
- session auth mock-first,
- middleware login dan role,
- layout dashboard reusable,
- sidebar role-based,
- halaman dashboard minimal untuk admin, DLH, dan seller,
- halaman monitoring dasar admin,
- halaman detail/verifikasi laporan DLH,
- halaman produk/pesanan/transaksi seller,
- mock data untuk akun, statistik, laporan, seller, produk, pesanan, dan reward,
- CSS dasar dashboard hijau ReWorth,
- README dashboard.

Catatan:
- Dashboard masih mock-first, belum tersambung database.
- Aksi validasi laporan, tolak laporan, dan approve/reject seller masih bersifat mock.
- File upload belum aktif, folder upload baru disiapkan.

## 2.2) Cara Menjalankan Dashboard
Dashboard ini membutuhkan PHP karena dibuat dengan PHP Native.

### Opsi 1 - PHP Sudah Terpasang di PATH
Jalankan dari root repo:
```bash
php -S localhost:8000 -t dashboard_reworth
```

Lalu buka:
```text
http://localhost:8000/public/login.php
```

### Opsi 2 - XAMPP
1. Install atau buka XAMPP.
2. Jalankan Apache.
3. Pindahkan atau salin folder repo ke dalam `htdocs`, atau pastikan folder project dapat diakses Apache.
4. Buka URL sesuai lokasi folder.

Contoh jika folder ada di `htdocs/ReWorth_PBLsem4`:
```text
http://localhost/ReWorth_PBLsem4/dashboard_reworth/public/login.php
```

Jika memakai XAMPP dan URL memakai subfolder, sesuaikan `APP_BASE_URL` di:
```text
dashboard_reworth/app/config/app.php
```

Contoh:
```php
const APP_BASE_URL = '/ReWorth_PBLsem4/dashboard_reworth/';
```

### Opsi 3 - Laragon
1. Letakkan project di folder `www`.
2. Jalankan Laragon.
3. Buka dashboard melalui localhost atau pretty URL Laragon.

Contoh:
```text
http://localhost/ReWorth_PBLsem4/dashboard_reworth/public/login.php
```

Jika memakai subfolder, sesuaikan juga `APP_BASE_URL`.

## 3) Role Dashboard
### Admin
Admin adalah role tertinggi untuk monitoring seluruh sistem.
Admin dapat melihat user, laporan sampah, seller, pengajuan seller, produk, pesanan, reward, dan aktivitas lintas role.

### DLH
DLH adalah petugas Dinas Lingkungan Hidup.
DLH hanya fokus pada laporan sampah: melihat laporan, membuka detail, memvalidasi laporan, dan menolak laporan dengan alasan.

### Seller
Seller adalah penjual mini market.
Seller hanya mengelola toko sendiri, produk sendiri, pesanan toko sendiri, dan riwayat transaksi toko sendiri.

## 4) Alur Login
1. Semua role membuka `public/login.php`.
2. User mengisi email/username dan password.
3. Sistem mengecek data akun dashboard.
4. Jika akun valid, session dibuat berisi:
   - `user_id`
   - `nama`
   - `email`
   - `role`
   - `status`
5. Jika role `admin`, redirect ke `app/modules/admin/dashboard.php`.
6. Jika role `dlh`, redirect ke `app/modules/dlh/dashboard.php`.
7. Jika role `seller`, redirect ke `app/modules/seller/dashboard.php`.
8. Jika user mencoba akses halaman role lain, sistem menolak lewat middleware role.
9. Logout menghapus session dan kembali ke halaman login.

## 5) Struktur Folder
```text
dashboard_reworth/
  public/
    index.php
    login.php
    logout.php
    assets/
      css/
        app.css
        dashboard.css
      js/
        app.js
      images/
        logo_reworth.png

  app/
    config/
      app.php
      database.php

    core/
      auth.php
      middleware.php
      helpers.php

    layout/
      main_layout.php
      sidebar.php
      topbar.php
      footer.php

    components/
      stat_card.php
      table.php
      badge_status.php
      action_button.php
      form_input.php
      modal.php

    modules/
      admin/
        dashboard.php
        users.php
        reports.php
        sellers.php
        seller_requests.php
        products.php
        orders.php
        rewards.php

      dlh/
        dashboard.php
        reports.php
        report_detail.php
        verification_action.php

      seller/
        dashboard.php
        store_profile.php
        products.php
        product_form.php
        orders.php
        transactions.php

    data/
      mock_data.php

  storage/
    uploads/
      reports/
      products/
      seller_documents/

  README.md
```

## 6) Fungsi Tiap Folder
### `public/`
Berisi file yang langsung dibuka browser.
Contoh: `login.php`, `logout.php`, `index.php`, CSS, JavaScript, dan gambar.

### `app/config/`
Berisi konfigurasi aplikasi dan database.
Untuk tahap awal, database boleh belum aktif. Tetap siapkan file-nya agar nanti mudah disambungkan.

### `app/core/`
Berisi fungsi inti:
- auth/session,
- middleware login,
- middleware role,
- helper redirect,
- helper format status.

### `app/layout/`
Berisi template dashboard reusable:
- layout utama,
- sidebar,
- topbar,
- footer.

Folder ini penting agar dashboard admin, DLH, dan seller tidak copy-paste layout.

### `app/components/`
Berisi komponen kecil yang dipakai ulang:
- card statistik,
- tabel,
- badge status,
- tombol aksi,
- input form,
- modal.

### `app/modules/admin/`
Berisi halaman khusus admin.
Admin boleh mengakses monitoring sistem secara menyeluruh.

### `app/modules/dlh/`
Berisi halaman khusus DLH.
DLH hanya mengelola laporan sampah.

### `app/modules/seller/`
Berisi halaman khusus seller.
Seller hanya mengelola toko sendiri.

### `app/data/`
Berisi `mock_data.php` sebagai data dummy awal.
Ini dipakai sebelum database/backend tersambung.

### `storage/uploads/`
Berisi file upload:
- foto laporan sampah,
- foto produk,
- dokumen/foto pendukung seller.

## 7) Fungsi File Inti
### `public/index.php`
Entry awal dashboard.
Jika belum login, arahkan ke `login.php`.
Jika sudah login, arahkan ke dashboard sesuai role.

### `public/login.php`
Halaman login tunggal untuk admin, DLH, dan seller.
Halaman ini tidak memiliki pilihan role manual; role dibaca dari data akun setelah login berhasil.

### `public/logout.php`
Menghapus session dan redirect ke login.

### `app/config/app.php`
Menyimpan konfigurasi umum, seperti nama aplikasi, base URL, dan mode mock/database.

### `app/config/database.php`
Menyimpan koneksi database.
Untuk tahap awal boleh placeholder dulu.

### `app/core/auth.php`
Berisi fungsi:
- `login($email, $password)`
- `logout()`
- `current_user()`
- `is_logged_in()`
- `redirect_by_role($role)`

### `app/core/middleware.php`
Berisi guard:
- `require_login()`
- `require_role($role)`
- `require_active_seller()`

### `app/core/helpers.php`
Berisi helper kecil seperti:
- `redirect($path)`
- `e($value)` untuk escape output HTML
- `format_status($status)`
- `status_badge_class($status)`

### `app/layout/main_layout.php`
Wrapper utama dashboard.
Menerima title dan content page, lalu memuat sidebar, topbar, content, dan footer.

### `app/layout/sidebar.php`
Menampilkan menu berbeda berdasarkan `$_SESSION['role']`.

### `app/layout/topbar.php`
Menampilkan judul halaman, nama user login, role, dan tombol logout.

### `app/data/mock_data.php`
Sumber data sementara:
- akun dashboard dummy,
- statistik admin,
- laporan sampah,
- pengajuan seller,
- produk,
- pesanan,
- reward.

## 8) Dashboard Admin
Admin adalah pengawas seluruh sistem.

### Menu Admin
- Dashboard
- Data User
- Laporan Sampah
- Pengajuan Seller
- Data Seller
- Produk
- Pesanan
- Reward
- Logout

### File Admin
- `dashboard.php`: ringkasan statistik sistem.
- `users.php`: daftar user mobile.
- `reports.php`: monitoring semua laporan sampah.
- `sellers.php`: daftar seller aktif/nonaktif.
- `seller_requests.php`: daftar pengajuan seller pending.
- `products.php`: monitoring produk mini market.
- `orders.php`: monitoring pesanan mini market.
- `rewards.php`: monitoring penukaran poin pulsa/kuota.

### Flow Admin
1. Login sebagai admin.
2. Masuk ke `admin/dashboard.php`.
3. Melihat ringkasan total user, laporan masuk, laporan valid, seller aktif, produk, pesanan, dan reward.
4. Membuka `seller_requests.php` untuk approve/reject pengajuan seller.
5. Membuka `reports.php` untuk memantau laporan yang diverifikasi DLH.
6. Membuka `products.php` dan `orders.php` untuk monitoring mini market.
7. Membuka `rewards.php` untuk melihat penukaran poin pulsa/kuota.

## 9) Dashboard DLH
DLH fokus pada laporan sampah.
DLH tidak mengelola seller, produk, pesanan, atau reward.

### Menu DLH
- Dashboard DLH
- Laporan Menunggu
- Laporan Valid
- Laporan Ditolak
- Logout

### File DLH
- `dashboard.php`: ringkasan laporan.
- `reports.php`: daftar laporan sampah.
- `report_detail.php`: detail laporan, foto, lokasi, deskripsi, jenis sampah, tingkat keparahan, pelapor, dan status.
- `verification_action.php`: proses POST validasi/tolak laporan.

### Flow DLH
1. Login sebagai DLH.
2. Masuk ke `dlh/dashboard.php`.
3. Melihat jumlah laporan menunggu, valid, ditolak, dan selesai.
4. Membuka `dlh/reports.php`.
5. Memilih laporan dan masuk ke `dlh/report_detail.php`.
6. Jika laporan layak, klik validasi.
7. Sistem mengubah status menjadi `valid`, memberi user 10 poin, dan menambah streak +1.
8. Jika laporan tidak layak, klik tolak.
9. Sistem wajib meminta alasan penolakan sebelum status berubah menjadi `ditolak`.

## 10) Dashboard Seller
Seller hanya mengelola toko sendiri.
Seller tidak boleh melihat semua seller, semua user, semua laporan sampah, atau dashboard admin.

### Menu Seller
- Dashboard Toko
- Profil Toko
- Produk Saya
- Pesanan Masuk
- Riwayat Transaksi
- Logout

### File Seller
- `dashboard.php`: ringkasan toko.
- `store_profile.php`: data toko seller.
- `products.php`: daftar produk toko sendiri.
- `product_form.php`: tambah/edit produk.
- `orders.php`: daftar pesanan masuk.
- `transactions.php`: riwayat transaksi toko sendiri.

### Flow Seller
1. Seller hanya bisa login jika status sudah `aktif`.
2. Masuk ke `seller/dashboard.php`.
3. Melihat ringkasan produk aktif, pesanan baru, pesanan diproses, dan total penjualan.
4. Membuka `seller/products.php` untuk melihat produk toko sendiri.
5. Membuka `seller/product_form.php` untuk tambah/edit produk.
6. Membuka `seller/orders.php` untuk memproses pesanan.
7. Membuka `seller/transactions.php` untuk melihat riwayat transaksi toko sendiri.

## 11) Aturan Bisnis Dashboard
- Admin boleh melihat semua data.
- DLH hanya boleh mengelola laporan sampah.
- Seller hanya boleh mengelola data toko sendiri.
- Laporan baru selalu berstatus `menunggu_verifikasi`.
- Laporan valid memberi user 10 poin.
- Tiap laporan valid menambah streak user +1.
- Jika streak mencapai 5, user mendapat bonus poin dan streak reset ke 0.
- Laporan ditolak wajib punya alasan.
- Seller baru tidak aktif sebelum disetujui admin.
- Reward hanya pulsa/kuota, bukan e-wallet atau cash.
- Aksi penting harus memakai method `POST`.

Contoh aksi penting:
- validasi laporan,
- tolak laporan,
- approve seller,
- reject seller,
- update status pesanan,
- nonaktifkan produk.

## 12) Status yang Digunakan
### Status Laporan
- `menunggu_verifikasi`
- `valid`
- `ditolak`
- `diproses`
- `selesai`

Untuk tahap awal, minimal gunakan:
- `menunggu_verifikasi`
- `valid`
- `ditolak`

### Status Seller
- `pending`
- `aktif`
- `ditolak`
- `nonaktif`

### Status Pesanan
- `baru`
- `diproses`
- `dikirim`
- `selesai`
- `dibatalkan`

### Status Reward
- `menunggu`
- `diproses`
- `selesai`
- `gagal`

## 13) Akun Demo Mock
Gunakan akun dummy ini untuk testing awal sebelum database aktif.

```text
Admin
Email: admin@reworth.app
Password: password123
Role: admin

DLH
Email: dlh@reworth.app
Password: password123
Role: dlh

Seller Aktif
Email: seller@reworth.app
Password: password123
Role: seller
Status: aktif

Seller Pending
Email: sellerpending@reworth.app
Password: password123
Role: seller
Status: pending
```

## 14) Catatan UI
- Bahasa UI: Bahasa Indonesia.
- Gaya dashboard: rapi, bersih, mudah discan, tidak terlalu ramai.
- Warna utama mengikuti ReWorth:
  - hijau tua `#3B6D11`
  - hijau utama `#6BAD34`
  - hijau muda `#B5FF77`
  - background `#F5F7F2`
  - putih `#FFFFFF`
  - teks utama `#1E1E1E`
  - teks sekunder `#6B7280`
  - error `#D32F2F`
  - warning `#F9A825`
- Sidebar harus jelas dan berbeda menu berdasarkan role.
- Tabel harus punya status badge agar mudah dibaca.
- Aksi berbahaya seperti tolak/hapus/nonaktif harus punya konfirmasi.

## 15) Urutan Pengerjaan untuk AI/Tim
1. Buat folder `dashboard_reworth`.
2. Buat struktur folder sesuai dokumen ini.
3. Buat file konfigurasi dasar.
4. Buat mock data akun dan data dashboard.
5. Buat auth/session login tunggal.
6. Buat middleware login dan role.
7. Buat layout utama reusable.
8. Buat sidebar role-based.
9. Buat dashboard admin minimal.
10. Buat dashboard DLH minimal.
11. Buat dashboard seller minimal.
12. Tambahkan flow aksi POST penting.
13. Rapikan UI dashboard.
14. Lakukan test manual semua role.
15. Setelah stabil, sambungkan database.

## 16) Test Plan Minimum
- Login admin mengarah ke dashboard admin.
- Login DLH mengarah ke dashboard DLH.
- Login seller aktif mengarah ke dashboard seller.
- Seller pending tidak boleh masuk dashboard.
- Admin tidak kehilangan akses ke menu monitoring.
- DLH tidak bisa membuka halaman admin/seller.
- Seller tidak bisa membuka halaman admin/DLH.
- Validasi laporan mengubah status dan menambah poin.
- Tolak laporan gagal jika alasan kosong.
- Approve seller mengubah status seller menjadi aktif.
- Logout menghapus session.

## 17) Larangan Implementasi
- Jangan membuat 3 folder project dashboard terpisah.
- Jangan membuat login berbeda untuk admin, DLH, dan seller.
- Jangan menyimpan password plaintext saat sudah memakai database.
- Jangan membuat fitur setor sampah atau event di dashboard V1 kecuali ada change request baru.
- Jangan membuat reward cash/e-wallet; reward hanya pulsa/kuota.
- Jangan menaruh semua logic dalam satu file besar.

## 18) Definisi Selesai Dashboard V1 Awal
Dashboard V1 awal dianggap siap jika:
- struktur folder sudah rapi,
- login tunggal berjalan,
- role-based redirect berjalan,
- middleware role berjalan,
- admin, DLH, dan seller punya dashboard masing-masing,
- layout utama dipakai bersama,
- mock data cukup untuk demo flow,
- akses lintas role tertolak,
- logout berjalan.
