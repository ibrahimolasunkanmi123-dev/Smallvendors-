import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/vendor.dart';
import '../models/buyer.dart';
import 'enhanced_profile_screen.dart';
import 'auth_screen.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  final Vendor? vendor;
  final Buyer? buyer;

  const EnhancedSettingsScreen({
    super.key,
    this.vendor,
    this.buyer,
  });

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> {
  final _storage = StorageService();
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _orderAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final notifications = await _storage.getData('notifications_enabled');
    final emailNotifs = await _storage.getData('email_notifications');
    final orderAlerts = await _storage.getData('order_alerts');
    
    setState(() {
      _notificationsEnabled = notifications != 'false';
      _emailNotifications = emailNotifs != 'false';
      _orderAlerts = orderAlerts != 'false';
    });
  }

  void _saveSettings() async {
    await _storage.saveData('notifications_enabled', _notificationsEnabled.toString());
    await _storage.saveData('email_notifications', _emailNotifications.toString());
    await _storage.saveData('order_alerts', _orderAlerts.toString());
    
    if (mounted) {
      NotificationService.showSuccess(context, 'Settings saved successfully!');
    }
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.removeData('current_vendor');
      await _storage.removeData('current_buyer');
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  void _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your data including products, orders, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearAllData();
      if (mounted) {
        NotificationService.showSuccess(context, 'All data cleared successfully!');
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Account',
            children: [
              _buildListTile(
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Manage your profile information',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnhancedProfileScreen(
                      vendor: widget.vendor,
                      buyer: widget.buyer,
                    ),
                  ),
                ),
              ),
              _buildListTile(
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () => _showPrivacySettings(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSettings();
                },
              ),
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive email notifications',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                  _saveSettings();
                },
              ),
              _buildSwitchTile(
                icon: Icons.shopping_cart,
                title: 'Order Alerts',
                subtitle: 'Get notified about new orders',
                value: _orderAlerts,
                onChanged: (value) {
                  setState(() => _orderAlerts = value);
                  _saveSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Appearance',
            children: [
              Consumer<ThemeService>(
                builder: (context, themeService, child) => _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: themeService.isDarkMode,
                  onChanged: (value) => themeService.toggleTheme(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Support',
            children: [
              _buildListTile(
                icon: Icons.help,
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                onTap: () => _showHelpDialog(),
              ),
              _buildListTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts with us',
                onTap: () => _showFeedbackDialog(),
              ),
              _buildListTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Data',
            children: [
              _buildListTile(
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download your data',
                onTap: () => _exportData(),
              ),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Clear All Data',
                subtitle: 'Permanently delete all data',
                onTap: _clearData,
                textColor: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Account Actions',
            children: [
              _buildListTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: _logout,
                textColor: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Text('Privacy settings will be available in future updates.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Frequently Asked Questions:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Q: How do I add products?'),
              Text('A: Go to Products tab and tap the + button.'),
              SizedBox(height: 8),
              Text('Q: How do I manage orders?'),
              Text('A: Check the Orders tab to view and update order status.'),
              SizedBox(height: 8),
              Text('Q: How do I share my catalog?'),
              Text('A: Use the Share button in your catalog to generate QR codes or links.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share your thoughts, suggestions, or report issues...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              NotificationService.showSuccess(context, 'Thank you for your feedback!');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Small Vendors',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.store, size: 48, color: Colors.blue),
      children: [
        const Text('A digital catalog app for small businesses to showcase their products and manage orders efficiently.'),
      ],
    );
  }

  void _exportData() async {
    NotificationService.showInfo(context, 'Data export feature will be available in future updates.');
  }
}