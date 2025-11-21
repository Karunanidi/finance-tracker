import 'package:equatable/equatable.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';

/// Base state for transactions
abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

/// Loading state
class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

/// Loaded state with data
class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;

  const TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// Error state
class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Adding transaction state
class TransactionAdding extends TransactionsState {
  const TransactionAdding();
}

/// Transaction added successfully
class TransactionAdded extends TransactionsState {
  const TransactionAdded();
}
