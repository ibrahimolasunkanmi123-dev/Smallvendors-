import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../models/user.dart' as AppUser;
import '../models/vendor.dart';
import '../models/buyer.dart';

class AppwriteService {
  static const String endpoint = 'https://nyc.cloud.appwrite.io/v1';
  static const String projectId = '699b21ef002b28b002d7';
  static const String databaseId = 'smallvendors-db';
  static const String usersCollectionId = 'users';
  static const String vendorsCollectionId = 'vendors';
  static const String buyersCollectionId = 'buyers';
  
  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  void init() {
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true); // Only for development
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // Authentication Methods
  Future<User> signUp(String email, String password, String name) async {
    return await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<Session> signIn(String email, String password) async {
    return await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
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
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: {
          'name': name,
          'email': email,
          'userType': userType,
          'phone': phone ?? '',
          'address': address ?? '',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // Create specific profile based on user type
      if (userType == 'vendor') {
        await databases.createDocument(
          databaseId: databaseId,
          collectionId: vendorsCollectionId,
          documentId: ID.unique(),
          data: {
            'userId': userId,
            'businessName': businessName ?? '',
            'businessDescription': businessDescription ?? '',
            'isVerified': false,
            'rating': 0.0,
            'totalSales': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
      } else {
        await databases.createDocument(
          databaseId: databaseId,
          collectionId: buyersCollectionId,
          documentId: ID.unique(),
          data: {
            'userId': userId,
            'totalOrders': 0,
            'totalSpent': 0.0,
            'preferredCategories': [],
            'createdAt': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final document = await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );
      return document.data;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<Vendor?> getVendorProfile(String userId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: vendorsCollectionId,
        queries: [Query.equal('userId', userId)],
      );
      
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
      final result = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: buyersCollectionId,
        queries: [Query.equal('userId', userId)],
      );
      
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
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
        data: data,
      );
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Generic data operations
  Future<void> saveData(String collection, Map<String, dynamic> data) async {
    try {
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collection,
        documentId: ID.unique(),
        data: data,
      );
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }

  Future<List<Document>> getData(String collection, {List<String>? queries}) async {
    try {
      final result = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collection,
        queries: queries?.map((q) => Query.equal('userId', q)).toList() ?? [],
      );
      return result.documents;
    } catch (e) {
      print('Error getting data: $e');
      return [];
    }
  }
}