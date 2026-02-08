import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/vendor.dart';

// Business Profile Screen for editing vendor information

class BusinessProfileScreen extends StatefulWidget {
  final Vendor vendor;

  const BusinessProfileScreen({super.key, required this.vendor});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _storage = StorageService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _socialMediaController;
  String? _selectedSocialMedia;
  
  final List<String> _socialMediaOptions = [
    'WhatsApp',
    'Instagram', 
    'Facebook',
    'Twitter',
    'Telegram'
  ];

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.vendor.businessName);
    _ownerNameController = TextEditingController(text: widget.vendor.ownerName);
    _phoneController = TextEditingController(text: widget.vendor.phone);
    _locationController = TextEditingController(text: widget.vendor.location ?? '');
    _socialMediaController = TextEditingController();
    
    // Set existing social media if any
    if (widget.vendor.whatsapp != null) {
      _selectedSocialMedia = 'WhatsApp';
      _socialMediaController.text = widget.vendor.whatsapp!;
    } else if (widget.vendor.instagram != null) {
      _selectedSocialMedia = 'Instagram';
      _socialMediaController.text = widget.vendor.instagram!;
    } else if (widget.vendor.facebook != null) {
      _selectedSocialMedia = 'Facebook';
      _socialMediaController.text = widget.vendor.facebook!;
    } else if (widget.vendor.twitter != null) {
      _selectedSocialMedia = 'Twitter';
      _socialMediaController.text = widget.vendor.twitter!;
    } else if (widget.vendor.telegram != null) {
      _selectedSocialMedia = 'Telegram';
      _socialMediaController.text = widget.vendor.telegram!;
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _socialMediaController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedVendor = Vendor(
        id: widget.vendor.id,
        businessName: _businessNameController.text,
        ownerName: _ownerNameController.text,
        phone: _phoneController.text,
        businessType: widget.vendor.businessType,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        logoPath: widget.vendor.logoPath,
        whatsapp: _selectedSocialMedia == 'WhatsApp' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        instagram: _selectedSocialMedia == 'Instagram' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        facebook: _selectedSocialMedia == 'Facebook' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        twitter: _selectedSocialMedia == 'Twitter' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
        telegram: _selectedSocialMedia == 'Telegram' && _socialMediaController.text.isNotEmpty ? _socialMediaController.text : null,
      );

      try {
        await _storage.saveVendor(updatedVendor);
        
        // Update vendors list
        final vendors = await _storage.getVendors();
        final index = vendors.indexWhere((v) => v.id == updatedVendor.id);
        if (index != -1) {
          vendors[index] = updatedVendor;
          await _storage.saveVendors(vendors);
        }
        
        // Ensure current vendor is set
        await _storage.saveData('current_vendor', updatedVendor.id);
        
        if (mounted) {
          NotificationService.showSuccess(context, 'Profile updated successfully');
          Navigator.pop(context, updatedVendor);
        }
      } catch (e) {
        if (mounted) {
          NotificationService.showError(context, 'Failed to update profile: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
          ],
        ),
      ),
    );
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