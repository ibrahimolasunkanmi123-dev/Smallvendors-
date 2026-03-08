# Sign In/Sign Up Fix

## ✅ Fixed Issues:
1. Updated Appwrite endpoint to `https://cloud.appwrite.io/v1`
2. Removed self-signed certificate setting (not needed for cloud)
3. Rebuilt web app with correct configuration

## 🔧 Next Steps to Make Sign In Work:

### 1. Add Web Platform in Appwrite Console
1. Go to https://cloud.appwrite.io
2. Open your project (ID: `679b21ef002b28b002d7`)
3. Go to **Settings** → **Platforms**
4. Click **Add Platform** → **Web App**
5. Add your domains:
   - `localhost` (for local testing)
   - `http://localhost:PORT` (replace PORT with your dev server port)
   - Your Vercel domain after deployment

### 2. Verify Database & Collections Exist
1. In Appwrite Console, go to **Databases**
2. Check if database `699b24bd001c72ccf9b6` exists
3. Verify these collections exist:
   - `users`
   - `vendors`
   - `buyers`

### 3. Set Collection Permissions
For each collection, set permissions:
- **Create**: Any user
- **Read**: Users (authenticated)
- **Update**: Users (authenticated)
- **Delete**: Users (authenticated)

## 🧪 Test Sign Up/Sign In:
1. Run: `flutter run -d chrome --web-port=8080`
2. Try creating a new account
3. Check Appwrite Console → Authentication to see new users

## 🚨 Common Errors:
- **"Project not found"**: Wrong project ID
- **"Origin not allowed"**: Add your domain to Appwrite platforms
- **"Collection not found"**: Create collections in Appwrite Console
- **"Permission denied"**: Update collection permissions
