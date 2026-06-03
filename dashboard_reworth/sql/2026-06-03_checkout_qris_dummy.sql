-- ReWorth checkout dummy QRIS
-- Aturan bisnis:
-- 1. Fee platform 10% dihitung per checkout dari subtotal produk.
-- 2. Biaya layanan tetap Rp500 per checkout.
-- 3. Pendapatan seller = subtotal item - alokasi proporsional fee platform.
-- 4. Biaya layanan masuk ke platform dan tidak memotong seller.

begin;

alter table public.pesanan
    add column if not exists subtotal_produk numeric default 0,
    add column if not exists fee_platform_persen numeric default 10,
    add column if not exists fee_platform numeric default 0,
    add column if not exists biaya_layanan numeric default 500;

alter table public.detail_pesanan
    add column if not exists id_seller uuid,
    add column if not exists fee_platform_item numeric default 0,
    add column if not exists pendapatan_seller numeric default 0,
    add column if not exists status_pencairan text default 'tertahan',
    add column if not exists tanggal_pencairan timestamptz;

alter table public.pembayaran
    add column if not exists metode_pembayaran text,
    add column if not exists provider_pembayaran text,
    add column if not exists kode_pembayaran text,
    add column if not exists qr_payload text,
    add column if not exists tanggal_kadaluarsa timestamptz;

create table if not exists public.shipping_methods (
    id bigserial primary key,
    shipping_method text not null,
    estimated_days text not null,
    shipping_fee numeric not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

insert into public.shipping_methods (shipping_method, estimated_days, shipping_fee)
select 'Standard', '3-4 hari', 0
where not exists (
    select 1 from public.shipping_methods where lower(shipping_method) = 'standard'
);

insert into public.shipping_methods (shipping_method, estimated_days, shipping_fee)
select 'Express', '1-2 hari', 12000
where not exists (
    select 1 from public.shipping_methods where lower(shipping_method) = 'express'
);

update public.detail_pesanan dp
set id_seller = p.id_seller
from public.produk p
where dp.id_produk = p.id_produk
  and dp.id_seller is null;

update public.pesanan
set subtotal_produk = coalesce(nullif(subtotal_produk, 0), subtotal)
where subtotal_produk is null
   or subtotal_produk = 0;

update public.pesanan
set fee_platform = coalesce(nullif(fee_platform, 0), pajak)
where fee_platform is null
   or fee_platform = 0;

update public.detail_pesanan dp
set fee_platform_item = round(
        case
            when coalesce(ps.subtotal_produk, ps.subtotal, 0) <= 0 then 0
            else coalesce(ps.fee_platform, ps.pajak, 0) * (dp.subtotal / coalesce(ps.subtotal_produk, ps.subtotal))
        end
    , 2),
    pendapatan_seller = round(
        dp.subtotal - case
            when coalesce(ps.subtotal_produk, ps.subtotal, 0) <= 0 then 0
            else coalesce(ps.fee_platform, ps.pajak, 0) * (dp.subtotal / coalesce(ps.subtotal_produk, ps.subtotal))
        end
    , 2)
from public.pesanan ps
where dp.id_pesanan = ps.id_pesanan
  and (dp.pendapatan_seller is null or dp.pendapatan_seller = 0);

do $$
begin
    if not exists (
        select 1
        from pg_constraint
        where conname = 'detail_pesanan_status_pencairan_check'
    ) then
        alter table public.detail_pesanan
            add constraint detail_pesanan_status_pencairan_check
            check (status_pencairan in ('tertahan', 'tersedia', 'dicairkan', 'dibatalkan'));
    end if;
end $$;

alter table public.pesanan enable row level security;
alter table public.detail_pesanan enable row level security;
alter table public.pembayaran enable row level security;
alter table public.shipping_methods enable row level security;

do $$
begin
    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pesanan'
          and policyname = 'pesanan_select_own'
    ) then
        create policy pesanan_select_own on public.pesanan
            for select
            to authenticated
            using (id_masyarakat = auth.uid());
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pesanan'
          and policyname = 'pesanan_insert_own'
    ) then
        create policy pesanan_insert_own on public.pesanan
            for insert
            to authenticated
            with check (id_masyarakat = auth.uid());
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'detail_pesanan'
          and policyname = 'detail_pesanan_select_own'
    ) then
        create policy detail_pesanan_select_own on public.detail_pesanan
            for select
            to authenticated
            using (
                exists (
                    select 1
                    from public.pesanan ps
                    where ps.id_pesanan = detail_pesanan.id_pesanan
                      and ps.id_masyarakat = auth.uid()
                )
            );
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'detail_pesanan'
          and policyname = 'detail_pesanan_insert_own'
    ) then
        create policy detail_pesanan_insert_own on public.detail_pesanan
            for insert
            to authenticated
            with check (
                exists (
                    select 1
                    from public.pesanan ps
                    where ps.id_pesanan = detail_pesanan.id_pesanan
                      and ps.id_masyarakat = auth.uid()
                )
            );
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pembayaran'
          and policyname = 'pembayaran_select_own'
    ) then
        create policy pembayaran_select_own on public.pembayaran
            for select
            to authenticated
            using (
                exists (
                    select 1
                    from public.pesanan ps
                    where ps.id_pesanan = pembayaran.id_pesanan
                      and ps.id_masyarakat = auth.uid()
                )
            );
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pembayaran'
          and policyname = 'pembayaran_insert_own'
    ) then
        create policy pembayaran_insert_own on public.pembayaran
            for insert
            to authenticated
            with check (
                exists (
                    select 1
                    from public.pesanan ps
                    where ps.id_pesanan = pembayaran.id_pesanan
                      and ps.id_masyarakat = auth.uid()
                )
            );
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pembayaran'
          and policyname = 'pembayaran_update_own'
    ) then
        create policy pembayaran_update_own on public.pembayaran
            for update
            to authenticated
            using (
                exists (
                    select 1
                    from public.pesanan ps
                    where ps.id_pesanan = pembayaran.id_pesanan
                      and ps.id_masyarakat = auth.uid()
                )
            )
            with check (
                exists (
                    select 1
                    from public.pesanan ps
                    where ps.id_pesanan = pembayaran.id_pesanan
                      and ps.id_masyarakat = auth.uid()
                )
            );
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'shipping_methods'
          and policyname = 'shipping_methods_public_read'
    ) then
        create policy shipping_methods_public_read on public.shipping_methods
            for select
            to authenticated, anon
            using (true);
    end if;
end $$;

commit;
