import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/data/repositories/transaction_repository.dart';
import 'package:finance_tracker/features/transactions/cubit/transactions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing transactions state
class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionRepository _repository;

  TransactionsCubit(this._repository) : super(const TransactionsInitial());

  /// Load all transactions
  Future<void> loadTransactions() async {
    try {
      emit(const TransactionsLoading());
      final transactions = await _repository.getTransactions();
      emit(TransactionsLoaded(transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      emit(const TransactionAdding());
      await _repository.addTransaction(transaction);
      emit(const TransactionAdded());
      // Reload transactions after adding
      await loadTransactions();
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  /// Refresh transactions
  Future<void> refresh() async {
    await loadTransactions();
  }
}
