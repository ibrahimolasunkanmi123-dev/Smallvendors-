import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../models/vendor.dart';
import '../models/buyer.dart';

class AppwriteService {
  static const String endpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://nyc.cloud.appwrite.io/v1',
  );
  static const String projectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '699b21ef002b28b002d7',
  );
  static const String databaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: '699b24bd001c72ccf9b6',
  );
  static const String fallbackDatabaseId = 'smallvendors';
  static const String usersCollectionId = String.fromEnvironment(
    'APPWRITE_USERS_COLLECTION_ID',
    defaultValue: 'users',
  );
  static const String vendorsCollectionId = String.fromEnvironment(
    'APPWRITE_VENDORS_COLLECTION_ID',
    defaultValue: 'vendors',
  );
  static const String buyersCollectionId = String.fromEnvironment(
    'APPWRITE_BUYERS_COLLECTION_ID',
    defaultValue: 'buyers',
  );
  
  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  List<String> get _databaseIdCandidates {
    final ids = <String>[databaseId, fallbackDatabaseId];
    return ids.toSet().toList();
  }

  bool _isMissingDatabaseError(Object e) {
    if (e is AppwriteException) {
      final message = (e.message ?? '').toLowerCase();
      return e.code == 404 &&
          message.contains('database') &&
          message.contains('requested id could not be found');
    }
    return false;
  }

  bool _isConflictError(Object e) {
    return e is AppwriteException && e.code == 409;
  }

  Map<String, dynamic> _buildUserProfileData({
    required String name,
    required String email,
    required String userType,
    String? phone,
    String? address,
  }) {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'userType': userType,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
    };

    if (phone != null && phone.trim().isNotEmpty) {
      data['phone'] = phone.trim();
    }
    if (address != null && address.trim().isNotEmpty) {
      data['address'] = address.trim();
    }
    return data;
  }

  Future<T> _withDatabaseFallback<T>(Future<T> Function(String dbId) action) async {
    Object? lastError;
    for (final dbId in _databaseIdCandidates) {
      try {
        return await action(dbId);
      } catch (e) {
        lastError = e;
        if (_isMissingDatabaseError(e)) {
          continue;
        }
        rethrow;
      }
    }
    throw Exception(
      'No matching Appwrite database ID found. Tried: ${_databaseIdCandidates.join(", ")}. Last error: $lastError',
    );
  }

  void init() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Authentication Methods
  Future<User> signUp(String email, String password, String name) async {
    try {
      print('Attempting Appwrite signup for: $email');
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      print('Appwrite signup successful: ${user.$id}');
      return user;
    } catch (e) {
      print('Appwrite signup error: $e');
      rethrow;
    }
  }

  Future<Session> signIn(String email, String password) async {
    try {
      print('Attempting Appwrite signin for: $email');
      
      // Clear any stale/active session before creating a new one.
      try {
        await account.deleteSession(sessionId: 'current');
      } catch (_) {
        // Ignore if there is no existing session.
      }

      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      print('Appwrite signin successful');
      return session;
    } catch (e) {
      print('Appwrite signin error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // User Profile Management
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String userType, // 'buyer' or 'vendor'
    String? phone,
    String? address,
    String? businessName,
    String? businessDescription,
  }) async {
    try {
      // Create base user profile
      try {
        await _withDatabaseFallback((dbId) => databases.createDocument(
              databaseId: dbId,
              collectionId: usersCollectionId,
              documentId: userId,
              data: _buildUserProfileData(
                name: name,
                email: email,
                userType: userType,
                phone: phone,
                address: address,
              ),
            ));
      } catch (e) {
        if (!_isConflictError(e)) rethrow;
      }

      // Create specific profile based on user type
      if (userType == 'vendor') {
        try {
          await _withDatabaseFallback((dbId) => databases.createDocument(
                databaseId: dbId,
                collectionId: vendorsCollectionId,
                documentId: ID.unique(),
                data: {
                  'userId': userId,
                  'businessName': (businessName ?? '').trim().isNotEmpty
                      ? businessName!.trim()
                      : name,
                  'businessDescription': businessDescription ?? '',
                  'isVerified': false,
                  'rating': 0.0,
                  'totalSales': 0,
                  'createdAt': DateTime.now().toIso8601String(),
                },
              ));
        } catch (e) {
          if (!_isConflictError(e)) rethrow;
        }
      } else {
        try {
          await _withDatabaseFallback((dbId) => databases.createDocument(
                databaseId: dbId,
                collectionId: buyersCollectionId,
                documentId: ID.unique(),
                data: {
                  'userId': userId,
                  'totalOrders': 0,
                  'totalSpent': 0.0,
                  'preferredCategories': [],
                  'createdAt': DateTime.now().toIso8601String(),
                },
              ));
        } catch (e) {
          if (!_isConflictError(e)) rethrow;
        }
      }
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final document = await _withDatabaseFallback((dbId) => databases.getDocument(
            databaseId: dbId,
            collectionId: usersCollectionId,
            documentId: userId,
          ));
      return document.data;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> ensureUserProfiles({
    required User user,
    String defaultUserType = 'buyer',
  }) async {
    Map<String, dynamic>? profile = await getUserProfile(user.$id);

    if (profile == null) {
      try {
        await _withDatabaseFallback((dbId) => databases.createDocument(
              databaseId: dbId,
              collectionId: usersCollectionId,
              documentId: user.$id,
              data: _buildUserProfileData(
                name: user.name,
                email: user.email,
                userType: defaultUserType,
              ),
            ));
      } catch (e) {
        if (!_isConflictError(e)) rethrow;
      }
      profile = await getUserProfile(user.$id);
    }

    if (profile == null) {
      profile = {
        'name': user.name,
        'email': user.email,
        'userType': defaultUserType,
      };
    }

    final userType = profile['userType'] == 'vendor' ? 'vendor' : 'buyer';
    if (userType == 'vendor') {
      final vendor = await getVendorProfile(user.$id);
      if (vendor == null) {
        try {
          await _withDatabaseFallback((dbId) => databases.createDocument(
                databaseId: dbId,
                collectionId: vendorsCollectionId,
                documentId: ID.unique(),
                data: {
                  'userId': user.$id,
                  'businessName': user.name.isNotEmpty ? user.name : 'My Business',
                  'businessDescription': '',
                  'isVerified': false,
                  'rating': 0.0,
                  'totalSales': 0,
                  'createdAt': DateTime.now().toIso8601String(),
                },
              ));
        } catch (e) {
          if (!_isConflictError(e)) rethrow;
        }
      }
    } else {
      final buyer = await getBuyerProfile(user.$id);
      if (buyer == null) {
        try {
          await _withDatabaseFallback((dbId) => databases.createDocument(
                databaseId: dbId,
                collectionId: buyersCollectionId,
                documentId: ID.unique(),
                data: {
                  'userId': user.$id,
                  'totalOrders': 0,
                  'totalSpent': 0.0,
                  'preferredCategories': [],
                  'createdAt': DateTime.now().toIso8601String(),
                },
              ));
        } catch (e) {
          if (!_isConflictError(e)) rethrow;
        }
      }
    }

    return profile;
  }

  Future<Vendor?> getVendorProfile(String userId) async {
    try {
      final result = await _withDatabaseFallback((dbId) => databases.listDocuments(
            databaseId: dbId,
            collectionId: vendorsCollectionId,
            queries: [Query.equal('userId', userId)],
          ));
      
      if (result.documents.isNotEmpty) {
        final doc = result.documents.first;
        return Vendor(
          id: doc.$id,
          businessName: doc.data['businessName'] ?? '',
          ownerName: '', // Get from user profile
          phone: '',
          businessType: doc.data['businessDescription'] ?? '',
          location: '',
          rating: (doc.data['rating'] ?? 0.0).toDouble(),
          totalReviews: 0,
          totalTransactions: doc.data['totalSales'] ?? 0,
          email: '', // Get from user profile
        );
      }
      return null;
    } catch (e) {
      print('Error getting vendor profile: $e');
      return null;
    }
  }

  Future<Buyer?> getBuyerProfile(String userId) async {
    try {
      final result = await _withDatabaseFallback((dbId) => databases.listDocuments(
            databaseId: dbId,
            collectionId: buyersCollectionId,
            queries: [Query.equal('userId', userId)],
          ));
      
      if (result.documents.isNotEmpty) {
        final doc = result.documents.first;
        return Buyer(
          id: doc.$id,
          name: '', // Get from user profile
          email: '',
          phone: '',
          address: '',
          createdAt: DateTime.parse(doc.data['createdAt']),
        );
      }
      return null;
    } catch (e) {
      print('Error getting buyer profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _withDatabaseFallback((dbId) => databases.updateDocument(
            databaseId: dbId,
            collectionId: usersCollectionId,
            documentId: userId,
            data: data,
          ));
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Generic data operations
  Future<void> saveData(String collection, Map<String, dynamic> data) async {
    try {
      await _withDatabaseFallback((dbId) => databases.createDocument(
            databaseId: dbId,
            collectionId: collection,
            documentId: ID.unique(),
            data: data,
          ));
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }

  Future<List<Document>> getData(String collection, {List<String>? queries}) async {
    try {
      final result = await _withDatabaseFallback((dbId) => databases.listDocuments(
            databaseId: dbId,
            collectionId: collection,
            queries: queries?.map((q) => Query.equal('userId', q)).toList() ?? [],
          ));
      return result.documents;
    } catch (e) {
      print('Error getting data: $e');
      return [];
    }
  }
}
