@echo off
echo Deploying Supabase Edge Functions...

REM Deploy email verification success page
echo Deploying email-verified function...
supabase functions deploy email-verified --project-ref ovasrhkddiaifhzlcckh

REM Deploy existing functions if needed
echo Deploying send-email-verification function...
supabase functions deploy send-email-verification --project-ref ovasrhkddiaifhzlcckh

echo Deploying verify-email-code function...
supabase functions deploy verify-email-code --project-ref ovasrhkddiaifhzlcckh

echo.
echo All functions deployed successfully!
echo.
echo Email verification link will redirect to:
echo https://ovasrhkddiaifhzlcckh.supabase.co/functions/v1/email-verified
echo.
pause