import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import 'buyer_dashboard.dart';
import 'vendor_dashboard.dart';

class AppwriteAuthScreen extends StatefulWidget {
  const AppwriteAuthScreen({super.key});

  @override
  _AppwriteAuthScreenState createState() => _AppwriteAuthScreenState();
}

class _AppwriteAuthScreenState extends State<AppwriteAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescController = TextEditingController();
  
  final _appwrite = AppwriteService();
  bool _isSignUp = false;
  bool _loading = false;
  String _userType = 'buyer'; // 'buyer' or 'vendor'

  @override
  void initState() {
    super.initState();
    _appwrite.init();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessNameController.dispose();
    _businessDescController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;
    
    print('Authentication started...');
    setState(() => _loading = true);
    try {
      if (_isSignUp) {
        print('Creating new account...');
        // Create account
        final user = await _appwrite.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
        print('User created: ${user.$id}');

        // Appwrite account creation does not automatically create a session.
        // Sign in first so database writes for profile creation are authorized.
        await _appwrite.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        print('Session created after signup');
        
        // Create user profile
        print('Creating user profile...');
        await _appwrite.createUserProfile(
          userId: user.$id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          userType: _userType,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          businessName: _userType == 'vendor' ? _businessNameController.text.trim() : null,
          businessDescription: _userType == 'vendor' ? _businessDescController.text.trim() : null,
        );
        print('Profile created successfully');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully! Please sign in.')),
          );
        }
        
        if (mounted) {
          setState(() => _isSignUp = false);
        }
      } else {
        print('Signing in...');
        // Sign in
        await _appwrite.signIn(_emailController.text.trim(), _passwordController.text);
        print('Sign in successful');
        
        // Get user profile and navigate
        final user = await _appwrite.getCurrentUser();
        print('Current user: ${user?.$id}');
        if (user != null) {
          final profile = await _appwrite.ensureUserProfiles(
            user: user,
            defaultUserType: 'buyer',
          );
          print('User profile: $profile');
          if (profile['userType'] == 'vendor') {
            final vendor = await _appwrite.getVendorProfile(user.$id);
            if (vendor != null && mounted) {
              print('Navigating to vendor dashboard');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => VendorDashboard(vendor: vendor)),
              );
            } else if (mounted) {
              Navigator.pushReplacementNamed(context, '/marketplace');
            }
          } else {
            final buyer = await _appwrite.getBuyerProfile(user.$id);
            if (buyer != null && mounted) {
              print('Navigating to buyer dashboard');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BuyerDashboard(buyer: buyer)),
              );
            } else if (mounted) {
              Navigator.pushReplacementNamed(context, '/marketplace');
            }
          }
        } else {
          throw Exception('Sign in failed. Please check your credentials and try again.');
        }
      }
    } catch (e) {
      print('Authentication error: $e');
      final error = e.toString().toLowerCase();
      if (_isSignUp && (error.contains('already') || error.contains('exists') || error.contains('409'))) {
        if (mounted) {
          setState(() => _isSignUp = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account already exists. Please sign in with your existing credentials.')),
          );
          setState(() => _loading = false);
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
    if (mounted) {
      setState(() => _loading = false);
    }
    print('Authentication completed');
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your email')),
                );
                return;
              }
              
              try {
                await _appwrite.account.createRecovery(
                  email: emailController.text.trim(),
                  url: 'https://smallvendors.app/reset-password',
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent! Check your email.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isSignUp ? 'Create Account' : 'Sign In'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.store,
                      size: 60,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSignUp ? 'Join Small Vendors' : 'Welcome Back',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp 
                        ? 'Create your account to start buying or selling'
                        : 'Sign in to your account',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // User Type Selection (only for sign up)
              if (_isSignUp) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'I want to:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Buy Products'),
                              subtitle: const Text('Browse and purchase'),
                              value: 'buyer',
                              groupValue: _userType,
                              onChanged: (value) => setState(() => _userType = value!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Sell Products'),
                              subtitle: const Text('Create a store'),
                              value: 'vendor',
                              groupValue: _userType,
                              onChanged: (value) => setState(() => _userType = value!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        if (!value!.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Password is required';
                        if (_isSignUp && value!.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone (Optional)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address (Optional)',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      if (_userType == 'vendor') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                            labelText: 'Business Name',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_userType == 'vendor' && (value?.isEmpty ?? true)) {
                              return 'Business name is required for vendors';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _businessDescController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Business Description (Optional)',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _loading ? null : _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _isSignUp ? 'Create Account' : 'Sign In',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
              ),
              
              const SizedBox(height: 16),
              
              // Forgot Password (only for sign in)
              if (!_isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              
              // Toggle Sign Up/Sign In
              TextButton(
                onPressed: () => setState(() {
                  _isSignUp = !_isSignUp;
                  _formKey.currentState?.reset();
                  _passwordController.clear();
                }),
                child: Text(
                  _isSignUp 
                    ? 'Already have an account? Sign In' 
                    : 'Don\'t have an account? Create one',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
