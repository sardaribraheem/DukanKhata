-- Preserve sale history when a product is edited or removed.
-- Sale rows already snapshot the prices used for revenue and profit.

alter table public.sales
  add column if not exists product_name_snapshot text;

update public.sales as sales
set product_name_snapshot = products.name
from public.products as products
where sales.product_id = products.id
  and sales.product_name_snapshot is null;

alter table public.sales
  alter column product_id drop not null;

alter table public.sales
  drop constraint if exists sales_product_id_fkey;

alter table public.sales
  add constraint sales_product_id_fkey
  foreign key (product_id) references public.products(id) on delete set null;

alter table public.sales
  alter column product_name_snapshot set not null;

create index if not exists sales_user_sold_idx on public.sales (user_id, sold_at desc);
