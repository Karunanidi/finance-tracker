-- Finance Tracker Database Setup Script (Updated for Multi-User)
-- Run this in your Supabase SQL Editor

-- ============================================
-- STEP 1: Create/Update Transactions Table
-- ============================================

-- Create transactions table if it doesn't exist
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  category TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  description TEXT NOT NULL,
  is_expense BOOLEAN NOT NULL DEFAULT true,
  receipt_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- If table exists but doesn't have user_id, add it
-- Note: This will fail if table already has user_id column, which is fine
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'transactions' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE transactions ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    ALTER TABLE transactions ALTER COLUMN user_id SET NOT NULL;
  END IF;
END $$;

-- ============================================
-- STEP 2: Create Indexes
-- ============================================

-- Create index on user_id for faster user-specific queries
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);

-- Create index on date for faster queries
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC);

-- Create index on category for filtering
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category);

-- Create composite index for user + date queries
CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON transactions(user_id, date DESC);

-- ============================================
-- STEP 3: Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Drop old permissive policies if they exist
DROP POLICY IF EXISTS "Allow all operations on transactions" ON transactions;

-- Create user-specific RLS policies
CREATE POLICY "Users can view own transactions"
  ON transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions"
  ON transactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions"
  ON transactions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions"
  ON transactions FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- STEP 4: Storage Bucket Setup
-- ============================================

-- Create storage bucket for receipts (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', false)
ON CONFLICT (id) DO UPDATE SET public = false;

-- Drop old permissive storage policies
DROP POLICY IF EXISTS "Allow public uploads to receipts bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow public reads from receipts bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow public deletes from receipts bucket" ON storage.objects;

-- Create user-specific storage policies
-- Users can upload to their own folder
CREATE POLICY "Users can upload own receipts"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'receipts' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can view their own receipts
CREATE POLICY "Users can view own receipts"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'receipts' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can delete their own receipts
CREATE POLICY "Users can delete own receipts"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'receipts' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================
-- STEP 5: Helper Functions (Optional)
-- ============================================

-- Function to get user's total transactions count
CREATE OR REPLACE FUNCTION get_user_transaction_count(uid UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER
  FROM transactions
  WHERE user_id = uid;
$$ LANGUAGE SQL SECURITY DEFINER;

-- Function to get user's total balance
CREATE OR REPLACE FUNCTION get_user_balance(uid UUID)
RETURNS DECIMAL AS $$
  SELECT COALESCE(
    SUM(CASE WHEN is_expense THEN -amount ELSE amount END),
    0
  )
  FROM transactions
  WHERE user_id = uid;
$$ LANGUAGE SQL SECURITY DEFINER;

-- ============================================
-- NOTES
-- ============================================

-- 1. All existing transactions without user_id will need to be assigned to a user
--    or deleted. You can run this to assign to first user:
--    UPDATE transactions SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;

-- 2. Storage bucket is now private (public = false) for better security
--    Receipts are organized by user_id: receipts/{user_id}/{filename}

-- 3. RLS policies ensure complete data isolation between users

-- 4. Cascade delete ensures when a user is deleted, all their data is removed
