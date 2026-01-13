-- 1. Drop existing users table and dependent objects to start fresh
-- WARNING: This will delete existing data in public.users
drop table if exists public.users cascade;

-- 2. Create the public.users table with id as the primary key referencing auth.users
create table public.users (
    id uuid primary key references auth.users(id) on delete cascade,
    email text,
    full_name text,
    created_at timestamptz default now()
);

-- 3. Enable Row Level Security
alter table public.users enable row level security;

-- 4. Create RLS Policies
-- Allow users to read their own profile
drop policy if exists "Users can view own profile" on public.users;
create policy "Users can view own profile" 
on public.users for select 
using (auth.uid() = id);

-- Allow users to update their own profile
drop policy if exists "Users can update own profile" on public.users;
create policy "Users can update own profile" 
on public.users for update 
using (auth.uid() = id);

-- 5. Create the function to handle new user signups
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
    insert into public.users (id, email, full_name)
    values (
        new.id,
        new.email,
        new.raw_user_meta_data->>'full_name'
    )
    on conflict (id) do nothing;
    return new;
end;
$$;

-- 6. Create the trigger on auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

-- 7. Populate existing users (Backfill)
insert into public.users (id, email, full_name)
select 
    id, 
    email, 
    raw_user_meta_data->>'full_name'
from auth.users
on conflict (id) do nothing;
