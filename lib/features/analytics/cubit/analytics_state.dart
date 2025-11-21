import 'package:equatable/equatable.dart';

/// Base state for analytics
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// Loading state
class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

/// Loaded state with data
class AnalyticsLoaded extends AnalyticsState {
  final Map<String, double> categoryBreakdown;
  final Map<String, double> monthlyTotals;
  final double totalIncome;
  final double totalExpenses;

  const AnalyticsLoaded({
    required this.categoryBreakdown,
    required this.monthlyTotals,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  List<Object?> get props => [
    categoryBreakdown,
    monthlyTotals,
    totalIncome,
    totalExpenses,
  ];
}

/// Error state
class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
