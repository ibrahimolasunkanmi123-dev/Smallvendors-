import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import 'splash_screen.dart';
import 'add_product_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'analytics_screen.dart';
import 'business_profile_screen.dart';

class VendorDashboard extends StatefulWidget {
  final Vendor vendor;

  const VendorDashboard({super.key, required this.vendor});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final _storage = StorageService();
  List<Product> _products = [];
  int _totalOrders = 0;
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    final allProducts = await _storage.getProducts();
    final vendorProducts = allProducts.where((p) => p.vendorId == widget.vendor.id).toList();
    setState(() {
      _products = vendorProducts;
      _totalOrders = 12; // Mock data
      _totalRevenue = 1250.50; // Mock data
    });
  }

  void _shareWhatsApp() async {
    final url = 'https://wa.me/?text=Check out my catalog: ${_getCatalogUrl()}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Your Catalog',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.blue),
              title: const Text('Show QR Code'),
              subtitle: const Text('Let customers scan to view catalog'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.green),
              title: const Text('Copy Link'),
              subtitle: const Text('Share catalog link directly'),
              onTap: () {
                Navigator.pop(context);
                _copyLink();
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.orange),
              title: const Text('Share via WhatsApp'),
              subtitle: const Text('Send catalog to WhatsApp contacts'),
              onTap: () {
                Navigator.pop(context);
                _shareWhatsApp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catalog QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 100, color: Colors.grey),
                    Text('QR Code Here', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Customers can scan this QR code to view your catalog',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: _copyLink,
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  void _copyLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Catalog link copied: ${_getCatalogUrl()}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getCatalogUrl() {
    return 'https://smallvendors.app/catalog/${widget.vendor.id}';
  }

  void _logout() async {
    await _storage.clearAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payment Integration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.blue),
              title: const Text('Flutterwave'),
              subtitle: const Text('Accept card payments'),
              onTap: () => _integratePayment('flutterwave'),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.green),
              title: const Text('Paystack'),
              subtitle: const Text('Nigerian payment gateway'),
              onTap: () => _integratePayment('paystack'),
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining, color: Colors.orange),
              title: const Text('Delivery Partners'),
              subtitle: const Text('Connect with delivery services'),
              onTap: () => _integrateDelivery(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromotionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Promote Your Business',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Featured Listing'),
              subtitle: const Text('\$5/month - Top search results'),
              onTap: () => _purchasePromotion('featured'),
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: Colors.red),
              title: const Text('Banner Ad'),
              subtitle: const Text('\$10/month - Homepage banner'),
              onTap: () => _purchasePromotion('banner'),
            ),
            ListTile(
              leading: const Icon(Icons.verified, color: Colors.blue),
              title: const Text('Verification Badge'),
              subtitle: const Text('\$2/month - Trusted vendor badge'),
              onTap: () => _purchaseVerification(),
            ),
          ],
        ),
      ),
    );
  }

  void _integratePayment(String provider) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Integrating with $provider...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _integrateDelivery() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting with delivery partners...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _purchasePromotion(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchasing $type promotion...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _purchaseVerification() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Verified'),
        content: const Text(
          'Verification badge helps customers trust your business.\n\n'
          'Benefits:\n'
          '• Increased visibility\n'
          '• Customer trust\n'
          '• Priority support\n\n'
          'Cost: \$2/month',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verification process started!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Get Verified'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vendor.businessName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWhatsApp,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BusinessProfileScreen(vendor: widget.vendor),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.business, size: 16),
                    SizedBox(width: 8),
                    Text('Business Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 16),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
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
                    const Text(
                      'Welcome back!',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      widget.vendor.ownerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.vendor.businessName,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Verification Status Banner
            _buildVerificationBanner(),
            const SizedBox(height: 16),
            
            // Ad Placement
            _buildAdBanner(),
            const SizedBox(height: 20),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Products',
                    '${_products.length}',
                    Icons.inventory,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Orders',
                    '$_totalOrders',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Revenue',
                    '\$${_totalRevenue.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildActionCard(
                  'Manage Products',
                  Icons.inventory_2,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  'View Orders',
                  Icons.receipt_long,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  'Analytics',
                  Icons.analytics,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnalyticsScreen(),
                    ),
                  ),
                ),
                _buildActionCard(
                  'Share Catalog',
                  Icons.qr_code,
                  Colors.orange,
                  _showShareOptions,
                ),
                _buildActionCard(
                  'Payments',
                  Icons.payment,
                  Colors.teal,
                  _showPaymentOptions,
                ),
                _buildActionCard(
                  'Promote',
                  Icons.campaign,
                  Colors.pink,
                  _showPromotionOptions,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductScreen(vendorId: widget.vendor.id)),
          );
          _loadDashboardData();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    return Card(
      color: Colors.amber.shade50,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.amber.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Verified',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const Text(
                    'Boost customer trust with verification badge',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _purchaseVerification,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    return Card(
      elevation: 2,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.pink.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 8,
              right: 8,
              child: Text(
                'Ad',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, color: Colors.purple.shade600, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Special Offer: 20% Off Delivery',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  Text(
                    'Partner with local delivery services',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}