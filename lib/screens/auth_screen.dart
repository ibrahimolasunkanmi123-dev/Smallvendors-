import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'main_dashboard.dart';
import 'enhanced_signup_screen.dart';
import 'buyer_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _businessNameController = TextEditingController();

  final _storage = StorageService();
  bool _isSignUp = false;
  bool _loading = false;

  void _signIn() async {
    if (_emailController.text.isEmpty) {
      NotificationService.showWarning(context, 'Please enter your email');
      return;
    }

    setState(() => _loading = true);

    try {
      final vendors = await _storage.getVendors();
      final existingVendor = vendors.where((v) => v.email == _emailController.text).isNotEmpty ? vendors.where((v) => v.email == _emailController.text).first : null;
      
      if (existingVendor != null) {
        await _storage.saveData('current_vendor', existingVendor.id);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainDashboard(vendor: existingVendor)),
          );
        }
      } else {
        setState(() => _isSignUp = true);
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, 'Sign in failed: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _signInAsBuyer() async {
    if (_emailController.text.isEmpty) {
      NotificationService.showWarning(context, 'Please enter your email');
      return;
    }

    setState(() => _loading = true);

    try {
      final buyers = await _storage.getBuyers();
      final existingBuyer = buyers.where((b) => b.email == _emailController.text).isNotEmpty ? buyers.where((b) => b.email == _emailController.text).first : null;
      
      if (existingBuyer != null) {
        await _storage.saveData('current_buyer', existingBuyer.id);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BuyerDashboard(buyer: existingBuyer)),
          );
        }
      } else {
        // Navigate to enhanced signup for new buyers
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EnhancedSignupScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, 'Sign in failed: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      
      try {
        final vendor = Vendor(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          businessName: _businessNameController.text,
          ownerName: _businessNameController.text,
          phone: '',
          email: _emailController.text,
        );

        await _storage.saveVendor(vendor);
        
        final vendors = await _storage.getVendors();
        if (!vendors.any((v) => v.id == vendor.id)) {
          vendors.add(vendor);
          await _storage.saveVendors(vendors);
        }
        await _storage.saveData('current_vendor', vendor.id);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainDashboard(vendor: vendor)),
          );
        }
      } catch (e) {
        if (mounted) {
          NotificationService.showError(context, 'Sign up failed: $e');
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                _isSignUp ? 'Create your account' : 'Welcome back!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              if (_isSignUp) const SizedBox(height: 16),
              if (_isSignUp) TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : (_isSignUp ? _signUp : _signIn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (_isSignUp) {
                    setState(() => _isSignUp = false);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EnhancedSignupScreen()),
                    );
                  }
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : 'New user? Sign Up',
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Or sign in as buyer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _signInAsBuyer,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Continue as Buyer'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}