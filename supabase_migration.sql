-- Migration Script for Existing Data
-- Run this AFTER running supabase_setup.sql if you have existing transactions

-- Option 1: Assign all existing transactions to the first user
-- (Use this if you want to keep existing data)
UPDATE transactions 
SET user_id = (SELECT id FROM auth.users ORDER BY created_at LIMIT 1)
WHERE user_id IS NULL;

-- Option 2: Delete all existing transactions
-- (Use this if you want to start fresh)
-- DELETE FROM transactions WHERE user_id IS NULL;

-- Verify migration
SELECT 
  COUNT(*) as total_transactions,
  COUNT(DISTINCT user_id) as unique_users
FROM transactions;
