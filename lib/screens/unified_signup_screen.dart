import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';

import 'buyer_dashboard.dart';

class UnifiedSignupScreen extends StatefulWidget {
  const UnifiedSignupScreen({super.key});

  @override
  State<UnifiedSignupScreen> createState() => _UnifiedSignupScreenState();
}

class _UnifiedSignupScreenState extends State<UnifiedSignupScreen> {
  final PageController _pageController = PageController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();

  final _locationService = LocationService();
  
  bool _isLoading = false;
  String? _profileImagePath;
  String _location = 'Detecting location...';
  bool _locationDetected = false;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _autoDetectLocation();
  }

  Future<void> _autoDetectLocation() async {
    final location = await _locationService.getCurrentLocation();
    setState(() {
      _location = location;
      _locationDetected = !location.contains('denied') && 
                         !location.contains('disabled') && 
                         !location.contains('Unable');
    });
  }

  Future<void> _sendEmailVerification() async {
    if (_emailController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _authService.resendEmailVerification(_emailController.text);
      // Email sent successfully
      _nextPage();
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.refreshSession();
      if (_authService.isEmailVerified) {
        _nextPage();
      } else {
        _showError('Please click the verification link in your email first');
      }
    } catch (e) {
      _showError('Verification check failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }



  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImagePath = image.path);
    }
  }

  Future<void> _completeSignup() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final buyer = await _authService.createUserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text,
        profileImage: _profileImagePath,
        location: _location,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BuyerDashboard(buyer: buyer)),
        );
      }
    } catch (e) {
      _showError('Failed to create profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentPage ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildContactPage(),
                _buildVerificationPage(),
                _buildProfilePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Enter your contact info',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Enter your email address to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
          const SizedBox(height: 24),
          
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendEmailVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.email,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Check your email',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'We sent a verification link to ${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _checkEmailVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('I\'ve verified my email'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Complete your profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          // Profile Picture
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: _profileImagePath != null
                ? ClipOval(
                    child: Image.file(
                      File(_profileImagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Add Photo', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Name Input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 24),
          
          // Location Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: _locationDetected ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Location (Auto-detected)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (_locationDetected)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _location,
                  style: TextStyle(
                    fontSize: 14,
                    color: _locationDetected ? Colors.black87 : Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _autoDetectLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Location'),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Complete Signup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}