-- Jalankan di Supabase SQL Editor
-- Tujuan: membuat 1 akun seller demo yang langsung terhubung ke produk Eco Craft
-- Login dashboard:
-- username: ecocraft
-- password: seller123

insert into public.seller (
    id_masyarakat,
    nama_toko,
    deskripsi_toko,
    alamat_toko,
    foto_toko,
    username_dashboard,
    password_hash_dashboard,
    aktif,
    created_at,
    updated_at
)
values (
    '5c16b203-0b61-49e9-afa9-b7a9b89d3bed',
    'Eco Craft',
    'Toko produk daur ulang ReWorth untuk seller demo dashboard.',
    'Alamat toko Eco Craft',
    null,
    'ecocraft',
    'seller123',
    true,
    now(),
    now()
)
on conflict (id_masyarakat) do update
set
    nama_toko = excluded.nama_toko,
    deskripsi_toko = excluded.deskripsi_toko,
    alamat_toko = excluded.alamat_toko,
    username_dashboard = excluded.username_dashboard,
    password_hash_dashboard = excluded.password_hash_dashboard,
    aktif = excluded.aktif,
    updated_at = now();
