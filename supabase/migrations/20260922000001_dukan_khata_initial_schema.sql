-- DukanKhata V1 initial schema.
-- Owner is the only user (single shop). user_id anchors RLS so the
-- structure can later enforce per-user ownership.

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  category text not null default 'Other',
  photo_url text,
  default_cost_price numeric(12,2) not null default 0,
  default_sale_price numeric(12,2) not null default 0,
  stock_quantity integer not null default 0,
  is_favorite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.stock_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete cascade not null,
  quantity integer not null check (quantity > 0),
  purchase_price numeric(12,2) not null check (purchase_price >= 0),
  total_cost numeric(12,2) not null,
  purchased_at timestamptz not null default now()
);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete cascade not null,
  quantity integer not null check (quantity > 0),
  cost_price numeric(12,2) not null check (cost_price >= 0),
  sale_price numeric(12,2) not null check (sale_price >= 0),
  revenue numeric(12,2) not null,
  profit numeric(12,2) not null,
  input_method text not null check (input_method in ('manual', 'voice')),
  sold_at timestamptz not null default now()
);

create table if not exists public.inventory_adjustments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete cascade not null,
  quantity_change integer not null check (quantity_change <> 0),
  reason text,
  created_at timestamptz not null default now()
);

create index if not exists products_user_idx on public.products (user_id);
create index if not exists products_category_idx on public.products (category);
create index if not exists stock_purchases_product_idx on public.stock_purchases (product_id, purchased_at desc);
create index if not exists sales_product_idx on public.sales (product_id, sold_at desc);
create index if not exists sales_user_sold_idx on public.sales (user_id, sold_at desc);
create index if not exists inventory_adjustments_product_idx on public.inventory_adjustments (product_id, created_at desc);

alter table public.products enable row level security;
alter table public.stock_purchases enable row level security;
alter table public.sales enable row level security;
alter table public.inventory_adjustments enable row level security;

create policy "products_select_own" on public.products for select to authenticated using ((select auth.uid()) = user_id);
create policy "products_insert_own" on public.products for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "products_update_own" on public.products for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "products_delete_own" on public.products for delete to authenticated using ((select auth.uid()) = user_id);

create policy "stock_purchases_select_own" on public.stock_purchases for select to authenticated using ((select auth.uid()) = user_id);
create policy "stock_purchases_insert_own" on public.stock_purchases for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "stock_purchases_update_own" on public.stock_purchases for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "stock_purchases_delete_own" on public.stock_purchases for delete to authenticated using ((select auth.uid()) = user_id);

create policy "sales_select_own" on public.sales for select to authenticated using ((select auth.uid()) = user_id);
create policy "sales_insert_own" on public.sales for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "sales_update_own" on public.sales for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "sales_delete_own" on public.sales for delete to authenticated using ((select auth.uid()) = user_id);

create policy "inventory_adjustments_select_own" on public.inventory_adjustments for select to authenticated using ((select auth.uid()) = user_id);
create policy "inventory_adjustments_insert_own" on public.inventory_adjustments for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "inventory_adjustments_update_own" on public.inventory_adjustments for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "inventory_adjustments_delete_own" on public.inventory_adjustments for delete to authenticated using ((select auth.uid()) = user_id);

-- Storage: product photos bucket (public read, owner-only write)
insert into storage.buckets (id, name, public) values ('product-photos', 'product-photos', true) on conflict (id) do nothing;

create policy "product_photos_select" on storage.objects for select using (bucket_id = 'product-photos');
create policy "product_photos_insert" on storage.objects for insert to authenticated with check (bucket_id = 'product-photos');
create policy "product_photos_update" on storage.objects for update to authenticated using (bucket_id = 'product-photos') with check (bucket_id = 'product-photos');
create policy "product_photos_delete" on storage.objects for delete to authenticated using (bucket_id = 'product-photos');

-- Keep products.updated_at fresh (manual writes to stock/sales use triggers
-- only where needed; this is the only trigger in V1).
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger products_set_updated_at before update on public.products for each row execute function public.set_updated_at();