import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/data/repositories/transaction_repository.dart';
import 'package:finance_tracker/features/analytics/cubit/analytics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing analytics state
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final TransactionRepository _repository;

  AnalyticsCubit(this._repository) : super(const AnalyticsInitial());

  /// Load analytics data
  Future<void> loadAnalytics() async {
    try {
      emit(const AnalyticsLoading());

      final transactions = await _repository.getTransactions();
      final stats = _calculateStats(transactions);

      emit(
        AnalyticsLoaded(
          categoryBreakdown: stats['categoryBreakdown'] as Map<String, double>,
          monthlyTotals: stats['monthlyTotals'] as Map<String, double>,
          totalIncome: stats['totalIncome'] as double,
          totalExpenses: stats['totalExpenses'] as double,
        ),
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  /// Calculate analytics statistics
  Map<String, dynamic> _calculateStats(List<TransactionModel> transactions) {
    final Map<String, double> categoryTotals = {};
    final Map<String, double> monthlyTotals = {};

    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      // Category totals (expenses only)
      if (transaction.isExpense) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
        totalExpenses += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }

      // Monthly totals
      final monthKey =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0) +
          (transaction.isExpense ? transaction.amount : -transaction.amount);
    }

    // Sort categories by amount and get top 5
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = Map.fromEntries(sortedCategories.take(5));

    return {
      'categoryBreakdown': topCategories,
      'monthlyTotals': monthlyTotals,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
    };
  }

  /// Refresh analytics data
  Future<void> refresh() async {
    await loadAnalytics();
  }
}
