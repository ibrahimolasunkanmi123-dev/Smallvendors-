# Supabase User Profile Setup Guide

## 🚀 Quick Setup

### Step 1: Run the SQL Migration
1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `supabase_functions/setup-profiles.sql`
4. Click **Run** to execute the SQL

### Step 2: Deploy Edge Function (Optional)
```bash
supabase functions deploy create-user-profile
```

## ✅ What This Sets Up

### Database Table: `profiles`
- **id**: UUID (linked to auth.users)
- **email**: User's email
- **name**: User's display name
- **profile_image**: Profile picture URL/path
- **location**: User's location
- **user_type**: 'buyer' or 'vendor'
- **created_at**: Timestamp
- **updated_at**: Timestamp

### Automatic Profile Creation
- **Database Trigger**: Automatically creates a profile when a user signs up
- **Row Level Security**: Users can only access their own profiles
- **Auto-timestamps**: Automatically updates `updated_at` field

### Updated AuthService
- `createUserProfile()`: Updates profile in Supabase database
- `getUserProfile()`: Fetches profile from Supabase
- Maintains local storage compatibility

## 🔧 How It Works

1. **User Signs Up** → Supabase creates auth user
2. **Database Trigger Fires** → Automatically creates profile record
3. **User Completes Profile** → App updates profile with name, image, location
4. **Profile Synced** → Data stored in both Supabase and local storage

## 🎯 Benefits

- ✅ **Automatic**: No manual profile creation needed
- ✅ **Secure**: Row-level security policies
- ✅ **Scalable**: Server-side database storage
- ✅ **Reliable**: Database triggers ensure consistency
- ✅ **Compatible**: Works with existing local storage

Your users will now have their profiles automatically saved to Supabase when they sign up!