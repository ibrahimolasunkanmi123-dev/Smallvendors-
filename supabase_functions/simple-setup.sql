-- Simple profiles table setup without triggers
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY,
  email TEXT,
  name TEXT,
  profile_image TEXT,
  location TEXT DEFAULT 'Location not set',
  user_type TEXT DEFAULT 'buyer',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Disable RLS for testing
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Create a simple insert function for manual profile creation
CREATE OR REPLACE FUNCTION create_profile(
  user_id UUID,
  user_email TEXT,
  user_name TEXT DEFAULT NULL,
  user_location TEXT DEFAULT 'Location not set'
)
RETURNS profiles AS $$
DECLARE
  new_profile profiles;
BEGIN
  INSERT INTO profiles (id, email, name, location, user_type)
  VALUES (user_id, user_email, user_name, user_location, 'buyer')
  RETURNING * INTO new_profile;
  
  RETURN new_profile;
END;
$$ LANGUAGE plpgsql;