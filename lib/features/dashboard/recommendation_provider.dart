import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:finance_tracker/data/services/ai_recommendation_service.dart';
import 'package:finance_tracker/features/analytics/analytics_provider.dart';
import 'package:finance_tracker/features/transactions/transaction_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recommendation_provider.g.dart';

class RecommendationState {
  final SpendingRecommendation recommendation;
  final String inputHash;
  final DateTime lastUpdated;

  RecommendationState({
    required this.recommendation,
    required this.inputHash,
    required this.lastUpdated,
  });
}

// Cache at the provider level (keep alive to persist across rebuilds)
RecommendationState? _cachedState;

@riverpod
class RecommendationData extends _$RecommendationData {
  @override
  Future<SpendingRecommendation> build() async {
    final transactions = await ref.watch(transactionListProvider.future);
    final analyticsState = await ref.watch(analyticsDataProvider.future);
    final aiService = ref.watch(aiRecommendationServiceProvider);

    // Calculate totals from transactions
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        totalExpenses += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    final currentBalance = totalIncome - totalExpenses;

    // Calculate days in month and days remaining
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;

    // Generate hash of current inputs
    final currentInputHash = _generateInputHash(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      currentBalance: currentBalance,
      categoryBreakdown: analyticsState.categoryBreakdown,
    );

    // Check if we can use cached data
    if (_canUseCache(currentInputHash)) {
      return _cachedState!.recommendation;
    }

    // If not, generate new recommendation
    final recommendation = await aiService.generateRecommendation(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      currentBalance: currentBalance,
      categoryBreakdown: analyticsState.categoryBreakdown,
      daysInMonth: daysInMonth,
      daysRemaining: daysRemaining,
    );

    // Update cache
    _cachedState = RecommendationState(
      recommendation: recommendation,
      inputHash: currentInputHash,
      lastUpdated: DateTime.now(),
    );

    return recommendation;
  }

  String _generateInputHash({
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    required Map<String, double> categoryBreakdown,
  }) {
    final data = {
      'income': totalIncome.toStringAsFixed(2),
      'expenses': totalExpenses.toStringAsFixed(2),
      'balance': currentBalance.toStringAsFixed(2),
      'categories': categoryBreakdown.toString(),
      'date': DateTime.now().day, // Invalidate daily
    };
    return md5.convert(utf8.encode(jsonEncode(data))).toString();
  }

  bool _canUseCache(String currentHash) {
    if (_cachedState == null) return false;

    // Check if hash matches
    if (_cachedState!.inputHash != currentHash) return false;

    // Check if cache is too old (e.g., > 24 hours)
    final difference = DateTime.now().difference(_cachedState!.lastUpdated);
    if (difference.inHours > 24) return false;

    return true;
  }

  /// Manually refresh the recommendation
  Future<void> refresh() async {
    // Clear cache to force update
    _cachedState = null;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
