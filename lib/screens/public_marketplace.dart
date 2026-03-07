import 'dart:async';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import '../services/storage_service.dart';
import '../widgets/safe_image.dart';

class PublicMarketplace extends StatefulWidget {
  const PublicMarketplace({super.key});

  @override
  State<PublicMarketplace> createState() => _PublicMarketplaceState();
}

class _PublicMarketplaceState extends State<PublicMarketplace> {
  static const Color _blue = Color(0xFF1565C0);
  static const Color _blueDark = Color(0xFF0D47A1);
  static const Color _blueLight = Color(0xFF42A5F5);

  final _storage = StorageService();
  final _searchController = TextEditingController();
  final _campaignController = PageController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Vendor> _vendors = [];
  final Set<String> _wishlistIds = {};
  final Map<String, int> _cart = {};
  final List<_RealtimeNotification> _notifications = [];

  bool _loading = true;
  bool _isDarkMode = false;
  int _tab = 0;
  int _campaignIndex = 0;
  int _unreadNotifications = 0;
  String _selectedCategory = 'All';

  Timer? _campaignTimer;
  Timer? _notificationTimer;

  final List<_CampaignData> _campaigns = const [
    _CampaignData('Blue Week Deals', 'Daily drops from top sellers', Icons.local_offer_outlined),
    _CampaignData('Official Store Picks', 'Trusted stores with fast response', Icons.verified_outlined),
    _CampaignData('Smart Cart Bundles', 'Quick add bundles for best value', Icons.shopping_cart_checkout_outlined),
  ];

