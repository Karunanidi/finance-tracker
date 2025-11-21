import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/features/transactions/transaction_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_provider.g.dart';

@riverpod
class AnalyticsData extends _$AnalyticsData {
  @override
  Future<AnalyticsStats> build() async {
    final transactions = await ref.watch(transactionListProvider.future);

    return _calculateStats(transactions);
  }

  AnalyticsStats _calculateStats(List<TransactionModel> transactions) {
    // Category breakdown
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

    // Sort categories by amount
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get top 5 categories
    final topCategories = Map.fromEntries(sortedCategories.take(5));

    return AnalyticsStats(
      categoryBreakdown: topCategories,
      monthlyTotals: monthlyTotals,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
    );
  }
}

class AnalyticsStats {
  final Map<String, double> categoryBreakdown;
  final Map<String, double> monthlyTotals;
  final double totalIncome;
  final double totalExpenses;

  AnalyticsStats({
    required this.categoryBreakdown,
    required this.monthlyTotals,
    required this.totalIncome,
    required this.totalExpenses,
  });
}
