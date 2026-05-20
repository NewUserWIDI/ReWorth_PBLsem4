# AGENT.md � ReWorth V1 Baseline (Terkunci)

## 1) Ringkasan Eksekusi
- Fokus fase saat ini: frontend mobile pada folder `mobile_reworth`.
- Dashboard web (Admin, DLH, Seller) dikerjakan setelah mobile frontend selesai.
- Keputusan stack dashboard (Flutter Web vs React/Next) ditunda sampai fase dashboard dimulai.
- Dokumen ini adalah baseline V1. Perubahan dilakukan lewat change request terkontrol.

## 2) Visi Produk
ReWorth adalah platform komunitas untuk pengelolaan sampah berbasis circular economy yang menghubungkan masyarakat, DLH, seller, dan admin agar:
- pelaporan sampah liar lebih rapi dan transparan,
- partisipasi masyarakat naik lewat insentif poin,
- sampah punya nilai ekonomi lewat mini market produk daur ulang/ramah lingkungan.

## 3) Scope V1 Mobile (Yang Wajib Dibangun Sekarang)
### In Scope
- Authentication: register, login, logout.
- Beranda: total poin, streak, shortcut fitur, aktivitas terbaru,nama user 
- Lapor Sampah: foto, alamat/lokasi, deskripsi, jenis sampah, tingkat keparahan.
- Riwayat Laporan: list + detail + status + alasan penolakan.
- Tukar Poin: reward pulsa/kuota.
- Mini Market: katalog, kategori, detail produk, wishlist, cart, checkout, riwayat pesanan.
- Profile: edit profil, kelola alamat, kelola metode pembayaran, logout.
- Registrasi Seller: form pengajuan seller.

### Out of Scope (V1 Mobile)
- Setor sampah.
- Event lingkungan.
- Reward e-wallet, saldo aplikasi, cash out.

## 4) Role dan Hak Akses
### User (Masyarakat)
- Menggunakan aplikasi mobile: auth, lapor sampah, riwayat, reward, mini market, profile.
- Tidak boleh mengakses dashboard admin/DLH/seller.

### DLH (Fase Dashboard)
- Verifikasi laporan sampah: valid/tolak.
- Penolakan wajib beralasan.
- Tidak mengelola seller atau transaksi mini market menyeluruh.

### Seller (Fase Dashboard)
- Registrasi seller menunggu approval admin.
- Setelah aktif: kelola produk, pesanan, transaksi toko sendiri.

### Admin (Fase Dashboard)
- Monitoring sistem menyeluruh.
- Approve/reject registrasi seller.
- Monitoring aktivitas user, DLH, seller, reward, transaksi.

## 5) Aturan Bisnis Inti V1 (Lock)
- Status awal laporan: `menunggu_verifikasi`.
- Laporan valid: user mendapat 10 poin.
- Tiap validasi valid menambah streak +1.
- Saat streak mencapai 5: bonus poin diberikan, streak reset ke 0.
- Laporan ditolak: alasan wajib, poin tidak bertambah.
- Reward exchange hanya pulsa/kuota.
- Metode pembayaran ditambahkan dari Profile, checkout hanya memilih metode tersimpan.
- Maksimal alamat tersimpan per user: 3 alamat.

## 6) Arsitektur Teknis yang Disepakati
- Flutter + Riverpod + go_router.
- Mock-first terstruktur (siap sambung backend/Supabase di fase berikutnya).
- Struktur folder utama: `app`, `core`, `shared`, `features`.
- Layer per fitur:
  - `presentation`: halaman + widget UI.
  - `application`: controller/state.
  - `domain`: model entitas + rule domain.
  - `data`: repository interface + mock implementation.

## 7) Konvensi Penamaan
- Folder tetap bahasa Inggris agar standar proyek.
- Nama file Dart dibuat jelas dan mudah dipahami tim (boleh istilah domain Indonesia).
- Konvensi:
  - halaman: `*_page.dart`
  - controller: `*_controller.dart`
  - state: `*_state.dart`
  - repository: `*_repository.dart`
  - model domain: nama entitas langsung (`laporan_sampah.dart`, `produk.dart`)

## 8) Rekomendasi Struktur `lib/`
```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme.dart
  core/
    constants/
    utils/
  shared/
    widgets/
    models/
  features/
    auth/
    home/
    waste_report/
    rewards/
    marketplace/
    profile/
    seller_registration/
```

