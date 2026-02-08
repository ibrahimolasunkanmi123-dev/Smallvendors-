import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../models/buyer.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class EnhancedProfileScreen extends StatefulWidget {
  final Vendor? vendor;
  final Buyer? buyer;

  const EnhancedProfileScreen({
    super.key,
    this.vendor,
    this.buyer,
  });

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _businessTypeController;
  
  bool _loading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.vendor != null) {
      _nameController = TextEditingController(text: widget.vendor!.businessName);
      _emailController = TextEditingController(text: widget.vendor!.email ?? '');
      _phoneController = TextEditingController(text: widget.vendor!.phone);
      _addressController = TextEditingController(text: widget.vendor!.location ?? '');
      _businessTypeController = TextEditingController(text: widget.vendor!.businessType);
    } else if (widget.buyer != null) {
      _nameController = TextEditingController(text: widget.buyer!.name);
      _emailController = TextEditingController(text: widget.buyer!.email ?? '');
      _phoneController = TextEditingController(text: widget.buyer!.phone ?? '');
      _addressController = TextEditingController(text: widget.buyer!.address ?? '');
      _businessTypeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessTypeController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (widget.vendor != null) {
        await _saveVendorProfile();
      } else if (widget.buyer != null) {
        await _saveBuyerProfile();
      }
      
      setState(() => _isEditing = false);
      if (mounted) {
        NotificationService.showSuccess(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, 'Failed to update profile: $e');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveVendorProfile() async {
    final updatedVendor = Vendor(
      id: widget.vendor!.id,
      businessName: _nameController.text,
      ownerName: widget.vendor!.ownerName,
      phone: _phoneController.text,
      email: _emailController.text,
      businessType: _businessTypeController.text,
      location: _addressController.text,
      logoPath: widget.vendor!.logoPath,
      rating: widget.vendor!.rating,
      totalReviews: widget.vendor!.totalReviews,
      totalTransactions: widget.vendor!.totalTransactions,
      whatsapp: widget.vendor!.whatsapp,
      telegram: widget.vendor!.telegram,
      instagram: widget.vendor!.instagram,
      facebook: widget.vendor!.facebook,
      twitter: widget.vendor!.twitter,
    );

    await _storage.saveVendor(updatedVendor);
    
    final vendors = await _storage.getVendors();
    final index = vendors.indexWhere((v) => v.id == widget.vendor!.id);
    if (index != -1) {
      vendors[index] = updatedVendor;
      await _storage.saveVendors(vendors);
    }
  }

  Future<void> _saveBuyerProfile() async {
    final updatedBuyer = widget.buyer!.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );

    final buyers = await _storage.getBuyers();
    final index = buyers.indexWhere((b) => b.id == widget.buyer!.id);
    if (index != -1) {
      buyers[index] = updatedBuyer;
      await _storage.saveBuyers(buyers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _loading ? null : _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfileForm(),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              widget.vendor != null ? Icons.store : Icons.person,
              size: 50,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.vendor?.businessName ?? widget.buyer?.name ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.vendor != null ? 'Vendor Account' : 'Buyer Account',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _nameController,
          label: widget.vendor != null ? 'Business Name' : 'Full Name',
          icon: widget.vendor != null ? Icons.business : Icons.person,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          enabled: _isEditing,
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
        _buildFormField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _addressController,
          label: widget.vendor != null ? 'Business Location' : 'Address',
          icon: Icons.location_on,
          enabled: _isEditing,
          maxLines: 2,
        ),
        if (widget.vendor != null) ...[
          const SizedBox(height: 16),
          _buildFormField(
            controller: _businessTypeController,
            label: 'Business Type',
            icon: Icons.category,
            enabled: _isEditing,
          ),
        ],
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator ?? (v) => v?.isEmpty == true ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _loading ? null : () {
              setState(() => _isEditing = false);
              _initializeControllers();
            },
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _loading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }
}