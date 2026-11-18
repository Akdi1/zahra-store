-- Zahra store schema for Supabase. Run in SQL Editor as project owner.
create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null check (category in ('beauty','perfume','accessories','fashion')),
  subcategory text,
  price numeric(10,2) not null check (price >= 0),
  old_price numeric(10,2),
  image text,
  description text,
  stock integer not null default 0 check (stock >= 0),
  badge text,
  rating numeric(2,1) default 0,
  reviews integer default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text unique not null,
  customer_name text not null,
  phone text not null,
  city text not null,
  address text not null,
  items jsonb not null,
  subtotal numeric(10,2) not null,
  shipping numeric(10,2) not null default 0,
  total numeric(10,2) not null,
  status text not null default 'new' check (status in ('new','confirmed','shipped','delivered','cancelled')),
  payment_method text not null default 'cash_on_delivery' check (payment_method = 'cash_on_delivery'),
  created_at timestamptz not null default now()
);

-- Assign this app_metadata role only through a trusted owner-side action.
create or replace function public.is_zahra_admin()
returns boolean language sql stable as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'zahra_admin', false);
$$;

alter table public.products enable row level security;
alter table public.orders enable row level security;

drop policy if exists "public read active products" on public.products;
create policy "public read active products" on public.products for select using (active = true or public.is_zahra_admin());
drop policy if exists "admin manage products" on public.products;
create policy "admin manage products" on public.products for all using (public.is_zahra_admin()) with check (public.is_zahra_admin());

drop policy if exists "public create COD orders" on public.orders;
create policy "public create COD orders" on public.orders for insert with check (payment_method = 'cash_on_delivery' and status = 'new');
drop policy if exists "admin read orders" on public.orders;
create policy "admin read orders" on public.orders for select using (public.is_zahra_admin());
drop policy if exists "admin update orders" on public.orders;
create policy "admin update orders" on public.orders for update using (public.is_zahra_admin()) with check (public.is_zahra_admin());
