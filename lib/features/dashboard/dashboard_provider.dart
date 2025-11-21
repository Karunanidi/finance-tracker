import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/data/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardStats extends _$DashboardStats {
  @override
  Future<DashboardData> build() async {
    final repository = ref.watch(transactionRepositoryProvider);
    final transactions = await repository.getTransactions();

    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        totalExpenses += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    final balance = totalIncome - totalExpenses;
    final recentTransactions = transactions.take(5).toList();

    return DashboardData(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: balance,
      recentTransactions: recentTransactions,
    );
  }
}

class DashboardData {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final List<TransactionModel> recentTransactions;

  DashboardData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.recentTransactions,
  });
}
