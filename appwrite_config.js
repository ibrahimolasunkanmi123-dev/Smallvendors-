// Appwrite Configuration
// Copy your actual values from Appwrite Console and update appwrite_service.dart

const APPWRITE_CONFIG = {
  endpoint: 'https://cloud.appwrite.io/v1',
  projectId: 'YOUR_PROJECT_ID_HERE', // Get this from Appwrite Console
  databaseId: '699b24bd001c72ccf9b6',
  
  // Collections
  usersCollection: 'users',
  vendorsCollection: 'vendors', 
  buyersCollection: 'buyers',
  productsCollection: 'products', // For future use
  ordersCollection: 'orders', // For future use
};

// Steps to get your Project ID:
// 1. Go to https://cloud.appwrite.io
// 2. Create account or sign in
// 3. Create new project
// 4. Copy the Project ID from project settings
// 5. Update the projectId in lib/services/appwrite_service.dart
