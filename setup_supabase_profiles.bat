@echo off
echo Setting up Supabase profiles and user management...

echo.
echo 1. Deploying Edge Function...
supabase functions deploy create-user-profile

echo.
echo 2. Setting up database tables and triggers...
echo Please run the following SQL in your Supabase SQL Editor:
echo.
echo ----------------------------------------
type supabase_functions\setup-profiles.sql
echo ----------------------------------------
echo.
echo 3. After running the SQL, your users will automatically get profiles created when they sign up!
echo.
pause