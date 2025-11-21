import 'package:equatable/equatable.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';

/// Base state for dashboard
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state with data
class DashboardLoaded extends DashboardState {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final List<TransactionModel> recentTransactions;

  const DashboardLoaded({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    balance,
    recentTransactions,
  ];

  /// Create a copy with updated values
  DashboardLoaded copyWith({
    double? totalIncome,
    double? totalExpenses,
    double? balance,
    List<TransactionModel>? recentTransactions,
  }) {
    return DashboardLoaded(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      balance: balance ?? this.balance,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }
}

/// Error state
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
