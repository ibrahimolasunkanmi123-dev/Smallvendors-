import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/buyer.dart';
import '../models/vendor.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      const url = 'https://ovasrhkddiaifhzlcckh.supabase.co';
      const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im92YXNyaGtkZGlhaWZoemxjY2toIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwNDMyNTUsImV4cCI6MjA3NjYxOTI1NX0.k2u8m2Vx6qqMBaF5Gf72_QgjOxbVezYoZxxPfhSawmg';
      
      await Supabase.initialize(url: url, anonKey: anonKey);
    } catch (e) {
      // Supabase initialization failed, continue with local storage
    }
  }

  // Authentication methods
  static Future<AuthResponse?> signUpWithEmail(String email, String password) async {
    try {
      print('SupabaseService: Signing up user $email');
      final response = await _client.auth.signUp(
        email: email, 
        password: password,
        data: {'email_confirm': false}
      );
      print('SupabaseService: Signup response - User: ${response.user?.id}, Session: ${response.session?.accessToken}');
      return response;
    } catch (e) {
      print('SupabaseService: Signup error - $e');
      return null;
    }
  }

  static Future<AuthResponse?> signInWithEmail(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  // Buyer operations
  static Future<Buyer?> saveBuyer(Buyer buyer) async {
    try {
      final response = await _client
          .from('buyers')
          .upsert(buyer.toJson())
          .select()
          .single();
      return Buyer.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<Buyer?> getBuyerByEmail(String email) async {
    try {
      final response = await _client
          .from('buyers')
          .select()
          .eq('email', email)
          .single();
      return Buyer.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<Buyer?> getBuyerById(String id) async {
    try {
      final response = await _client
          .from('buyers')
          .select()
          .eq('id', id)
          .single();
      return Buyer.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Vendor operations
  static Future<Vendor?> saveVendor(Vendor vendor) async {
    try {
      final response = await _client
          .from('vendors')
          .upsert(vendor.toJson())
          .select()
          .single();
      return Vendor.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Vendor>> getVendors() async {
    try {
      final response = await _client.from('vendors').select();
      return (response as List).map((json) => Vendor.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}