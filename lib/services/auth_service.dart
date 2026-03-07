import 'dart:async';

import '../models/buyer.dart';
import 'appwrite_service.dart';
import 'storage_service.dart';

class AuthUser {
  final String id;
  final String? email;
  final DateTime? emailConfirmedAt;

  const AuthUser({
    required this.id,
    this.email,
    this.emailConfirmedAt,
  });
}

class AuthResponse {
  final AuthUser? user;
  final String? accessToken;

  const AuthResponse({this.user, this.accessToken});
}

class AuthState {
  final AuthUser? user;
  final String event;

  const AuthState({required this.user, required this.event});
}

class AuthService {
  final AppwriteService _appwrite = AppwriteService();
  final StorageService _storage = StorageService();
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  AuthUser? _currentUser;

  AuthService() {
    _appwrite.init();
  }

  AuthUser _mapUser(dynamic user) {
    final isVerified = (user.emailVerification as bool?) ?? false;
    return AuthUser(
      id: user.$id as String,
      email: user.email as String?,
      emailConfirmedAt: isVerified ? DateTime.now() : null,
    );
  }

  AuthUser? get currentUser => _currentUser;

  bool get isSignedIn => currentUser != null;

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final displayName = email.split('@').first;
      final createdUser = await _appwrite.signUp(email, password, displayName);

      try {
        await _appwrite.signIn(email, password);
      } catch (_) {
        // Session may already exist or signup policy may block auto sign-in.
      }

      _currentUser = _mapUser(createdUser);
      _authStateController.add(AuthState(user: _currentUser, event: 'signed_up'));

      return AuthResponse(user: _currentUser);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final session = await _appwrite.signIn(email, password);
      final user = await _appwrite.getCurrentUser();

      if (user != null) {
        _currentUser = _mapUser(user);
        await _storage.saveData('current_buyer', user.$id);
      }

      _authStateController.add(AuthState(user: _currentUser, event: 'signed_in'));
      return AuthResponse(user: _currentUser, accessToken: session.$id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendEmailVerification(String email) async {
    await refreshSession();
    if (_currentUser == null) {
      throw Exception('Please sign in before requesting verification email.');
    }

    await _appwrite.account.createVerification(
      url: 'https://smallvendors.vercel.app/',
    );
  }

  Future<Buyer> createUserProfile({
    required String name,
    required String email,
    String? profileImage,
    String? location,
  }) async {
    await refreshSession();
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _appwrite.createUserProfile(
      userId: user.id,
      name: name,
      email: email,
      userType: 'buyer',
      address: location,
    );

    final buyer = Buyer(
      id: user.id,
      name: name,
      email: email,
      profileImage: profileImage,
      location: location ?? 'Location not set',
    );

    final buyers = await _storage.getBuyers();
    buyers.removeWhere((b) => b.id == buyer.id);
    buyers.add(buyer);
    await _storage.saveBuyers(buyers);
    await _storage.saveData('current_buyer', buyer.id);

    _authStateController.add(AuthState(user: _currentUser, event: 'profile_updated'));
    return buyer;
  }

  Future<void> signOut() async {
    await _appwrite.signOut();
    await _storage.removeData('current_buyer');
    _currentUser = null;
    _authStateController.add(const AuthState(user: null, event: 'signed_out'));
  }

  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  Future<Buyer?> getUserProfile() async {
    await refreshSession();
    final user = currentUser;
    if (user == null) return null;

    try {
      final profile = await _appwrite.getUserProfile(user.id);
      if (profile == null) return null;
      return Buyer(
        id: user.id,
        name: (profile['name'] ?? '').toString(),
        email: (profile['email'] ?? user.email ?? '').toString(),
        profileImage: profile['profileImage']?.toString(),
        location: (profile['location'] ?? 'Location not set').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  Future<void> refreshSession() async {
    try {
      final user = await _appwrite.getCurrentUser();
      _currentUser = user == null ? null : _mapUser(user);
    } catch (_) {
      _currentUser = null;
    }
  }
}
