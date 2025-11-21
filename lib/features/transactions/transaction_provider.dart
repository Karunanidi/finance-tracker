import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/data/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<TransactionModel>> build() async {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.getTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.addTransaction(transaction);
      return repository.getTransactions();
    });
  }
}
