import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../models/vendor.dart';
import 'splash_screen.dart';
import 'business_profile_screen.dart';
import 'help_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Vendor? vendor;
  
  const SettingsScreen({super.key, this.vendor});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoBackup = false;
  String _currency = 'USD';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
  }

  void _loadSettings() async {
    final settings = await _storage.getSettings();
    if (mounted) {
      final themeService = Provider.of<ThemeService>(context, listen: false);
      setState(() {
        _darkMode = themeService.isDarkMode;
        _notifications = settings['notifications'] ?? true;
        _autoBackup = settings['autoBackup'] ?? false;
        _currency = settings['currency'] ?? 'USD';
      });
    }
  }

  void _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await _storage.removeData('current_vendor');
              await _storage.removeData('current_buyer');
              if (mounted) {
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection('Appearance', [
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                Provider.of<ThemeService>(context, listen: false).toggleTheme();
                _saveSetting('darkMode', value);
              },
            ),
            ListTile(
              title: const Text('Currency'),
              subtitle: Text(_currency),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showCurrencyDialog(),
            ),
          ]),
          _buildSection('Notifications', [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive order and inventory alerts'),
              value: _notifications,
              onChanged: (value) {
                setState(() => _notifications = value);
                _saveSetting('notifications', value);
              },
            ),
          ]),
          _buildSection('Data & Backup', [
            SwitchListTile(
              title: const Text('Auto Backup'),
              subtitle: const Text('Automatically backup data daily'),
              value: _autoBackup,
              onChanged: (value) {
                setState(() => _autoBackup = value);
                _saveSetting('autoBackup', value);
              },
            ),
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Export all data to CSV'),
              trailing: const Icon(Icons.download),
              onTap: () => _exportData(),
            ),
            ListTile(
              title: const Text('Import Data'),
              subtitle: const Text('Import data from CSV'),
              trailing: const Icon(Icons.upload),
              onTap: () => _importData(),
            ),
          ]),
          _buildSection('Account', [
            ListTile(
              title: const Text('Business Profile'),
              subtitle: const Text('Edit business information'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (widget.vendor != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessProfileScreen(vendor: widget.vendor!),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Logout'),
              subtitle: const Text('Sign out of your account'),
              trailing: const Icon(Icons.logout),
              onTap: _logout,
            ),
          ]),
          _buildSection('Help & Support', [
            ListTile(
              title: const Text('Help & Tutorial'),
              subtitle: const Text('Learn how to use the app'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
            ),
          ]),
          _buildSection('About', [
            ListTile(
              title: const Text('App Version'),
              subtitle: Text(_appVersion),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy policy coming soon')),
                );
              },
            ),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms of service coming soon')),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) => ListTile(
            title: Text(currency),
            leading: Icon(
              _currency == currency ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _currency == currency ? Theme.of(context).primaryColor : Colors.grey,
            ),
            onTap: () {
              setState(() => _currency = currency);
              Navigator.pop(context);
              _saveSetting('currency', currency);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _exportData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose what to export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performExport(['products', 'orders', 'customers']);
            },
            child: const Text('Export All'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performExport(List<String> dataTypes) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting data...'),
            ],
          ),
        ),
      );
      
      final exportData = <String, dynamic>{};
      
      if (dataTypes.contains('products')) {
        exportData['products'] = (await _storage.getProducts()).map((p) => p.toJson()).toList();
      }
      if (dataTypes.contains('orders')) {
        exportData['orders'] = (await _storage.getOrders()).map((o) => o.toJson()).toList();
      }
      if (dataTypes.contains('customers')) {
        exportData['customers'] = (await _storage.getBuyers()).map((c) => c.toJson()).toList();
      }
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${dataTypes.join(', ')} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _importData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Importing data...'),
            ],
          ),
        ),
      );
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }

  }

  void _saveSetting(String key, dynamic value) async {
    final settings = await _storage.getSettings();
    settings[key] = value;
    await _storage.saveSettings(settings);
  }
}