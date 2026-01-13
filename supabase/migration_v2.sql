-- Migration to v2 Schema

-- 1. Enhance Crops Table
ALTER TABLE public.crops ADD COLUMN IF NOT EXISTS expected_harvest_date date;
ALTER TABLE public.crops ADD COLUMN IF NOT EXISTS notes text;
-- Update status check if needed
-- ALTER TABLE public.crops DROP CONSTRAINT IF EXISTS crops_status_check;
-- ALTER TABLE public.crops ADD CONSTRAINT crops_status_check CHECK (status IN ('Active', 'Completed', 'Archived'));

-- 2. Chick Sources Table
CREATE TABLE IF NOT EXISTS public.chick_sources (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_id uuid REFERENCES public.crops(id) ON DELETE CASCADE,
    supplier_name text NOT NULL,
    count integer NOT NULL,
    unit_price numeric,
    created_at timestamptz DEFAULT now()
);

-- 3. Enhance Daily Logs (Renaming Growth Logs or Creating New)
-- Let's keep growth_logs but rename to daily_logs for clarity if desired, 
-- or just ensure it has all needed fields.
ALTER TABLE public.growth_logs RENAME TO daily_logs;
ALTER TABLE public.daily_logs RENAME COLUMN mortality_count TO mortality;
ALTER TABLE public.daily_logs ADD COLUMN IF NOT EXISTS water_consumed_liters numeric;
ALTER TABLE public.daily_logs ADD COLUMN IF NOT EXISTS notes text;

-- 4. Enhance Vaccinations
ALTER TABLE public.vaccinations ADD COLUMN IF NOT EXISTS standard_day integer;
ALTER TABLE public.vaccinations RENAME COLUMN scheduled_date TO target_date;
-- Update status check
-- ALTER TABLE public.vaccinations DROP CONSTRAINT IF EXISTS vaccinations_status_check;
-- ALTER TABLE public.vaccinations ADD CONSTRAINT vaccinations_status_check CHECK (status IN ('Pending', 'Administered', 'Missed'));

-- 5. Feed Inventory Tracking
-- Existing feed_types and feed_logs are okay, but let's add brand to feed_types
ALTER TABLE public.feed_types ADD COLUMN IF NOT EXISTS brand text;
ALTER TABLE public.feed_types ADD COLUMN IF NOT EXISTS description text;

-- 6. Enable RLS for new tables
ALTER TABLE public.chick_sources ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all access" ON public.chick_sources FOR ALL USING (true);

-- 7. Add comments for documentation
COMMENT ON TABLE public.daily_logs IS 'Daily tracking of mortality, feed, and growth';
