import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/supabase_service.dart';
import 'services/sample_data_service.dart';
import 'services/appwrite_service.dart';
import 'screens/splash_screen.dart';
import 'screens/public_marketplace.dart';
import 'screens/onboarding_screen.dart';
import 'screens/unified_auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/appwrite_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Appwrite
    AppwriteService().init();
    print('Appwrite initialized successfully');
    
    // Initialize other services
    await SupabaseService.initialize();
    await SampleDataService.initializeSampleData();
  } catch (e) {
    print('Initialization error: $e');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const SmallVendorsApp(),
    ),
  );
}

class SmallVendorsApp extends StatelessWidget {
  const SmallVendorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Small Vendors',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            '/marketplace': (context) => const PublicMarketplace(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/auth': (context) => const UnifiedAuthScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/appwrite-auth': (context) => const AppwriteAuthScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}