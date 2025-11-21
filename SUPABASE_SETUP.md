# Supabase Database Setup Guide

Follow these steps to set up your Supabase database for the Finance Tracker app.

## Step 1: Access Supabase Dashboard

1. Go to [https://supabase.com](https://supabase.com)
2. Sign in to your account
3. Select your project (the one with URL: `https://phxbciykiwakhcfuamli.supabase.co`)

## Step 2: Open SQL Editor

1. In the left sidebar, click on **SQL Editor** (icon looks like `</>`)
2. Click **New Query** button

## Step 3: Run the Setup Script

1. Copy the entire contents of `supabase_setup.sql` file
2. Paste it into the SQL Editor
3. Click **Run** button (or press `Ctrl+Enter`)

The script will create:
- ✅ `transactions` table with all necessary columns
- ✅ Indexes for better query performance
- ✅ Row Level Security (RLS) policies
- ✅ `receipts` storage bucket for receipt images
- ✅ Storage policies for uploads and downloads

## Step 4: Verify the Setup

### Check the Transactions Table

1. Go to **Table Editor** in the left sidebar
2. You should see a `transactions` table
3. Click on it to view the structure

**Expected columns:**
- `id` (uuid, primary key)
- `amount` (numeric)
- `category` (text)
- `date` (timestamp with time zone)
- `description` (text)
- `is_expense` (boolean)
- `receipt_url` (text, nullable)
- `created_at` (timestamp with time zone)
- `updated_at` (timestamp with time zone)

### Check the Storage Bucket

1. Go to **Storage** in the left sidebar
2. You should see a `receipts` bucket
3. This is where receipt images will be stored

## Step 5: (Optional) Add Sample Data

If you want to test with some sample data, run this in the SQL Editor:

```sql
INSERT INTO transactions (amount, category, date, description, is_expense)
VALUES 
  (45.50, 'Food', NOW() - INTERVAL '1 day', 'Lunch at restaurant', true),
  (120.00, 'Shopping', NOW() - INTERVAL '2 days', 'New shoes', true),
  (3500.00, 'Salary', NOW() - INTERVAL '5 days', 'Monthly salary', false),
  (25.00, 'Transport', NOW() - INTERVAL '3 days', 'Uber ride', true),
  (80.00, 'Entertainment', NOW() - INTERVAL '4 days', 'Movie tickets', true);
```

## Security Notes

⚠️ **Important**: The current setup allows public access to the database. This is fine for development, but for production you should:

1. **Enable Authentication**: Set up Supabase Auth
2. **Update RLS Policies**: Restrict access to authenticated users only
3. **Add User Column**: Add a `user_id` column to track which user owns each transaction

### Example Production RLS Policy

```sql
-- Remove the public policy
DROP POLICY "Allow all operations on transactions" ON transactions;

-- Add user_id column
ALTER TABLE transactions ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- Create policy for authenticated users to see only their own data
CREATE POLICY "Users can view their own transactions"
ON transactions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own transactions"
ON transactions FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own transactions"
ON transactions FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own transactions"
ON transactions FOR DELETE
USING (auth.uid() = user_id);
```

## Troubleshooting

### Error: "relation already exists"
- This means the table was already created. You can safely ignore this error.

### Error: "permission denied"
- Make sure you're logged in as the project owner
- Check that you have the correct project selected

### Storage bucket not appearing
- Refresh the page
- Check the Storage section in the left sidebar
- Make sure the SQL script ran without errors

## Next Steps

Once the database is set up, your app is ready to use! Run:

```bash
flutter run
```

The app will automatically connect to your Supabase database and you can start adding transactions!
