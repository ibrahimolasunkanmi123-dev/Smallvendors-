import 'lib/services/appwrite_service.dart';

void main() async {
  print('Testing Appwrite connection...');
  
  final appwrite = AppwriteService();
  appwrite.init();
  
  try {
    // Test basic connection
    final user = await appwrite.getCurrentUser();
    print('Current user: $user');
    
    print('Appwrite connection test completed successfully!');
  } catch (e) {
    print('Appwrite connection error: $e');
  }
}