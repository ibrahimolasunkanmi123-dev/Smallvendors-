import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/buyer.dart';
import '../models/vendor.dart';
import 'buyer_main_screen.dart';
import 'main_dashboard.dart';

class UnifiedAuthScreen extends StatefulWidget {
  const UnifiedAuthScreen({super.key});

  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  
  final _authService = AuthService();
  final _storage = StorageService();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isBuyer = true;
  
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (_isLogin) {
        await _handleLogin();
      } else {
        await _handleSignup();
      }
    } catch (e) {
      _showError('Authentication failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    
    // Try local storage first
    if (_isBuyer) {
      final buyers = await _storage.getBuyers();
      final buyer = buyers.where((b) => b.email == email).firstOrNull;
      if (buyer != null) {
        await _storage.saveData('current_buyer', buyer.id);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BuyerMainScreen(buyer: buyer)),
          );
        }
        return;
      }
    } else {
      final vendors = await _storage.getVendors();
      final vendor = vendors.where((v) => v.email == email).firstOrNull;
      if (vendor != null) {
        await _storage.saveData('current_vendor', vendor.id);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainDashboard(vendor: vendor)),
          );
        }
        return;
      }
    }
    
    // Try Supabase authentication
    try {
      final response = await _authService.signInWithEmail(email, _passwordController.text);
      if (response.user != null) {
        final profile = await _authService.getUserProfile();
        if (profile != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BuyerMainScreen(buyer: profile)),
          );
        }
      }
    } catch (e) {
      // If login fails, suggest signup
      _showError('Account not found. Please sign up first.');
      setState(() => _isLogin = false);
    }
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    
    if (_isBuyer) {
      // Create buyer account
      final buyer = Buyer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: email,
        phone: '',
        address: '',
      );
      
      await _storage.saveBuyer(buyer);
      final buyers = await _storage.getBuyers();
      if (!buyers.any((b) => b.id == buyer.id)) {
        buyers.add(buyer);
        await _storage.saveBuyers(buyers);
      }
      await _storage.saveData('current_buyer', buyer.id);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BuyerMainScreen(buyer: buyer)),
        );
      }
    } else {
      // Create vendor account
      final vendor = Vendor(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessName: _businessNameController.text.trim(),
        ownerName: _nameController.text.trim(),
        phone: '',
        email: email,
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
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildUserTypeSelector(),
                const SizedBox(height: 24),
                _buildAuthToggle(),
                const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 32),
                _buildAuthButton(),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.store, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Small Vendors',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin ? 'Welcome back!' : 'Join our marketplace',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() => _isBuyer = index == 0),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade600,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: const [
          Tab(
            icon: Icon(Icons.shopping_cart),
            text: 'Buyer',
          ),
          Tab(
            icon: Icon(Icons.store),
            text: 'Vendor',
          ),
        ],
      ),
    );
  }

  Widget _buildAuthToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => setState(() => _isLogin = true),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: _isLogin ? Colors.blue.shade600 : Colors.grey.shade600,
              fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 20,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        TextButton(
          onPressed: () => setState(() => _isLogin = false),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: !_isLogin ? Colors.blue.shade600 : Colors.grey.shade600,
              fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin) ...[
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            if (!_isBuyer) ...[
              _buildTextField(
                controller: _businessNameController,
                label: 'Business Name',
                icon: Icons.business_outlined,
                validator: (v) => v?.trim().isEmpty == true ? 'Business name is required' : null,
              ),
              const SizedBox(height: 16),
            ],
          ],
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v?.trim().isEmpty == true) return 'Email is required';
              if (!RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$').hasMatch(v!)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            validator: (v) {
              if (v?.isEmpty == true) return 'Password is required';
              if (!_isLogin && v!.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isLogin ? 'Sign In' : 'Create Account',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/marketplace'),
                icon: const Icon(Icons.explore),
                label: const Text('Browse Products'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  side: BorderSide(color: Colors.blue.shade600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLogin = false;
                    _isBuyer = false;
                  });
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.business),
                label: const Text('Start Selling'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  side: BorderSide(color: Colors.green.shade600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}