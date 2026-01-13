-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Crops Table
create table public.crops (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    total_chicks integer not null default 0,
    arrival_date date not null,
    source text check (source in ('Normal', 'KENCHICK')),
    normal_chicks_count integer default 0,
    kenchick_chicks_count integer default 0,
    sawdust_amount_kg numeric default 0,
    status text default 'Active' check (status in ('Active', 'Completed')),
    created_at timestamptz default now()
);

-- Vaccinations Table
create table public.vaccinations (
    id uuid primary key default gen_random_uuid(),
    crop_id uuid references public.crops(id) on delete cascade,
    vaccine_name text not null,
    scheduled_date date not null,
    status text default 'Upcoming' check (status in ('Completed', 'Upcoming', 'Missed')),
    completed_at timestamptz,
    notes text,
    created_at timestamptz default now()
);

-- Feed Types Table
create table public.feed_types (
    id uuid primary key default gen_random_uuid(),
    name text unique not null,
    current_stock_kg numeric default 0,
    reorder_level_kg numeric default 100,
    unit text default 'kg',
    created_at timestamptz default now()
);

-- Feed Logs Table
create table public.feed_logs (
    id uuid primary key default gen_random_uuid(),
    feed_type_id uuid references public.feed_types(id),
    crop_id uuid references public.crops(id),
    action text not null check (action in ('Restock', 'Usage')),
    quantity_kg numeric not null,
    log_date timestamptz default now()
);

-- Growth Logs Table (for Mortality and Growth metrics)
create table public.growth_logs (
    id uuid primary key default gen_random_uuid(),
    crop_id uuid references public.crops(id) on delete cascade,
    log_date date not null default current_date,
    mortality_count integer default 0,
    avg_weight_g numeric,
    feed_consumed_kg numeric,
    created_at timestamptz default now(),
    unique(crop_id, log_date)
);

-- Row Level Security (RLS)
alter table public.crops enable row level security;
alter table public.vaccinations enable row level security;
alter table public.feed_types enable row level security;
alter table public.feed_logs enable row level security;
alter table public.growth_logs enable row level security;

-- Allow all authenticated users to read/write for now
create policy "Allow all access" on public.crops for all using (true);
create policy "Allow all access" on public.vaccinations for all using (true);
create policy "Allow all access" on public.feed_types for all using (true);
create policy "Allow all access" on public.feed_logs for all using (true);
create policy "Allow all access" on public.growth_logs for all using (true);
