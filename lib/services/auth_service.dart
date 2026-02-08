import 'package:supabase_flutter/supabase_flutter.dart';

import 'storage_service.dart';
import '../models/buyer.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storage = StorageService();

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Sign up with email - disable email confirmation for testing
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      print('Attempting to sign up user: $email');
      
      // Sign up without email confirmation
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'email_confirm': false, // Skip email confirmation
        },
      );
      
      print('Supabase signup response: ${response.user?.id}');
      print('Supabase signup session: ${response.session?.accessToken}');
      
      if (response.user == null) {
        if (response.session == null) {
          throw Exception('Signup failed - check Supabase email confirmation settings');
        }
        throw Exception('Failed to create user account - no user returned');
      }
      
      // Manually create profile if trigger doesn't work
      try {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'user_type': 'buyer',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Profile created manually');
      } catch (profileError) {
        print('Profile creation error (might already exist): $profileError');
      }
      
      return response;
    } catch (e) {
      print('Signup error details: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      print('Attempting to sign in user: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('Sign in response: ${response.user?.id}');
      
      if (response.user != null) {
        // Save current user ID to local storage
        await _storage.saveData('current_buyer', response.user!.id);
      }
      
      return response;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Resend email verification link
  Future<void> resendEmailVerification(String email) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  // Create user profile after authentication
  Future<Buyer> createUserProfile({
    required String name,
    required String email,
    String? profileImage,
    String? location,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');

    print('Creating profile for user: ${user.id}');

    try {
      // Update profile in Supabase
      final updateResult = await _supabase.from('profiles').update({
        'name': name,
        'profile_image': profileImage,
        'location': location ?? 'Location not set',
        'user_type': 'buyer',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id).select();
      
      print('Profile update result: $updateResult');
    } catch (e) {
      print('Error updating profile in Supabase: $e');
      // Continue anyway - we'll save locally
    }

    final buyer = Buyer(
      id: user.id,
      name: name,
      email: email,
      profileImage: profileImage,
      location: location ?? 'Location not set',
    );

    // Save to local storage as backup
    try {
      final buyers = await _storage.getBuyers();
      buyers.removeWhere((b) => b.id == buyer.id);
      buyers.add(buyer);
      await _storage.saveBuyers(buyers);
      await _storage.saveData('current_buyer', user.id);
      print('Saved buyer to local storage: ${buyer.id}');
    } catch (e) {
      print('Error saving to local storage: $e');
    }

    return buyer;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _storage.removeData('current_buyer');
  }

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  // Get user profile from Supabase
  Future<Buyer?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Buyer(
        id: response['id'],
        name: response['name'] ?? '',
        email: response['email'] ?? user.email ?? '',
        profileImage: response['profile_image'],
        location: response['location'] ?? 'Location not set',
      );
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Refresh session to check verification status
  Future<void> refreshSession() async {
    await _supabase.auth.refreshSession();
  }
}