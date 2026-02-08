import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Tutorial'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildSection(
            'Getting Started',
            Icons.rocket_launch,
            Colors.blue,
            [
              _buildHelpItem('1. Set up your business profile', 'Add your business name, contact info, and description'),
              _buildHelpItem('2. Add your first product', 'Include photos, prices, and descriptions'),
              _buildHelpItem('3. Share your catalog', 'Use QR codes or direct links to share with customers'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Managing Products',
            Icons.inventory,
            Colors.green,
            [
              _buildHelpItem('Add Products', 'Tap the + button to add new products with photos and details'),
              _buildHelpItem('Edit Products', 'Long press any product to edit or delete it'),
              _buildHelpItem('Stock Management', 'Set stock levels and get low stock alerts'),
              _buildHelpItem('Categories', 'Organize products into categories for easy browsing'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Order Management',
            Icons.receipt_long,
            Colors.orange,
            [
              _buildHelpItem('View Orders', 'See all customer orders in the Orders tab'),
              _buildHelpItem('Update Status', 'Change order status from pending to delivered'),
              _buildHelpItem('Contact Customers', 'Call or message customers directly from orders'),
              _buildHelpItem('Order History', 'Track all completed and cancelled orders'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Analytics & Reports',
            Icons.analytics,
            Colors.purple,
            [
              _buildHelpItem('Revenue Tracking', 'Monitor daily, weekly, and monthly sales'),
              _buildHelpItem('Top Products', 'See which products are selling best'),
              _buildHelpItem('Customer Insights', 'Track customer orders and preferences'),
              _buildHelpItem('Export Data', 'Download reports for external analysis'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Sharing Your Catalog',
            Icons.share,
            Colors.teal,
            [
              _buildHelpItem('QR Code', 'Generate QR codes for easy catalog sharing'),
              _buildHelpItem('WhatsApp Integration', 'Share products directly via WhatsApp'),
              _buildHelpItem('Public Link', 'Get a shareable link to your catalog'),
              _buildHelpItem('Social Media', 'Share individual products on social platforms'),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipsCard(),
          const SizedBox(height: 20),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Welcome to Small Vendors!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This guide will help you get the most out of your digital catalog. Learn how to manage products, track orders, and grow your business.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> items) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: items,
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description),
      dense: true,
    );
  }

  Widget _buildTipsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Pro Tips',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('Use high-quality photos to showcase your products'),
            _buildTip('Keep product descriptions clear and detailed'),
            _buildTip('Update stock levels regularly to avoid overselling'),
            _buildTip('Respond to customer inquiries quickly'),
            _buildTip('Use analytics to identify your best-selling products'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, color: Colors.amber.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.support_agent, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Need More Help?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'If you have questions or need assistance, we\'re here to help!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Email Support'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      
                    },
                    icon: const Icon(Icons.quiz),
                    label: const Text('FAQ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}