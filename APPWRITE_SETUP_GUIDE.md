# Appwrite Setup Guide for Small Vendors

## 1. Create Appwrite Account
1. Go to [Appwrite Cloud](https://cloud.appwrite.io)
2. Sign up for a free account
3. Create a new project

## 2. Get Project Configuration
1. In your Appwrite console, go to **Settings** > **General**
2. Copy your **Project ID**
3. Update the `projectId` in `lib/services/appwrite_service.dart`:
   ```dart
   static const String projectId = 'YOUR_ACTUAL_PROJECT_ID_HERE';
   ```

## 3. Create Database and Collections

### Create Database
1. Go to **Databases** in your Appwrite console
2. Create a new database with ID: `699b24bd001c72ccf9b6`

### Create Collections

#### 1. Users Collection
- **Collection ID**: `users`
- **Attributes**:
  - `name` (String, required)
  - `email` (String, required)
  - `userType` (String, required) - 'buyer' or 'vendor'
  - `phone` (String, optional)
  - `address` (String, optional)
  - `createdAt` (String, required)

#### 2. Vendors Collection
- **Collection ID**: `vendors`
- **Attributes**:
  - `userId` (String, required)
  - `businessName` (String, required)
  - `businessDescription` (String, optional)
  - `isVerified` (Boolean, default: false)
  - `rating` (Double, default: 0.0)
  - `totalSales` (Integer, default: 0)
  - `createdAt` (String, required)

#### 3. Buyers Collection
- **Collection ID**: `buyers`
- **Attributes**:
  - `userId` (String, required)
  - `totalOrders` (Integer, default: 0)
  - `totalSpent` (Double, default: 0.0)
  - `preferredCategories` (String Array, optional)
  - `createdAt` (String, required)

## 4. Set Permissions
For each collection, set the following permissions:
- **Create**: Users
- **Read**: Users (for their own documents)
- **Update**: Users (for their own documents)
- **Delete**: Users (for their own documents)

## 5. Authentication Settings
1. Go to **Auth** > **Settings**
2. Enable **Email/Password** authentication
3. Configure session length as needed

## 6. Test the Integration
1. Run your Flutter app
2. Complete the onboarding
3. Try creating a new account as both buyer and vendor
4. Verify that user profiles are created in your Appwrite database

## Features Included

### Authentication
- ✅ User registration with email/password
- ✅ User login
- ✅ User logout
- ✅ Session management
- ✅ User type selection (buyer/vendor)

### User Management
- ✅ Create user profiles
- ✅ Store user-specific data
- ✅ Separate buyer and vendor profiles
- ✅ Profile updates

### Data Storage
- ✅ User profile data
- ✅ Business information for vendors
- ✅ Purchase history for buyers
- ✅ Preferences and settings

## Next Steps
1. Add product management for vendors
2. Implement order management
3. Add real-time chat functionality
4. Implement file storage for product images
5. Add push notifications

## Troubleshooting
- Make sure your project ID is correct
- Verify all collections are created with proper attributes
- Check permissions are set correctly
- Ensure your app has internet connectivity
