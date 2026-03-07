import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'enhanced_profile_setup_screen.dart';

class EnhancedSignupScreen extends StatefulWidget {
  const EnhancedSignupScreen({super.key});

  @override
  State<EnhancedSignupScreen> createState() => _EnhancedSignupScreenState();
}

class _EnhancedSignupScreenState extends State<EnhancedSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _storage = StorageService();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isEmailSent = false;



  Future<void> _sendEmailVerification() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Send email verification link using Appwrite
      await _authService.resendEmailVerification(_emailController.text);
      setState(() => _isEmailSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent! Please check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isLoading = true);
    
    try {
      // Refresh session to check verification status
      await _authService.refreshSession();
      if (_authService.isEmailVerified) {
        await _proceedToProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please click the verification link in your email first')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification check failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  Future<void> _proceedToProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _storage.saveData('temp_user_id', user.id);
      await _storage.saveData('temp_email', _emailController.text);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EnhancedProfileSetupScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
              const Icon(Icons.person_add, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Create your account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Enter your email address to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const SizedBox(height: 24),
              
              // Email input
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
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
              
              if (_isEmailSent) ...[
                const SizedBox(height: 24),
                const Text(
                  'Check your email for the verification link and click it to verify your account.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_isEmailSent ? _checkEmailVerification : _sendEmailVerification),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEmailSent ? 'I\'ve Verified My Email' : 'Send Verification Email'),
                ),
              ),
              
              if (_isEmailSent) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _sendEmailVerification,
                  child: const Text('Resend Email'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
