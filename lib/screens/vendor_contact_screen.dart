import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vendor.dart';
import 'chat_screen.dart';

class VendorContactScreen extends StatelessWidget {
  final Vendor vendor;

  const VendorContactScreen({super.key, required this.vendor});

  void _launchWhatsApp() async {
    final message = 'Hi ${vendor.businessName}, I found you on SmallVendors app and would like to inquire about your products.';
    final url = 'https://wa.me/${vendor.phone.replaceAll(RegExp(r'[^\d]'), '')}?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _makePhoneCall() async {
    final url = 'tel:${vendor.phone}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact ${vendor.businessName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.store, size: 30, color: Colors.blue[600]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.businessName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            vendor.ownerName,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (vendor.businessType.isNotEmpty)
                            Text(
                              vendor.businessType,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(' ${vendor.rating.toStringAsFixed(1)} (${vendor.totalReviews} reviews)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Contact Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // WhatsApp Contact
            _buildContactOption(
              icon: Icons.chat,
              title: 'WhatsApp',
              subtitle: 'Send a message on WhatsApp',
              color: Colors.green,
              onTap: _launchWhatsApp,
            ),
            
            // Phone Call
            _buildContactOption(
              icon: Icons.phone,
              title: 'Phone Call',
              subtitle: vendor.phone,
              color: Colors.blue,
              onTap: _makePhoneCall,
            ),
            
            // In-App Message
            _buildContactOption(
              icon: Icons.message,
              title: 'In-App Message',
              subtitle: 'Send a message within the app',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Business Hours (if available)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (vendor.location != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(vendor.location!)),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.business, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('${vendor.totalTransactions} completed transactions'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}