begin;

alter table public.pengajuan_seller enable row level security;

do $$
begin
    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pengajuan_seller'
          and policyname = 'pengajuan_seller_select_own'
    ) then
        create policy pengajuan_seller_select_own
            on public.pengajuan_seller
            for select
            to authenticated
            using (id_masyarakat = auth.uid());
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pengajuan_seller'
          and policyname = 'pengajuan_seller_insert_own'
    ) then
        create policy pengajuan_seller_insert_own
            on public.pengajuan_seller
            for insert
            to authenticated
            with check (id_masyarakat = auth.uid());
    end if;

    if not exists (
        select 1 from pg_policies
        where schemaname = 'public'
          and tablename = 'pengajuan_seller'
          and policyname = 'pengajuan_seller_update_own'
    ) then
        create policy pengajuan_seller_update_own
            on public.pengajuan_seller
            for update
            to authenticated
            using (id_masyarakat = auth.uid())
            with check (id_masyarakat = auth.uid());
    end if;
end $$;

commit;
