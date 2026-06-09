begin;

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create table if not exists public.dashboard_users (
    id bigserial primary key,
    profile_id uuid references public.profiles(id) on delete set null,
    nama_lengkap text not null,
    username text not null unique,
    email text,
    password_hash text not null,
    role text not null,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint dashboard_users_role_check check (role in ('admin', 'dlh'))
);

create unique index if not exists dashboard_users_profile_id_key
    on public.dashboard_users (profile_id);

create unique index if not exists dashboard_users_email_lower_key
    on public.dashboard_users (email)
    where email is not null;

alter table public.dashboard_users enable row level security;

create or replace function public.dashboard_login(p_identifier text, p_password text)
returns table (
    dashboard_user_id bigint,
    profile_id uuid,
    username text,
    email text,
    role text,
    nama_lengkap text,
    is_active boolean
)
language plpgsql
security definer
set search_path = public, extensions
as $fn$
begin
    return query
    select
        du.id as dashboard_user_id,
        du.profile_id,
        du.username,
        coalesce(du.email, p.email) as email,
        du.role,
        coalesce(p.nama_lengkap, p.nama, du.nama_lengkap, 'Petugas ReWorth') as nama_lengkap,
        du.is_active
    from public.dashboard_users du
    left join public.profiles p on p.id = du.profile_id
    where du.is_active = true
          and (
            lower(du.username) = lower(trim(p_identifier))
            or lower(coalesce(du.email, p.email, '')) = lower(trim(p_identifier))
          )
      and du.password_hash = crypt(p_password, du.password_hash)
    limit 1;
end;
$fn$;

grant execute on function public.dashboard_login(text, text) to anon, authenticated;

insert into public.dashboard_users (
    nama_lengkap,
    username,
    email,
    password_hash,
    role,
    is_active,
    created_at,
    updated_at
)
values
(
    'Admin ReWorth 1',
    'admin1',
    'admin1@reworth.local',
    '$2y$10$6Q5YeGI4GCYLGdkoxK5nNOON694wWmZywWCMHemi3Jr8MrQJOUXXq',
    'admin',
    true,
    now(),
    now()
),
(
    'Petugas DLH 1',
    'petugasdlh1',
    'petugasdlh1@reworth.local',
    '$2y$10$Yvcb..5OzyNUw9YoM8/VqewfRZN9jHhQ9ZM.jZzJ5xBwhrLK/4CcK',
    'dlh',
    true,
    now(),
    now()
)
on conflict (username) do update
set
    nama_lengkap = excluded.nama_lengkap,
    username = excluded.username,
    email = excluded.email,
    password_hash = excluded.password_hash,
    role = excluded.role,
    is_active = excluded.is_active,
    updated_at = now();

commit;
