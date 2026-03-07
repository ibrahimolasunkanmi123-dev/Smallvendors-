import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../services/storage_service.dart';
import 'buyer_login_screen.dart';
import 'buyer_order_history_screen.dart';
import 'buyer_profile_screen.dart';
import 'notifications_screen.dart';

class BuyerAccountScreen extends StatelessWidget {
  final Buyer? buyer;

  const BuyerAccountScreen({super.key, this.buyer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          if (buyer != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      buyer!.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    buyer!.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    buyer!.email ?? 'No email',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (buyer != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuyerProfileScreen(buyer: buyer!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Addresses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Order History'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (buyer != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuyerOrderHistoryScreen(buyer: buyer!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Methods'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (buyer != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(userId: buyer!.id),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Track Current Order'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (buyer != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuyerOrderHistoryScreen(buyer: buyer!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final storage = StorageService();
              await storage.clearAll();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyerLoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
