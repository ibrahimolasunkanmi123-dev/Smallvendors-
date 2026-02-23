import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../services/appwrite_service.dart';
import 'buyer_dashboard.dart';
import 'vendor_dashboard.dart';
import 'onboarding_screen.dart';
import 'public_marketplace.dart';

extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = StorageService();
  final _appwrite = AppwriteService();

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  void _checkLoginState() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    try {
      // Initialize Appwrite
      _appwrite.init();
      
      // Check Appwrite authentication first
      final appwriteUser = await _appwrite.getCurrentUser();
      if (appwriteUser != null) {
        final profile = await _appwrite.getUserProfile(appwriteUser.$id);
        if (profile != null && mounted) {
          if (profile['userType'] == 'vendor') {
            final vendor = await _appwrite.getVendorProfile(appwriteUser.$id);
            if (vendor != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => VendorDashboard(vendor: vendor)),
              );
              return;
            }
          } else {
            final buyer = await _appwrite.getBuyerProfile(appwriteUser.$id);
            if (buyer != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BuyerDashboard(buyer: buyer)),
              );
              return;
            }
          }
        }
      }
    } catch (e) {
      print('Authentication check error: $e');
    }
    
    // If no user is logged in, go to authentication screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/appwrite-auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.store,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Small Vendors',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover Amazing Products Now!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
