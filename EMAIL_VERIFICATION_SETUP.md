# Email Verification Setup Guide

## Overview
This guide shows how to integrate the new email-only verification system that removes phone number requirements.

## Files Created
- `lib/screens/email_signup_screen.dart` - New email-only signup screen
- `lib/screens/email_verification_screen.dart` - Email verification handling screen

## Supabase Configuration

### 1. Email Templates
In your Supabase dashboard, go to Authentication > Email Templates and customize:

**Confirm signup template:**
```html
<h2>Confirm your signup</h2>
<p>Follow this link to confirm your account:</p>
<p><a href="{{ .ConfirmationURL }}">Confirm your account</a></p>
```

### 2. URL Configuration
In Authentication > URL Configuration, set:
- Site URL: `https://your-app-domain.com` or `http://localhost:3000` for development
- Redirect URLs: Add your app's deep link scheme like `smallvendors://verify`

### 3. Email Settings
In Authentication > Settings:
- Enable "Confirm email" 
- Set "Confirm email" to required
- Disable phone confirmation if enabled

## Integration Steps

### 1. Replace Existing Signup
Replace your current signup screen import:

```dart
// OLD
import 'screens/signup_screen.dart';

// NEW  
import 'screens/email_signup_screen.dart';
```

### 2. Update Navigation
In your authentication flow:

```dart
// Navigate to new email signup
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EmailSignupScreen()),
);
```

### 3. Deep Link Handling (Optional)
For automatic verification detection, add deep link handling in your main app:

```dart
// In main.dart or app.dart
void _handleDeepLink(String link) {
  if (link.contains('verify')) {
    // User clicked email verification link
    // Navigate to verification screen or refresh auth state
  }
}
```

## Usage Flow

1. User enters email and password in `EmailSignupScreen`
2. Supabase sends verification email
3. User is redirected to `EmailVerificationScreen`
4. Screen automatically checks for verification every 3 seconds
5. Once verified, user proceeds to profile setup

## Testing

### Local Testing
1. Use a real email address you can access
2. Check spam/junk folders for verification emails
3. Click the verification link in the email
4. The app should automatically detect verification and proceed

### Production
1. Configure proper domain in Supabase settings
2. Set up custom email templates with your branding
3. Test the full flow with real email addresses

## Customization

### Email Template
Customize the verification email in Supabase dashboard under Authentication > Email Templates.

### UI Styling
Modify the screens in:
- `lib/screens/email_signup_screen.dart`
- `lib/screens/email_verification_screen.dart`

### Verification Timing
Adjust the check interval in `email_verification_screen.dart`:
```dart
// Change from 3 seconds to desired interval
_checkTimer = Timer.periodic(const Duration(seconds: 3), ...);
```

## Troubleshooting

### Email Not Received
1. Check Supabase email settings
2. Verify email templates are configured
3. Check spam/junk folders
4. Ensure email service is properly configured in Supabase

### Verification Not Detected
1. Ensure proper redirect URLs are configured
2. Check that email confirmation is enabled in Supabase
3. Verify the auth state change listener is working

### Deep Link Issues
1. Configure proper URL schemes in your app
2. Test deep links on actual devices
3. Ensure Supabase redirect URLs match your app scheme