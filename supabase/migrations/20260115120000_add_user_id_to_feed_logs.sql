-- Add user_id column to feed_logs
ALTER TABLE feed_logs 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) DEFAULT auth.uid();

-- Add user_id column to daily_logs (optional but good for direct access)
ALTER TABLE daily_logs 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) DEFAULT auth.uid();

-- Update RLS policies to check user_id
ALTER TABLE feed_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own feed logs" ON feed_logs;
CREATE POLICY "Users can view own feed logs" ON feed_logs
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own feed logs" ON feed_logs;
CREATE POLICY "Users can insert own feed logs" ON feed_logs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own feed logs" ON feed_logs;
CREATE POLICY "Users can update own feed logs" ON feed_logs
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own feed logs" ON feed_logs;
CREATE POLICY "Users can delete own feed logs" ON feed_logs
    FOR DELETE USING (auth.uid() = user_id);
