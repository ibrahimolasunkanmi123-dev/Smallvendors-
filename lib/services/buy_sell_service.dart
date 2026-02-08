import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/buy_sell_request.dart';

class BuySellService {
  static const String _requestsKey = 'buy_sell_requests';

  Future<List<BuySellRequest>> getRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString(_requestsKey);
    if (requestsJson == null) return [];
    
    final List<dynamic> requestsList = json.decode(requestsJson);
    return requestsList.map((json) => BuySellRequest.fromJson(json)).toList();
  }

  Future<void> saveRequests(List<BuySellRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = json.encode(requests.map((r) => r.toJson()).toList());
    await prefs.setString(_requestsKey, requestsJson);
  }

  Future<void> addRequest(BuySellRequest request) async {
    final requests = await getRequests();
    requests.add(request);
    await saveRequests(requests);
  }

  Future<void> updateRequest(BuySellRequest updatedRequest) async {
    final requests = await getRequests();
    final index = requests.indexWhere((r) => r.id == updatedRequest.id);
    if (index != -1) {
      requests[index] = updatedRequest;
      await saveRequests(requests);
    }
  }

  Future<void> deleteRequest(String requestId) async {
    final requests = await getRequests();
    requests.removeWhere((r) => r.id == requestId);
    await saveRequests(requests);
  }

  Future<List<BuySellRequest>> getRequestsByType(RequestType type) async {
    final requests = await getRequests();
    return requests.where((r) => r.type == type && r.status == RequestStatus.active).toList();
  }

  Future<List<BuySellRequest>> getRequestsByUser(String userId) async {
    final requests = await getRequests();
    return requests.where((r) => r.userId == userId).toList();
  }

  Future<List<BuySellRequest>> searchRequests(String query) async {
    final requests = await getRequests();
    final lowerQuery = query.toLowerCase();
    return requests.where((r) => 
      r.status == RequestStatus.active &&
      (r.title.toLowerCase().contains(lowerQuery) ||
       r.description.toLowerCase().contains(lowerQuery) ||
       r.category.toLowerCase().contains(lowerQuery) ||
       r.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
    ).toList();
  }
}