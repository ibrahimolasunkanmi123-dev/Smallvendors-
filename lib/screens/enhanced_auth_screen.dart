import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'main_dashboard.dart';

class EnhancedAuthScreen extends StatefulWidget {
  const EnhancedAuthScreen({super.key});

  @override
  State<EnhancedAuthScreen> createState() => _EnhancedAuthScreenState();
}

class _EnhancedAuthScreenState extends State<EnhancedAuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();


  final _storage = StorageService();
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _loadRememberedCredentials();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadRememberedCredentials() async {
    final rememberedEmail = await _storage.getData('remembered_email');
    if (rememberedEmail != null) {
      _emailController.text = rememberedEmail;
      setState(() => _rememberMe = true);
    }
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final vendors = await _storage.getVendors();
      final existingVendor = vendors.where((v) => v.email == _emailController.text).isNotEmpty ? vendors.where((v) => v.email == _emailController.text).first : null;
      
      if (existingVendor != null) {
        // Validate password
        final storedPassword = await _storage.getData('vendor_password_${existingVendor.id}');
        if (storedPassword == _passwordController.text) {
          if (_rememberMe) {
            await _storage.saveData('remembered_email', _emailController.text);
          }
          
          await _storage.saveData('current_vendor', existingVendor.id);
          if (mounted) {
            _showSuccessSnackBar('Welcome back, ${existingVendor.businessName}!');
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainDashboard(vendor: existingVendor)),
              );
            }
          }
        } else {
          _showInfoSnackBar('Invalid password. Please try again.');
        }
      } else {
        setState(() => _isSignUp = true);
        _showInfoSnackBar('Account not found. Please sign up.');
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
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      final vendors = await _storage.getVendors();
      if (vendors.any((v) => v.email == _emailController.text)) {
        NotificationService.showWarning(context, 'Email already registered. Please sign in.');
        setState(() => _isSignUp = false);
        return;
      }
      
      final vendor = Vendor(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessName: _businessNameController.text,
        ownerName: _businessNameController.text,
        phone: '', // Phone can be added later in profile setup
        email: _emailController.text,
      );
      
      // Store password separately for authentication
      await _storage.saveData('vendor_password_${vendor.id}', _passwordController.text);

      await _storage.saveVendor(vendor);
      
      if (!vendors.any((v) => v.id == vendor.id)) {
        vendors.add(vendor);
        await _storage.saveVendors(vendors);
      }
      
      if (_rememberMe) {
        await _storage.saveData('remembered_email', _emailController.text);
      }
      
      await _storage.saveData('current_vendor', vendor.id);
      
      if (mounted) {
        _showSuccessSnackBar('Account created successfully! Welcome to Small Vendors.');
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

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text('Password reset functionality will be implemented in a future update. Please contact support for assistance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.store, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Small Vendors',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp ? 'Create your vendor account' : 'Welcome back!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Password is required';
                        if (_isSignUp && v!.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: InputDecoration(
                          labelText: 'Business Name',
                          hintText: 'Enter your business name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.business_outlined),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) => v?.isEmpty == true ? 'Business name is required' : null,
                      ),

                    ],
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) => setState(() => _rememberMe = value ?? false),
                        ),
                        const Text('Remember me'),
                        const Spacer(),
                        if (!_isSignUp)
                          TextButton(
                            onPressed: _forgotPassword,
                            child: const Text('Forgot Password?'),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _loading ? null : (_isSignUp ? _signUp : _signIn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'Create Account' : 'Sign In',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _isSignUp = !_isSignUp;
                            _passwordController.clear();
                            _businessNameController.clear();

                          }),
                          child: Text(
                            _isSignUp ? 'Sign In' : 'Sign Up',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
