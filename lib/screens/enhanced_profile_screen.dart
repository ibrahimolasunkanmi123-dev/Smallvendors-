import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final _imagePicker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _businessTypeController;
  late TextEditingController _whatsappController;
  late TextEditingController _telegramController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  late TextEditingController _twitterController;
  
  bool _loading = false;
  bool _isEditing = false;
  String? _selectedImagePath;

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
      _whatsappController = TextEditingController(text: widget.vendor!.whatsapp ?? '');
      _telegramController = TextEditingController(text: widget.vendor!.telegram ?? '');
      _instagramController = TextEditingController(text: widget.vendor!.instagram ?? '');
      _facebookController = TextEditingController(text: widget.vendor!.facebook ?? '');
      _twitterController = TextEditingController(text: widget.vendor!.twitter ?? '');
      _selectedImagePath = widget.vendor!.logoPath;
    } else if (widget.buyer != null) {
      _nameController = TextEditingController(text: widget.buyer!.name);
      _emailController = TextEditingController(text: widget.buyer!.email ?? '');
      _phoneController = TextEditingController(text: widget.buyer!.phone ?? '');
      _addressController = TextEditingController(text: widget.buyer!.address ?? '');
      _businessTypeController = TextEditingController();
      _whatsappController = TextEditingController();
      _telegramController = TextEditingController();
      _instagramController = TextEditingController();
      _facebookController = TextEditingController();
      _twitterController = TextEditingController();
      _selectedImagePath = widget.buyer!.profileImage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessTypeController.dispose();
    _whatsappController.dispose();
    _telegramController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
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
      logoPath: _selectedImagePath,
      rating: widget.vendor!.rating,
      totalReviews: widget.vendor!.totalReviews,
      totalTransactions: widget.vendor!.totalTransactions,
      whatsapp: _whatsappController.text.isEmpty ? null : _whatsappController.text,
      telegram: _telegramController.text.isEmpty ? null : _telegramController.text,
      instagram: _instagramController.text.isEmpty ? null : _instagramController.text,
      facebook: _facebookController.text.isEmpty ? null : _facebookController.text,
      twitter: _twitterController.text.isEmpty ? null : _twitterController.text,
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
      profileImage: _selectedImagePath,
    );

    final buyers = await _storage.getBuyers();
    final index = buyers.indexWhere((b) => b.id == widget.buyer!.id);
    if (index != -1) {
      buyers[index] = updatedBuyer;
      await _storage.saveBuyers(buyers);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.vendor != null ? 3 : 2,
      child: Scaffold(
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
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              const Tab(icon: Icon(Icons.person), text: 'Basic Info'),
              if (widget.vendor != null) const Tab(icon: Icon(Icons.share), text: 'Social'),
              const Tab(icon: Icon(Icons.analytics), text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBasicInfoTab(),
            if (widget.vendor != null) _buildSocialMediaTab(),
            _buildStatsTab(),
          ],
        ),
      ),
    );
  }



  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildSocialMediaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Social Media Links',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSocialMediaForm(),
          if (_isEditing) ...[
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
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
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: _selectedImagePath != null && _selectedImagePath!.isNotEmpty
                    ? (_selectedImagePath!.startsWith('http')
                        ? NetworkImage(_selectedImagePath!)
                        : FileImage(File(_selectedImagePath!))) as ImageProvider
                    : null,
                child: _selectedImagePath == null || _selectedImagePath!.isEmpty
                    ? Icon(
                        widget.vendor != null ? Icons.store : Icons.person,
                        size: 50,
                        color: Colors.blue,
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
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
          if (widget.vendor != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${widget.vendor!.rating.toStringAsFixed(1)} (${widget.vendor!.totalReviews} reviews)',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialMediaForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _whatsappController,
          label: 'WhatsApp',
          icon: Icons.phone,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _telegramController,
          label: 'Telegram',
          icon: Icons.telegram,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _instagramController,
          label: 'Instagram',
          icon: Icons.camera_alt,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _facebookController,
          label: 'Facebook',
          icon: Icons.facebook,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _twitterController,
          label: 'Twitter',
          icon: Icons.alternate_email,
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    if (widget.vendor != null) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Rating',
                  widget.vendor!.rating.toStringAsFixed(1),
                  Icons.star,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Reviews',
                  '${widget.vendor!.totalReviews}',
                  Icons.rate_review,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Transactions',
                  '${widget.vendor!.totalTransactions}',
                  Icons.receipt,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Member Since',
                  'Jan 2024',
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Orders',
                  '12',
                  Icons.shopping_bag,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Wishlist',
                  '8',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Reviews Given',
                  '5',
                  Icons.rate_review,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Member Since',
                  widget.buyer?.createdAt.year.toString() ?? '2024',
                  Icons.calendar_today,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildQuickActionButton(
              'Change Password',
              Icons.lock,
              Colors.orange,
              () => _showChangePasswordDialog(),
            ),
            _buildQuickActionButton(
              'Privacy Settings',
              Icons.privacy_tip,
              Colors.purple,
              () => _showPrivacySettings(),
            ),
            _buildQuickActionButton(
              'Backup Data',
              Icons.backup,
              Colors.green,
              () => _backupData(),
            ),
            _buildQuickActionButton(
              'Help & Support',
              Icons.help,
              Colors.blue,
              () => _showHelpSupport(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Privacy settings will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _backupData() {
    NotificationService.showSuccess(context, 'Data backup initiated!');
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('Contact support at support@smallvendors.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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