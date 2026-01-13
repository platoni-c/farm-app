-- 1. Add user_id column to crops table
alter table public.crops add column if not exists user_id uuid references public.users(id) on delete cascade;

-- 2. Add user_id column to other primary tables if necessary
-- Note: feed_types can be shared or per-user. If per-user:
alter table public.feed_types add column if not exists user_id uuid references public.users(id) on delete cascade;

-- 3. Update existing records to belong to a user (if any exist)
-- This is just for safety during migration if there's already data
do $$
declare
    first_user_id uuid;
begin
    select id into first_user_id from public.users limit 1;
    if first_user_id is not null then
        update public.crops set user_id = first_user_id where user_id is null;
        update public.feed_types set user_id = first_user_id where user_id is null;
    end if;
end $$;

-- 4. Set user_id to NOT NULL for future records
-- alter table public.crops alter column user_id set not null;
-- alter table public.feed_types alter column user_id set not null;

-- 5. Update RLS Policies for Crops
drop policy if exists "Allow all access" on public.crops;
create policy "Users can view their own crops"
on public.crops for select
using (auth.uid() = user_id);

create policy "Users can insert their own crops"
on public.crops for insert
with check (auth.uid() = user_id);

create policy "Users can update their own crops"
on public.crops for update
using (auth.uid() = user_id);

create policy "Users can delete their own crops"
on public.crops for delete
using (auth.uid() = user_id);

-- 6. Update RLS Policies for Vaccinations (via join or direct user_id)
-- Simpler to allow access if the user owns the crop
drop policy if exists "Allow all access" on public.vaccinations;
create policy "Users can manage vaccinations of their crops"
on public.vaccinations for all
using (
    exists (
        select 1 from public.crops
        where public.crops.id = public.vaccinations.crop_id
        and public.crops.user_id = auth.uid()
    )
);

-- 7. Update RLS Policies for Feed Types
drop policy if exists "Allow all access" on public.feed_types;
create policy "Users can manage their own feed types"
on public.feed_types for all
using (auth.uid() = user_id);

-- 8. Update RLS Policies for Feed Logs
drop policy if exists "Allow all access" on public.feed_logs;
create policy "Users can manage feed logs of their crops"
on public.feed_logs for all
using (
    exists (
        select 1 from public.crops
        where public.crops.id = public.feed_logs.crop_id
        and public.crops.user_id = auth.uid()
    )
);

-- 9. Update RLS Policies for Daily Logs
drop policy if exists "Allow all access" on public.daily_logs;
create policy "Users can manage daily logs of their crops"
on public.daily_logs for all
using (
    exists (
        select 1 from public.crops
        where public.crops.id = public.daily_logs.crop_id
        and public.crops.user_id = auth.uid()
    )
);

-- 10. Chick Sources
drop policy if exists "Allow all access" on public.chick_sources;
create policy "Users can manage chick sources of their crops"
on public.chick_sources for all
using (
    exists (
        select 1 from public.crops
        where public.crops.id = public.chick_sources.crop_id
        and public.crops.user_id = auth.uid()
    )
);
