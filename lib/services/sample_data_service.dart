import '../models/vendor.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';
import 'storage_service.dart';

class SampleDataService {
  static final _storage = StorageService();

  static Future<void> initializeSampleData() async {
    final existingProducts = await _storage.getProducts();
    if (existingProducts.isNotEmpty) return;

    await _createSampleVendors();
    await _createSampleProducts();
    await _createSampleCustomers();
    await _createSampleOrders();
  }

  static Future<void> _createSampleVendors() async {
    final vendors = [
      Vendor(
        id: 'vendor1',
        businessName: 'Fresh Foods Market',
        ownerName: 'John Smith',
        phone: '+1234567890',
        businessType: 'Food & Beverages',
        location: 'Downtown Plaza',
        email: 'john@freshfoods.com',
      ),
      Vendor(
        id: 'vendor2',
        businessName: 'Tech Gadgets Store',
        ownerName: 'Sarah Johnson',
        phone: '+1234567891',
        businessType: 'Electronics',
        location: 'Tech Mall',
        email: 'sarah@techgadgets.com',
      ),
      Vendor(
        id: 'vendor3',
        businessName: 'Fashion Boutique',
        ownerName: 'Emma Wilson',
        phone: '+1234567892',
        businessType: 'Fashion',
        location: 'Style Street',
        email: 'emma@fashionboutique.com',
      ),
      Vendor(
        id: 'vendor4',
        businessName: 'Home & Garden',
        ownerName: 'Mike Brown',
        phone: '+1234567893',
        businessType: 'Home Decor',
        location: 'Garden Center',
        email: 'mike@homeandgarden.com',
      ),
    ];
    await _storage.saveVendors(vendors);
  }

  static Future<void> _createSampleProducts() async {
    final products = [
      // Fresh Foods Market
      Product(
        id: 'prod1',
        vendorId: 'vendor1',
        name: 'Fresh Apples',
        description: 'Crisp and sweet red apples, perfect for snacking',
        price: 2.99,
        category: 'Food',
        stock: 50,
        orders: 25,
        views: 150,
      ),
      Product(
        id: 'prod2',
        vendorId: 'vendor1',
        name: 'Organic Bananas',
        description: 'Fresh organic bananas, rich in potassium',
        price: 1.99,
        category: 'Food',
        stock: 30,
        orders: 18,
        views: 120,
      ),
      Product(
        id: 'prod3',
        vendorId: 'vendor1',
        name: 'Premium Coffee Beans',
        description: 'Freshly roasted premium coffee beans',
        price: 12.99,
        category: 'Food',
        stock: 20,
        orders: 35,
        views: 220,
      ),
      Product(
        id: 'prod4',
        vendorId: 'vendor1',
        name: 'Artisan Bread',
        description: 'Handmade artisan bread baked daily',
        price: 4.50,
        category: 'Food',
        stock: 15,
        orders: 28,
        views: 95,
      ),
      // Tech Gadgets Store
      Product(
        id: 'prod5',
        vendorId: 'vendor2',
        name: 'Wireless Headphones',
        description: 'High-quality wireless headphones with noise cancellation',
        price: 89.99,
        category: 'Electronics',
        stock: 15,
        orders: 12,
        views: 200,
      ),
      Product(
        id: 'prod6',
        vendorId: 'vendor2',
        name: 'Smartphone Case',
        description: 'Durable protective case for smartphones',
        price: 19.99,
        category: 'Electronics',
        stock: 25,
        orders: 30,
        views: 180,
      ),
      Product(
        id: 'prod7',
        vendorId: 'vendor2',
        name: 'Bluetooth Speaker',
        description: 'Portable Bluetooth speaker with excellent sound quality',
        price: 45.99,
        category: 'Electronics',
        stock: 12,
        orders: 22,
        views: 165,
      ),
      Product(
        id: 'prod8',
        vendorId: 'vendor2',
        name: 'USB Cable',
        description: 'High-speed USB charging cable',
        price: 9.99,
        category: 'Electronics',
        stock: 40,
        orders: 45,
        views: 130,
      ),
      // Fashion Boutique
      Product(
        id: 'prod9',
        vendorId: 'vendor3',
        name: 'Summer Dress',
        description: 'Elegant floral summer dress, perfect for any occasion',
        price: 49.99,
        category: 'Fashion',
        stock: 20,
        orders: 15,
        views: 180,
      ),
      Product(
        id: 'prod10',
        vendorId: 'vendor3',
        name: 'Designer Handbag',
        description: 'Stylish leather handbag with premium finish',
        price: 79.99,
        category: 'Fashion',
        stock: 8,
        orders: 12,
        views: 250,
      ),
      Product(
        id: 'prod11',
        vendorId: 'vendor3',
        name: 'Casual Sneakers',
        description: 'Comfortable and trendy sneakers for everyday wear',
        price: 65.99,
        category: 'Fashion',
        stock: 25,
        orders: 20,
        views: 190,
      ),
      // Home & Garden
      Product(
        id: 'prod12',
        vendorId: 'vendor4',
        name: 'Indoor Plant Set',
        description: 'Beautiful set of 3 indoor plants to brighten your home',
        price: 29.99,
        category: 'Home',
        stock: 15,
        orders: 18,
        views: 140,
      ),
      Product(
        id: 'prod13',
        vendorId: 'vendor4',
        name: 'Decorative Candles',
        description: 'Scented decorative candles for a cozy atmosphere',
        price: 15.99,
        category: 'Home',
        stock: 30,
        orders: 25,
        views: 160,
      ),
      Product(
        id: 'prod14',
        vendorId: 'vendor4',
        name: 'Garden Tool Set',
        description: 'Complete set of essential gardening tools',
        price: 39.99,
        category: 'Home',
        stock: 12,
        orders: 8,
        views: 110,
      ),
    ];
    await _storage.saveProducts(products);
  }

