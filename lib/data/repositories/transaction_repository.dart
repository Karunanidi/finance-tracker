import 'dart:io';
import 'package:finance_tracker/data/models/transaction_model.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'transaction_repository.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(Supabase.instance.client);
}

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository(this._supabase);

  /// Get current authenticated user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Fetch all transactions for the current user
  Future<List<TransactionModel>> getTransactions() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  /// Add a new transaction for the current user
  Future<void> addTransaction(TransactionModel transaction) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final transactionData = transaction.toJson();
    transactionData['user_id'] = userId;

    await _supabase.from('transactions').insert(transactionData);
  }

  /// Upload receipt image to user-specific folder
  Future<String?> uploadReceipt(File file) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Use user-specific path: {user_id}/{timestamp}.jpg
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '$userId/$fileName';

    try {
      await _supabase.storage
          .from('receipts')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL (will work due to RLS policies)
      return _supabase.storage.from('receipts').getPublicUrl(filePath);
    } catch (e) {
      print('Error uploading receipt: $e');
      return null;
    }
  }

  /// Delete all transactions for the current user
  Future<void> deleteAllUserTransactions() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase.from('transactions').delete().eq('user_id', userId);
  }

  /// Delete all receipts for the current user from storage
  Future<void> deleteAllUserReceipts() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // List all files in user's folder
      final files = await _supabase.storage.from('receipts').list(path: userId);

      if (files.isEmpty) return;

      // Delete all files
      final filePaths = files.map((file) => '$userId/${file.name}').toList();
      await _supabase.storage.from('receipts').remove(filePaths);
    } catch (e) {
      print('Error deleting receipts: $e');
      // Continue even if deletion fails
    }
  }

  /// Delete all user data (transactions + receipts)
  Future<void> deleteAllUserData() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Delete receipts first
    await deleteAllUserReceipts();

    // Then delete transactions
    await deleteAllUserTransactions();
  }

  /// Delete a specific transaction
  Future<void> deleteTransaction(String transactionId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase
        .from('transactions')
        .delete()
        .eq('id', transactionId)
        .eq('user_id', userId);
  }

  /// Update a transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final transactionData = transaction.toJson();
    transactionData['user_id'] = userId;
    transactionData['updated_at'] = DateTime.now().toIso8601String();

    await _supabase
        .from('transactions')
        .update(transactionData)
        .eq('id', transaction.id)
        .eq('user_id', userId);
  }
}
