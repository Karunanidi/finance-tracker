import 'package:finance_tracker/data/repositories/transaction_repository.dart';
import 'package:finance_tracker/features/dashboard/cubit/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing dashboard state
class DashboardCubit extends Cubit<DashboardState> {
  final TransactionRepository _repository;

  DashboardCubit(this._repository) : super(const DashboardInitial());

  /// Load dashboard data
  Future<void> loadDashboard() async {
    try {
      emit(const DashboardLoading());

      final transactions = await _repository.getTransactions();

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

      emit(
        DashboardLoaded(
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          balance: balance,
          recentTransactions: recentTransactions,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboard();
  }
}
