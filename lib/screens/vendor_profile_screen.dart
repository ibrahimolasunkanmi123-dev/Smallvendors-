import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/buyer.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../services/storage_service.dart';
import '../services/chat_service.dart';
import 'product_detail_screen.dart';
import 'buyer_chat_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  final Vendor vendor;
  final Buyer buyer;

  const VendorProfileScreen({super.key, required this.vendor, required this.buyer});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _storage = StorageService();
  final _chatService = ChatService();
  List<Product> _vendorProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorProducts();
  }

  void _loadVendorProducts() async {
    final products = await _storage.getProducts();
    setState(() {
      _vendorProducts = products.where((p) => p.vendorId == widget.vendor.id).toList();
      _loading = false;
    });
  }

  void _startChat() async {
    final customer = Customer(
      id: widget.buyer.id,
      name: widget.buyer.name,
      phone: widget.buyer.phone,
      email: widget.buyer.email,
    );

    final chat = await _chatService.findOrCreateChat(
      widget.vendor.id,
      widget.buyer.id,
      widget.buyer.name,
      widget.buyer.phone,
      vendorName: widget.vendor.businessName,
    );

    if (mounted && chat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuyerChatScreen(
            customer: customer,
            vendor: widget.vendor,
            existingChat: chat,
          ),
        ),
      );
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchWhatsApp(String number) {
    _launchUrl('https://wa.me/$number');
  }

  void _launchTelegram(String username) {
    _launchUrl('https://t.me/$username');
  }

  void _launchInstagram(String username) {
    _launchUrl('https://instagram.com/$username');
  }

  void _launchFacebook(String username) {
    _launchUrl('https://facebook.com/$username');
  }

  void _launchTwitter(String username) {
    _launchUrl('https://twitter.com/$username');
  }

  void _launchEmail(String email) {
    _launchUrl('mailto:$email');
  }

  bool _hasSocialMedia() {
    return widget.vendor.whatsapp != null ||
           widget.vendor.telegram != null ||
           widget.vendor.instagram != null ||
           widget.vendor.facebook != null ||
           widget.vendor.twitter != null ||
           widget.vendor.email != null;
  }

  List<Widget> _buildSocialMediaButtons() {
    List<Widget> buttons = [];

    if (widget.vendor.whatsapp != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _launchWhatsApp(widget.vendor.whatsapp!),
          icon: const Icon(Icons.message, size: 16),
          label: const Text('WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (widget.vendor.telegram != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _launchTelegram(widget.vendor.telegram!),
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Telegram'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (widget.vendor.instagram != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _launchInstagram(widget.vendor.instagram!),
          icon: const Icon(Icons.camera_alt, size: 16),
          label: const Text('Instagram'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (widget.vendor.facebook != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _launchFacebook(widget.vendor.facebook!),
          icon: const Icon(Icons.facebook, size: 16),
          label: const Text('Facebook'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (widget.vendor.twitter != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _launchTwitter(widget.vendor.twitter!),
          icon: const Icon(Icons.alternate_email, size: 16),
          label: const Text('Twitter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (widget.vendor.email != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _launchEmail(widget.vendor.email!),
          icon: const Icon(Icons.email, size: 16),
          label: const Text('Email'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vendor.businessName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.vendor.businessName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('Owner: ${widget.vendor.ownerName}'),
                                    Text('Phone: ${widget.vendor.phone}'),
                                    if (widget.vendor.location != null)
                                      Text('Location: ${widget.vendor.location}'),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _startChat,
                                icon: const Icon(Icons.chat, color: Colors.white),
                                label: const Text('Chat', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_hasSocialMedia())
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Contact & Social Media:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _buildSocialMediaButtons(),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Products (${_vendorProducts.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _vendorProducts.length,
                    itemBuilder: (context, index) {
                      final product = _vendorProducts[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product, buyer: widget.buyer)),
                        ),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                  child: const Center(child: Icon(Icons.shopping_bag, size: 40)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}