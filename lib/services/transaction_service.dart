import 'dart:convert';
import '../models/transaction.dart';
import '../models/enums.dart';
import 'storage_service.dart';

class TransactionService {
  final _storage = StorageService();
  static const String _transactionsKey = 'transactions';

  Future<List<Transaction>> getTransactions(String vendorId) async {
    final transactionsData = await _storage.getData(_transactionsKey) ?? '[]';
    final transactionsList = jsonDecode(transactionsData) as List;
    return transactionsList
        .map((json) => Transaction.fromJson(json))
        .where((transaction) => transaction.vendorId == vendorId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveTransaction(Transaction transaction) async {
    final transactions = await _getAllTransactions();
    final existingIndex = transactions.indexWhere((t) => t.id == transaction.id);
    
    if (existingIndex >= 0) {
      transactions[existingIndex] = transaction;
    } else {
      transactions.add(transaction);
    }
    
    await _storage.saveData(_transactionsKey, jsonEncode(transactions.map((t) => t.toJson()).toList()));
  }

  Future<Transaction?> getTransaction(String transactionId) async {
    final transactions = await _getAllTransactions();
    return transactions.where((t) => t.id == transactionId).firstOrNull;
  }

  Future<void> updateTransactionStatus(String transactionId, TransactionStatus status) async {
    final transaction = await getTransaction(transactionId);
    if (transaction != null) {
      final updatedTransaction = transaction.copyWith(
        status: status,
      );
      await saveTransaction(updatedTransaction);
    }
  }

  Future<List<Transaction>> getTransactionsByCustomer(String vendorId, String customerId) async {
    final transactions = await getTransactions(vendorId);
    return transactions.where((t) => t.customerId == customerId).toList();
  }

  Future<double> getTotalRevenue(String vendorId, {DateTime? startDate, DateTime? endDate}) async {
    final transactions = await getTransactions(vendorId);
    double total = 0.0;
    for (final transaction in transactions) {
      if (transaction.status == TransactionStatus.completed &&
          (startDate == null || transaction.createdAt.isAfter(startDate)) &&
          (endDate == null || transaction.createdAt.isBefore(endDate))) {
        total += transaction.total ?? transaction.totalAmount;
      }
    }
    return total;
  }

  Future<List<Transaction>> _getAllTransactions() async {
    final transactionsData = await _storage.getData(_transactionsKey) ?? '[]';
    final transactionsList = jsonDecode(transactionsData) as List;
    return transactionsList.map((json) => Transaction.fromJson(json)).toList();
  }
}