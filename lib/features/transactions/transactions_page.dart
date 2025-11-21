import 'package:auto_size_text/auto_size_text.dart';
import 'package:finance_tracker/features/transactions/transaction_provider.dart';
import 'package:finance_tracker/widgets/transaction_card.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _searchQuery = '';
  String _filterCategory = 'All';
  bool? _filterIsExpense;

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionListProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFF6F7F9),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: AutoSizeText(
                        'Transactions',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                        maxLines: 1,
                        minFontSize: 20,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Color(0xFF1E293B),
                            ),
                            onPressed: () {
                              // TODO: Implement search
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.filter_list,
                              color: Color(0xFF1E293B),
                            ),
                            onPressed: _showFilterDialog,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            transactionsState.when(
              data: (transactions) {
                // Apply filters
                var filteredTransactions = transactions.where((transaction) {
                  final matchesSearch =
                      transaction.description.toLowerCase().contains(
                        _searchQuery,
                      ) ||
                      transaction.category.toLowerCase().contains(_searchQuery);

                  final matchesCategory =
                      _filterCategory == 'All' ||
                      transaction.category == _filterCategory;

                  final matchesType =
                      _filterIsExpense == null ||
                      transaction.isExpense == _filterIsExpense;

                  return matchesSearch && matchesCategory && matchesType;
                }).toList();

                if (filteredTransactions.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Group transactions by date
                final groupedTransactions = <String, List<TransactionModel>>{};
                for (var transaction in filteredTransactions) {
                  final dateKey = _getDateKey(transaction.date);
                  if (!groupedTransactions.containsKey(dateKey)) {
                    groupedTransactions[dateKey] = [];
                  }
                  groupedTransactions[dateKey]!.add(transaction);
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final dateKey = groupedTransactions.keys.elementAt(index);
                      final transactionsForDate = groupedTransactions[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16, top: 8),
                            child: Text(
                              dateKey,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          ...transactionsForDate.map(
                            (transaction) => TransactionCard(
                              transaction: transaction,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }, childCount: groupedTransactions.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(transactionListProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                    'All',
                    'Food',
                    'Transport',
                    'Shopping',
                    'Entertainment',
                    'Health',
                    'Bills',
                    'Salary',
                  ].map((category) {
                    return FilterChip(
                      label: Text(category, overflow: TextOverflow.ellipsis),
                      selected: _filterCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _filterCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterIsExpense == null,
                  onSelected: (selected) {
                    setState(() {
                      _filterIsExpense = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Expenses'),
                  selected: _filterIsExpense == true,
                  onSelected: (selected) {
                    setState(() {
                      _filterIsExpense = true;
                    });
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Income'),
                  selected: _filterIsExpense == false,
                  onSelected: (selected) {
                    setState(() {
                      _filterIsExpense = false;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterCategory = 'All';
                _filterIsExpense = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
