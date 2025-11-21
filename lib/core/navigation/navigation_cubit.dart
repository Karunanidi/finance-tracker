import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing bottom navigation state
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  /// Navigate to a specific tab
  void navigateToTab(int index) {
    if (index >= 0 && index < 5) {
      emit(index);
    }
  }

  /// Navigate to Dashboard (index 0)
  void navigateToDashboard() => emit(0);

  /// Navigate to Transactions (index 1)
  void navigateToTransactions() => emit(1);

  /// Navigate to Add Transaction (index 2)
  void navigateToAddTransaction() => emit(2);

  /// Navigate to Analytics (index 3)
  void navigateToAnalytics() => emit(3);

  /// Navigate to Settings (index 4)
  void navigateToSettings() => emit(4);
}
