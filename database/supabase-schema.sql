
-- Sulap Artisan production database for Supabase
-- Run this in Supabase Dashboard → SQL Editor → New query → Run.

create extension if not exists pgcrypto;

create table if not exists public.site_settings (
  id int primary key default 1,
  logo_url text,
  hero_badge text not null default '🌿 Now accepting 2025 applications',
  hero_title text not null default 'Bringing artisan makers\nto <span>Sulap Markets</span>',
  hero_subtitle text not null default 'Apply to become a Sulap vendor, showcase your craft at curated artisan markets, and manage everything from one place.',
  updated_at timestamptz not null default now()
);

create table if not exists public.vendors (
  ref_id text primary key,
  user_id uuid references auth.users(id) on delete set null,
  name text not null,
  contact text not null,
  email text not null,
  phone text,
  category text not null,
  state text,
  car_plate text,
  description text,
  price_range text,
  power_needed text,
  booth_notes text,
  instagram text,
  facebook text,
  tiktok text,
  website text,
  photo_count int default 0,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.events (
  id text primary key,
  name text not null,
  date_start date not null,
  date_end date not null,
  time_text text,
  venue text not null,
  fee_fnb numeric(10,2) default 0,
  fee_nonfnb numeric(10,2) default 0,
  status text not null default 'active' check (status in ('draft','active','closed','cancelled')),
  description text,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.event_applications (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.events(id) on delete cascade,
  vendor_ref_id text not null references public.vendors(ref_id) on delete cascade,
  status text not null default 'applied' check (status in ('applied','selected','confirmed','declined')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(event_id, vendor_ref_id)
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.events(id) on delete cascade,
  vendor_ref_id text not null references public.vendors(ref_id) on delete cascade,
  amount numeric(10,2),
  receipt_url text,
  receipt_date date,
  invoice_url text,
  invoice_date date,
  status text not null default 'payment-pending' check (status in ('payment-pending','receipt-uploaded','confirmed','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(event_id, vendor_ref_id)
);

create table if not exists public.parking_records (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.events(id) on delete cascade,
  vendor_ref_id text not null references public.vendors(ref_id) on delete cascade,
  day_index int not null,
  serial_no text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(event_id, vendor_ref_id, day_index)
);

create table if not exists public.vendor_passes (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.events(id) on delete cascade,
  vendor_ref_id text not null references public.vendors(ref_id) on delete cascade,
  collected_by text,
  collector_phone text,
  tags_issued int,
  collected_on date,
  tags_returned int,
  returned_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(event_id, vendor_ref_id)
);

create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  owner_vendor_ref_id text references public.vendors(ref_id) on delete cascade,
  event_id text references public.events(id) on delete cascade,
  file_type text not null check (file_type in ('logo','product-photo','receipt','invoice','event-image')),
  storage_bucket text not null,
  storage_path text not null,
  public_url text,
  created_at timestamptz not null default now()
);

-- Demo seed so your first deployment is not empty.
insert into public.site_settings (id) values (1)
on conflict (id) do nothing;

insert into public.events (id,name,date_start,date_end,time_text,venue,fee_fnb,fee_nonfnb,status,description) values
('E001','Sulap Makers Market — TTDI','2025-06-14','2025-06-15','9am – 6pm','TTDI Park, KL',180,250,'active','Our flagship monthly market in the leafy TTDI park.'),
('E002','Artisan Weekend — Publika','2025-07-05','2025-07-06','10am – 9pm','Publika Mall',280,380,'active','Curated indoor market at Publika.'),
('E003','Merdeka Craft Fair','2025-08-23','2025-08-25','8am – 8pm','Dataran Merdeka, KL',150,200,'active','Special Merdeka edition celebrating Malaysian craft.')
on conflict (id) do nothing;

insert into public.vendors (ref_id,name,contact,email,category,state,car_plate,description,status,photo_count,instagram,facebook) values
('SUL-2025-0038','Tanah Liat Studio','Aishah Ramli','aishah@tanahliat.com','Handmade Crafts & Art','Kuala Lumpur','WXY 5599','Wheel-thrown ceramics — mugs, bowls, vases.','approved',4,'@tanahliatstudio','tanahliatstudio'),
('SUL-2025-0039','Lilin Halus','Farhan Abdul','farhan@lilinhalus.com','Handmade Crafts & Art','Kuala Lumpur','WBC 4412','Hand-poured soy candles with local botanical scents.','approved',3,'@lilinhalus',null),
('SUL-2025-0036','Batik Bayu','Redzuan Ismail','redzuan@batikbayu.com','Fashion & Apparel','Penang','PEA 7711','Contemporary batik wearables with traditional motifs.','pending',4,'@batikbayu',null)
on conflict (ref_id) do nothing;

insert into public.event_applications (event_id,vendor_ref_id,status) values
('E001','SUL-2025-0038','selected'),
('E001','SUL-2025-0039','selected'),
('E002','SUL-2025-0038','confirmed'),
('E002','SUL-2025-0036','confirmed')
on conflict (event_id, vendor_ref_id) do nothing;

insert into public.payments (event_id,vendor_ref_id,amount,status,receipt_url,invoice_url) values
('E002','SUL-2025-0038',380,'confirmed','receipt_tanahliat.pdf','INV-2025-007.pdf'),
('E001','SUL-2025-0039',250,'payment-pending',null,null),
('E002','SUL-2025-0036',380,'confirmed','receipt_batikbayu.pdf','INV-2025-008.pdf')
on conflict (event_id, vendor_ref_id) do nothing;

-- Storage buckets. Public buckets are simplest for free MVP review.
insert into storage.buckets (id, name, public) values
('logos','logos',true),
('product-photos','product-photos',true),
('receipts','receipts',true),
('invoices','invoices',true),
('event-images','event-images',true)
on conflict (id) do nothing;

-- MVP RLS: read public event/site data, write mainly through authenticated users.
alter table public.site_settings enable row level security;
alter table public.vendors enable row level security;
alter table public.events enable row level security;
alter table public.event_applications enable row level security;
alter table public.payments enable row level security;
alter table public.parking_records enable row level security;
alter table public.vendor_passes enable row level security;
alter table public.files enable row level security;

drop policy if exists "public can read site settings" on public.site_settings;
create policy "public can read site settings" on public.site_settings for select using (true);

drop policy if exists "public can read active events" on public.events;
create policy "public can read active events" on public.events for select using (status in ('active','draft','closed'));

drop policy if exists "public can apply as vendor" on public.vendors;
create policy "public can apply as vendor" on public.vendors for insert with check (true);

drop policy if exists "public can read demo vendors" on public.vendors;
create policy "public can read demo vendors" on public.vendors for select using (true);

drop policy if exists "public can read event applications" on public.event_applications;
create policy "public can read event applications" on public.event_applications for select using (true);

drop policy if exists "public can insert event applications" on public.event_applications;
create policy "public can insert event applications" on public.event_applications for insert with check (true);

drop policy if exists "public can read payments" on public.payments;
create policy "public can read payments" on public.payments for select using (true);

drop policy if exists "public can read parking" on public.parking_records;
create policy "public can read parking" on public.parking_records for select using (true);

drop policy if exists "public can read vendor passes" on public.vendor_passes;
create policy "public can read vendor passes" on public.vendor_passes for select using (true);

drop policy if exists "public can read files" on public.files;
create policy "public can read files" on public.files for select using (true);

-- Temporary admin-write policies for MVP. Before launch with real vendors,
-- replace these with role-based admin policies.
drop policy if exists "temporary public update site settings" on public.site_settings;
create policy "temporary public update site settings" on public.site_settings for update using (true) with check (true);
drop policy if exists "temporary public upsert site settings" on public.site_settings;
create policy "temporary public upsert site settings" on public.site_settings for insert with check (true);

drop policy if exists "temporary public manage events" on public.events;
create policy "temporary public manage events" on public.events for all using (true) with check (true);
drop policy if exists "temporary public manage applications" on public.event_applications;
create policy "temporary public manage applications" on public.event_applications for all using (true) with check (true);
drop policy if exists "temporary public manage payments" on public.payments;
create policy "temporary public manage payments" on public.payments for all using (true) with check (true);
drop policy if exists "temporary public manage parking" on public.parking_records;
create policy "temporary public manage parking" on public.parking_records for all using (true) with check (true);
drop policy if exists "temporary public manage vendor passes" on public.vendor_passes;
create policy "temporary public manage vendor passes" on public.vendor_passes for all using (true) with check (true);