## 9) Urutan Pengerjaan End-to-End (Wajib Ikuti)
1. Stabilkan baseline project agar bisa run tanpa error.
2. Bangun fondasi app: theme, router, constants, shared widgets.
3. Bangun fitur auth (register/login/logout flow).
4. Bangun beranda (poin, streak, shortcut, aktivitas).
5. Bangun waste report (form laporan + riwayat + detail).
6. Implement domain rule poin/streak sesuai lock 10/5.
7. Bangun rewards (list reward, validasi poin, transaksi penukaran).
8. Bangun marketplace bertahap: katalog -> detail -> wishlist -> cart -> checkout -> order history.
9. Bangun profile: edit profil, alamat (maks 3), metode pembayaran.
10. Bangun seller registration (submit pengajuan + status).
11. Rapikan UX state (loading, empty, error, success feedback).
12. Testing minimum + hardening sebelum deklarasi selesai V1 mobile.

## 10) Definisi Selesai (DoD) Mobile V1
Mobile dianggap selesai jika:
- seluruh flow utama berjalan: auth, lapor, riwayat, poin/reward, mini market, profile,
- aturan bisnis inti berjalan sesuai baseline,
- navigasi/state antar halaman tidak putus,
- validasi form inti aktif,
- tidak ada error kritikal pada alur utama.

## 11) Test Plan Minimum
### Unit Test
- Rule poin/streak.
- Validasi poin cukup/tidak cukup saat tukar reward.
- Cart merge: produk yang sama menambah kuantitas, bukan duplikat baris.
- Batas maksimal 3 alamat.

### Widget/Integration Smoke
- Login/register.
- Submit laporan.
- Cek riwayat + status laporan.
- Tukar poin reward.
- Checkout dengan alamat + metode pembayaran tersimpan.

## 12) Alur Fitur Utama
### Lapor Sampah
1. User login.
2. User isi form laporan dan kirim.
3. Status jadi `menunggu_verifikasi`.
4. Nanti DLH verifikasi di dashboard.
5. Jika valid: +10 poin, streak +1, bonus jika streak ke-5.
6. Jika ditolak: user lihat alasan penolakan di riwayat.

### Tukar Poin
1. User buka halaman reward.
2. Pilih reward pulsa/kuota.
3. Sistem cek kecukupan poin.
4. Jika cukup: poin berkurang, transaksi reward tercatat.
5. Jika tidak cukup: tampil pesan gagal.

### Mini Market
1. User lihat katalog produk.
2. Buka detail, tambah wishlist/cart.
3. Cart menggabungkan item produk sama ke kuantitas.
4. Checkout pilih alamat tersimpan (maks 3) dan metode pembayaran dari Profile.
5. Buat pesanan dan tampil di riwayat pesanan.

## 13) UI dan Visual
- Bahasa UI: Bahasa Indonesia.
- Gaya UI: production-ready ringan (rapi, konsisten, tidak berlebihan).
- Palet utama:
  - `#2E7D32` (hijau tua)
  - `#4CAF50` (hijau utama)
  - `#A5D6A7` (hijau muda)
  - `#E8F5E9` (hijau sangat muda)
  - `#FFFFFF` (putih)
  - `#F5F5F5` (abu background)
  - `#616161` (teks sekunder)
  - `#212121` (teks utama)
  - `#D32F2F` (error)
  - `#F57C00` (warning)

## 14) Manajemen Perubahan Setelah Lock
- Baseline ini adalah V1.0.
- Perubahan baru masuk sebagai change request dengan isi:
  - tujuan perubahan,
  - dampak ke flow/data/UI/timeline,
  - kategori minor/medium/major.
- Dashboard dimulai setelah mobile frontend V1 selesai.

## 15) Keputusan yang Ditunda (Sengaja)
- Nama folder dashboard final.
- Stack dashboard (Flutter Web vs React/Next).
- Keduanya ditetapkan saat fase dashboard dimulai.

## 16) Catatan Implementasi untuk Agent
- Jangan implement fitur di luar scope V1.
- Selalu jaga pemisahan layer per fitur.
- Prioritaskan flow end-to-end jalan dulu dengan mock data.
- Setelah stabil, baru lanjut integrasi backend.
