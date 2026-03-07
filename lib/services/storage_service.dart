import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vendor.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/review.dart';
import '../models/buyer.dart';

class StorageService {
  static const _vendorKey = 'vendor';
  static const _productsKey = 'products';
  static const _ordersKey = 'orders';
  static const _customersKey = 'customers';
  static const _settingsKey = 'settings';
  static const _reviewsKey = 'reviews';

  Future<void> saveVendor(Vendor vendor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vendorKey, jsonEncode(vendor.toJson()));

    final vendors = await getVendors();
    final index = vendors.indexWhere((v) => v.id == vendor.id);
    if (index >= 0) {
      vendors[index] = vendor;
    } else {
      vendors.add(vendor);
    }
    await saveVendors(vendors);
  }

  Future<Vendor?> getVendor() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_vendorKey);
    return data != null ? Vendor.fromJson(jsonDecode(data)) : null;
  }

  Future<List<Vendor>> getVendors() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('vendors');
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((v) => Vendor.fromJson(v)).toList();
  }

  Future<void> saveVendors(List<Vendor> vendors) async {
    final prefs = await SharedPreferences.getInstance();
    final data = vendors.map((v) => v.toJson()).toList();
    await prefs.setString('vendors', jsonEncode(data));
  }

  Future<Vendor?> getVendorById(String vendorId) async {
    final vendors = await getVendors();
    try {
      return vendors.firstWhere((v) => v.id == vendorId);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final data = products.map((p) => p.toJson()).toList();
    await prefs.setString(_productsKey, jsonEncode(data));
  }

  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_productsKey);
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((p) => Product.fromJson(p)).toList();
  }

  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final data = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_ordersKey, jsonEncode(data));
  }

  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_ordersKey);
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((o) => Order.fromJson(o)).toList();
  }

  Future<void> saveCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final data = customers.map((c) => c.toJson()).toList();
    await prefs.setString(_customersKey, jsonEncode(data));
  }

  Future<List<Customer>> getCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_customersKey);
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((c) => Customer.fromJson(c)).toList();
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_settingsKey);
    return data != null ? Map<String, dynamic>.from(jsonDecode(data)) : {};
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveData(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  Future<List<Review>> getReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_reviewsKey);
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((r) => Review.fromJson(r)).toList();
  }

  Future<void> saveReviews(List<Review> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    final data = reviews.map((r) => r.toJson()).toList();
    await prefs.setString(_reviewsKey, jsonEncode(data));
  }

  Future<List<Buyer>> getBuyers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('buyers');
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((b) => Buyer.fromJson(b)).toList();
  }

  Future<void> saveBuyers(List<Buyer> buyers) async {
    final prefs = await SharedPreferences.getInstance();
    final data = buyers.map((b) => b.toJson()).toList();
    await prefs.setString('buyers', jsonEncode(data));
  }

  Future<void> saveBuyer(Buyer buyer) async {
    final buyers = await getBuyers();
    final existingIndex = buyers.indexWhere((b) => b.id == buyer.id);
    if (existingIndex >= 0) {
      buyers[existingIndex] = buyer;
    } else {
      buyers.add(buyer);
    }
    await saveBuyers(buyers);
  }

  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> getBoolData(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> saveBoolData(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