  Color get _bg => _isDarkMode ? const Color(0xFF0B1220) : const Color(0xFFF5F8FC);
  Color get _surface => _isDarkMode ? const Color(0xFF111827) : Colors.white;
  Color get _soft => _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE3F2FD);
  Color get _text => _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get _muted => _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _shadow => _isDarkMode ? const Color(0x70000000) : const Color(0x12000000);

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
    _campaignTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_campaignController.hasClients || _campaigns.isEmpty) return;
      final next = (_campaignIndex + 1) % _campaigns.length;
      _campaignController.animateToPage(next, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    });
    _notificationTimer = Timer.periodic(const Duration(seconds: 12), (_) => _pushRealtimeNotification());
  }

  @override
  void dispose() {
    _campaignTimer?.cancel();
    _notificationTimer?.cancel();
    _campaignController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final products = await _storage.getProducts();
    final vendors = await _storage.getVendors();
    if (!mounted) return;
    setState(() {
      _allProducts = products.where((p) => p.isAvailable).toList();
      _vendors = vendors;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    var list = List<Product>.from(_allProducts);
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (query.isNotEmpty) {
      list = list.where((p) =>
          p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query)).toList();
    }
    if (!mounted) return;
    setState(() => _filteredProducts = list);
  }

  void _pushRealtimeNotification() {
    if (!mounted || _allProducts.isEmpty) return;
    final idx = DateTime.now().millisecondsSinceEpoch % _allProducts.length;
    final p = _allProducts[idx];
    setState(() {
      _notifications.insert(
        0,
        _RealtimeNotification('Update on ${p.name}', 'Stock and pricing refreshed just now', DateTime.now()),
      );
      _unreadNotifications++;
      if (_notifications.length > 30) _notifications.removeLast();
    });
  }

  Vendor? _vendorById(String vendorId) {
    for (final v in _vendors) {
      if (v.id == vendorId) return v;
    }
    return null;
  }

  bool _isOfficial(Vendor? vendor) {
    if (vendor == null) return false;
    final top = _vendors.take(2).map((v) => v.id).toSet();
    return top.contains(vendor.id) || vendor.rating >= 4.2 || vendor.totalTransactions >= 20;
  }

  void _addToCart(Product product, {int qty = 1}) {
    setState(() {
      _cart.update(product.id, (n) => n + qty, ifAbsent: () => qty);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 1)),
    );
  }

  int get _cartCount => _cart.values.fold(0, (sum, n) => sum + n);

  List<String> get _categories {
    final out = <String>{'All'};
    for (final p in _allProducts) {
      out.add(p.category);
    }
    return out.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        title: const Text('SmallVendors Mall', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _openNotifications,
            icon: Badge(
              isLabelVisible: _unreadNotifications > 0,
              label: Text('$_unreadNotifications'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            icon: Icon(_isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/appwrite-auth'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tab == 0 ? _quickActions() : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _tab,
        selectedItemColor: _blue,
        unselectedItemColor: Colors.grey.shade600,
        onTap: (i) => setState(() => _tab = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Categories'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _wishlistIds.isNotEmpty,
              label: Text('${_wishlistIds.length}'),
              child: const Icon(Icons.favorite_border),
            ),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_tab) {
      case 1:
        return _categoriesTab();
      case 2:
        return _cartTab();
      case 3:
        return _wishlistTab();
      case 4:
        return _accountTab();
      default:
        return _homeTab();
    }
  }

  Widget _homeTab() {
    final deals = [..._allProducts]..sort((a, b) => a.price.compareTo(b.price));
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _searchBar(),
          const SizedBox(height: 12),
          _heroBanner(),
          const SizedBox(height: 12),
          _campaignCarousel(),
          const SizedBox(height: 16),
          _categoryChips(),
          const SizedBox(height: 16),
          _sectionTitle('Flash Deals'),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: deals.take(8).length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _dealCard(deals[i]),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Trending Products'),
          const SizedBox(height: 10),
          _filteredProducts.isEmpty
              ? _empty('No products match your search')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.66,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) => _productCard(_filteredProducts[i]),
                ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: _text),
      decoration: InputDecoration(
        hintText: 'Search products, categories...',
        hintStyle: TextStyle(color: _muted, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: _blueDark),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _heroBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [_blue, _blueLight]),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Everything you need,\nfrom trusted local vendors',
                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Browse first. Sign in only when you are ready to order.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.local_mall_outlined, color: Colors.white, size: 36),
        ],
      ),
    );
  }

  Widget _campaignCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 118,
          child: PageView.builder(
            controller: _campaignController,
            itemCount: _campaigns.length,
            onPageChanged: (index) => setState(() => _campaignIndex = index),
            itemBuilder: (context, index) {
              final c = _campaigns[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _soft),
                ),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: _soft, child: Icon(c.icon, color: _blue)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, style: TextStyle(color: _text, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(c.subtitle, style: TextStyle(color: _muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => setState(() => _selectedCategory = 'All'),
                      style: FilledButton.styleFrom(backgroundColor: _blue),
                      child: const Text('View'),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_campaigns.length, (i) {
            final active = i == _campaignIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? _blue : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final category = _categories[i];
          final selected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: selected,
            selectedColor: _soft,
            onSelected: (_) {
              setState(() => _selectedCategory = category);
              _applyFilters();
            },
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
        TextButton(onPressed: () {}, child: Text('See all', style: TextStyle(color: _blueDark))),
      ],
    );
  }

  Widget _dealCard(Product product) {
    final vendor = _vendorById(product.vendorId);
    final oldPrice = product.price * 1.2;
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _shadow, blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openQuickView(product, vendor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: SafeImage(
                  imagePath: product.imagePath,
                  fallback: Container(
                    color: _soft,
                    child: const Icon(Icons.shopping_bag_outlined, size: 38, color: _blue),
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _text, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(children: [
                  Expanded(child: Text(vendor?.businessName ?? 'Unknown vendor', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _muted, fontSize: 11))),
                  if (_isOfficial(vendor)) _officialBadge(),
                ]),
                const SizedBox(height: 6),
                Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: _blueDark, fontWeight: FontWeight.w800, fontSize: 15)),
                Text('\$${oldPrice.toStringAsFixed(2)}', style: TextStyle(color: _muted, decoration: TextDecoration.lineThrough, fontSize: 11)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(Product product) {
    final vendor = _vendorById(product.vendorId);
    final inWish = _wishlistIds.contains(product.id);
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _shadow, blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openQuickView(product, vendor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: SafeImage(
                      imagePath: product.imagePath,
                      fallback: Container(color: _soft, child: const Icon(Icons.inventory_2_outlined, size: 36)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: _surface,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => setState(() => inWish ? _wishlistIds.remove(product.id) : _wishlistIds.add(product.id)),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(inWish ? Icons.favorite : Icons.favorite_border, size: 18, color: inWish ? Colors.red : _muted),
                      ),
                    ),
                  ),
                ),
                if (_isOfficial(vendor)) Positioned(top: 8, left: 8, child: _officialBadge()),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _text, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(vendor?.businessName ?? 'Unknown vendor', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _muted, fontSize: 11)),
                const SizedBox(height: 4),
                Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: _blueDark, fontWeight: FontWeight.w800, fontSize: 15)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addToCart(product),
                  style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('Add to cart', style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _officialBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(10)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: Colors.white, size: 10),
          SizedBox(width: 3),
          Text('Official', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _categoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Shop by category', style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories.where((c) => c != 'All').map((cat) {
            final count = _allProducts.where((p) => p.category == cat).length;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  _tab = 0;
                });
                _applyFilters();
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 42) / 2,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.category_outlined, color: _blue),
                  const SizedBox(height: 8),
                  Text(cat, style: TextStyle(color: _text, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('$count products', style: TextStyle(color: _muted, fontSize: 12)),
                ]),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _cartTab() {
    final items = _allProducts.where((p) => _cart.containsKey(p.id)).toList();
    final total = items.fold<double>(0, (sum, item) => sum + item.price * (_cart[item.id] ?? 0));
    if (items.isEmpty) return _empty('Your cart is empty');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...items.map((item) {
          final qty = _cart[item.id] ?? 0;
          return Card(
            color: _surface,
            child: ListTile(
              title: Text(item.name, style: TextStyle(color: _text)),
              subtitle: Text('Qty: $qty', style: TextStyle(color: _muted)),
              trailing: Text('\$${(item.price * qty).toStringAsFixed(2)}', style: TextStyle(color: _text)),
            ),
          );
        }),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(color: _text, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: _text, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final orderId = 'SV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(orderId: orderId, itemCount: _cartCount),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
                child: const Text('Place order & track'),
              ),
            ),
          ]),
        )
      ],
    );
  }

  Widget _wishlistTab() {
    final items = _allProducts.where((p) => _wishlistIds.contains(p.id)).toList();
    if (items.isEmpty) return _empty('No wishlist items yet');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          color: _surface,
          child: ListTile(
            title: Text(item.name, style: TextStyle(color: _text)),
            subtitle: Text(item.category, style: TextStyle(color: _muted)),
            trailing: IconButton(icon: const Icon(Icons.add_shopping_cart), onPressed: () => _addToCart(item)),
          ),
        );
      },
    );
  }

  Widget _accountTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Guest mode', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Browse products before signup. Track orders after checkout.', style: TextStyle(color: _muted)),
          ]),
        ),
        const SizedBox(height: 12),
        ListTile(
          tileColor: _surface,
          leading: const Icon(Icons.login),
          title: Text('Sign in / Sign up', style: TextStyle(color: _text)),
          subtitle: Text('Save account, chat, and full checkout features', style: TextStyle(color: _muted)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () => Navigator.pushNamed(context, '/appwrite-auth'),
        ),
      ],
    );
  }

  Widget _quickActions() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: Material(
        color: _blueDark,
        borderRadius: BorderRadius.circular(14),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _quickAction(Icons.local_offer_outlined, 'Deals', () {
              setState(() => _selectedCategory = 'All');
              _applyFilters();
            }),
            _quickAction(Icons.shopping_cart_outlined, 'Cart', () => setState(() => _tab = 2)),
            _quickAction(Icons.location_history_outlined, 'Track', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen(orderId: 'SV-DEMO-1234', itemCount: 3)));
            }),
          ]),
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _empty(String text) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(Icons.search_off, size: 40, color: _muted),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: _muted)),
      ]),
    );
  }

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          child: Column(children: [
            const SizedBox(height: 10),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: _muted.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(99))),
            ListTile(
              title: Text('Real-time Notifications', style: TextStyle(color: _text, fontWeight: FontWeight.w800)),
              trailing: TextButton(onPressed: () => setState(() => _notifications.clear()), child: const Text('Clear')),
            ),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(child: Text('No notifications yet', style: TextStyle(color: _muted)))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: _soft, child: const Icon(Icons.notifications_active, color: _blue)),
                          title: Text(n.title, style: TextStyle(color: _text)),
                          subtitle: Text('${n.message}\n${n.time.hour.toString().padLeft(2, '0')}:${n.time.minute.toString().padLeft(2, '0')}', style: TextStyle(color: _muted, fontSize: 12)),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
          ]),
        );
      },
    );
    setState(() => _unreadNotifications = 0);
  }

  void _openQuickView(Product product, Vendor? vendor) {
    int qty = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: _muted.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 12),
              Text(product.name, style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(vendor?.businessName ?? 'Unknown vendor', style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SafeImage(
                  imagePath: product.imagePath,
                  fallback: Container(height: 160, color: _soft, child: const Icon(Icons.inventory_2_outlined, size: 42)),
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(product.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: _muted, height: 1.35)),
              const SizedBox(height: 10),
              Row(children: [
                Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: _blueDark, fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(onPressed: qty > 1 ? () => setModalState(() => qty--) : null, icon: const Icon(Icons.remove_circle_outline)),
                Text('$qty', style: TextStyle(color: _text, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => setModalState(() => qty++), icon: const Icon(Icons.add_circle_outline)),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addToCart(product, qty: qty);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: Text('Quick add to cart ($qty)'),
                ),
              ),
            ]),
          );
        });
      },
    );
  }
}

class _CampaignData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _CampaignData(this.title, this.subtitle, this.icon);
}

class _RealtimeNotification {
  final String title;
  final String message;
  final DateTime time;

  const _RealtimeNotification(this.title, this.message, this.time);
}

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final int itemCount;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.itemCount,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const List<String> _steps = [
    'Order confirmed',
    'Preparing package',
    'Out for delivery',
    'Delivered',
  ];

  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() {
        if (_step < _steps.length - 1) _step++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _steps.length;
    final eta = 22 - (_step * 5);
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${widget.orderId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('${widget.itemCount} item(s) • ETA: ${eta > 0 ? eta : 3} mins', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery progress', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                ...List.generate(_steps.length, (i) {
                  final done = i <= _step;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : Colors.grey, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _steps[i],
                            style: TextStyle(fontWeight: done ? FontWeight.w700 : FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
