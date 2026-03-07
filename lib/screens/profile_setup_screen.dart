import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../models/buyer.dart';
import 'buyer_dashboard.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String phone;
  
  const ProfileSetupScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.phone,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();

  final _locationService = LocationService();
  String? _profileImage;
  String _location = 'Detecting location...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    final location = await _locationService.getCurrentLocation();
    setState(() => _location = location);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = image.path);
    }
  }

  Future<void> _completeProfile() async {
    if (_nameController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    final buyer = Buyer(
      id: widget.userId,
      name: _nameController.text,
      email: widget.email,
      phone: widget.phone,
      profileImage: _profileImage,
      location: _location,
    );
    
    await StorageService().saveBuyer(buyer);
    final savedBuyer = buyer;
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BuyerDashboard(buyer: savedBuyer)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile setup failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null 
                  ? AssetImage(_profileImage!) 
                  : null,
                child: _profileImage == null 
                  ? const Icon(Icons.add_a_photo, size: 30)
                  : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(_location),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _detectLocation,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeProfile,
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Complete Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
