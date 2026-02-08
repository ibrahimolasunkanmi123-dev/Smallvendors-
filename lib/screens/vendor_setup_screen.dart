import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/storage_service.dart';

class VendorSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const VendorSetupScreen({super.key, required this.onComplete});

  @override
  State<VendorSetupScreen> createState() => _VendorSetupScreenState();
}

class _VendorSetupScreenState extends State<VendorSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();

  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _socialMediaController = TextEditingController();
  final _storage = StorageService();
  String? _selectedSocialMedia;
  
  final List<String> _socialMediaOptions = [
    'WhatsApp',
    'Instagram', 
    'Facebook',
    'Twitter',
    'Telegram'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Business'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Business Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder()),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Owner Name', border: OutlineInputBorder()),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text('Contact & Social Media (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSocialMedia,
                decoration: const InputDecoration(
                  labelText: 'Social Media Platform (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.share),
                ),
                items: _socialMediaOptions.map((platform) => DropdownMenuItem(
                  value: platform,
                  child: Text(platform),
                )).toList(),
                onChanged: (value) => setState(() => _selectedSocialMedia = value),
              ),
              if (_selectedSocialMedia != null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _socialMediaController,
                  decoration: InputDecoration(
                    labelText: '$_selectedSocialMedia Handle/Link',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.link),
                    hintText: _getHintText(_selectedSocialMedia!),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveVendor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Save Business Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveVendor() async {
    if (_formKey.currentState!.validate()) {
      final vendor = Vendor(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessName: _businessNameController.text,
        ownerName: _ownerNameController.text,
        phone: '',
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        whatsapp: _selectedSocialMedia == 'WhatsApp' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        telegram: _selectedSocialMedia == 'Telegram' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        instagram: _selectedSocialMedia == 'Instagram' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        facebook: _selectedSocialMedia == 'Facebook' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        twitter: _selectedSocialMedia == 'Twitter' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
      );
      await _storage.saveVendor(vendor);
      widget.onComplete();
    }
  }
  
  String _getHintText(String platform) {
    switch (platform) {
      case 'WhatsApp':
        return '+1234567890';
      case 'Instagram':
        return '@username or instagram.com/username';
      case 'Facebook':
        return 'facebook.com/username';
      case 'Twitter':
        return '@username';
      case 'Telegram':
        return '@username';
      default:
        return '';
    }
  }
}