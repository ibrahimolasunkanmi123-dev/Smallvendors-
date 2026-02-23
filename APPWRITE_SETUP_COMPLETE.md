# Appwrite Setup Guide for Small Vendors App

## Quick Setup Steps

### 1. Create Appwrite Project
1. Go to [Appwrite Cloud](https://cloud.appwrite.io)
2. Create a new account or sign in
3. Create a new project with ID: `smallvendors-app`
4. Copy your project ID and update it in `lib/services/appwrite_service.dart`

### 2. Create Database and Collections

#### Database Setup
1. In your Appwrite console, go to "Databases"
2. Create a new database with ID: `smallvendors-db`

#### Collections Setup
Create these collections in your database:

**1. Users Collection (ID: `users`)**
- Attributes:
  - `name` (String, required)
  - `email` (String, required)
  - `userType` (String, required) - "buyer" or "vendor"
  - `phone` (String, optional)
  - `address` (String, optional)
  - `createdAt` (String, required)

**2. Vendors Collection (ID: `vendors`)**
- Attributes:
  - `userId` (String, required)
  - `businessName` (String, required)
  - `businessDescription` (String, optional)
  - `isVerified` (Boolean, default: false)
  - `rating` (Float, default: 0.0)
  - `totalSales` (Integer, default: 0)
  - `createdAt` (String, required)

**3. Buyers Collection (ID: `buyers`)**
- Attributes:
  - `userId` (String, required)
  - `totalOrders` (Integer, default: 0)
  - `totalSpent` (Float, default: 0.0)
  - `preferredCategories` (String array, optional)
  - `createdAt` (String, required)

### 3. Configure Permissions
For each collection, set these permissions:
- **Create**: Users (authenticated users can create)
- **Read**: Users (authenticated users can read)
- **Update**: Users (authenticated users can update their own documents)
- **Delete**: Users (authenticated users can delete their own documents)

### 4. Platform Configuration
1. Go to "Settings" > "Platforms"
2. Add your platforms:
   - **Web**: Add your domain (e.g., `localhost:*` for development)
   - **Flutter**: Add your package name

### 5. Authentication Settings
1. Go to "Auth" > "Settings"
2. Enable "Email/Password" authentication
3. Configure other settings as needed

## Current App Features

✅ **User Registration**: Users can create accounts as buyers or vendors
✅ **User Authentication**: Secure login/logout functionality
✅ **Profile Management**: Separate profiles for buyers and vendors
✅ **Data Persistence**: All user data stored in Appwrite
✅ **Session Management**: Users stay logged in between app sessions

## Testing the App

1. Run the app: `flutter run -d chrome`
2. You'll see the authentication screen
3. Create a new account (choose buyer or vendor)
4. Fill in the required information
5. Sign in with your credentials
6. Your data will be stored in Appwrite and you'll stay logged in

## Next Steps

After setting up Appwrite:
1. Test user registration and login
2. Add product management for vendors
3. Add shopping cart for buyers
4. Implement real-time chat
5. Add payment integration

## Troubleshooting

**Common Issues:**
- **Project ID mismatch**: Make sure the project ID in the code matches your Appwrite project
- **Collection not found**: Ensure all collections are created with exact IDs
- **Permission denied**: Check collection permissions are set correctly
- **CORS errors**: Add your domain to platform settings

**Need Help?**
- Check Appwrite documentation: https://appwrite.io/docs
- Verify your project settings in Appwrite console
- Check browser console for detailed error messages