  static Future<void> _createSampleCustomers() async {
    final customers = [
      Customer(
        name: 'Alice Brown',
        email: 'alice@email.com',
        phone: '+1234567892',
        totalOrders: 5,
        totalSpent: 150.50,
      ),
      Customer(
        name: 'Bob Wilson',
        email: 'bob@email.com',
        phone: '+1234567893',
        totalOrders: 3,
        totalSpent: 89.99,
      ),
      Customer(
        name: 'Carol Davis',
        email: 'carol@email.com',
        phone: '+1234567894',
        totalOrders: 8,
        totalSpent: 245.75,
      ),
      Customer(
        name: 'David Miller',
        email: 'david@email.com',
        phone: '+1234567895',
        totalOrders: 2,
        totalSpent: 65.99,
      ),
    ];
    await _storage.saveCustomers(customers);
  }

  static Future<void> _createSampleOrders() async {
    final orders = [
      Order(
        id: 'order1',
        buyerId: 'buyer1',
        vendorId: 'vendor1',
        items: [],
        status: OrderStatus.delivered,
        totalAmount: 25.50,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        deliveryAddress: '123 Main St',
        paymentMethod: 'Cash',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'order2',
        buyerId: 'buyer2',
        vendorId: 'vendor2',
        items: [],
        status: OrderStatus.pending,
        totalAmount: 89.99,
        orderDate: DateTime.now().subtract(const Duration(hours: 5)),
        deliveryAddress: '456 Oak Ave',
        paymentMethod: 'Card',
      ),
      Order(
        id: 'order3',
        buyerId: 'buyer3',
        vendorId: 'vendor3',
        items: [],
        status: OrderStatus.delivered,
        totalAmount: 129.98,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        deliveryAddress: '789 Pine St',
        paymentMethod: 'Card',
        completedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Order(
        id: 'order4',
        buyerId: 'buyer4',
        vendorId: 'vendor4',
        items: [],
        status: OrderStatus.preparing,
        totalAmount: 45.98,
        orderDate: DateTime.now().subtract(const Duration(hours: 3)),
        deliveryAddress: '321 Elm Ave',
        paymentMethod: 'Cash',
      ),
    ];
    await _storage.saveOrders(orders);
  }
}