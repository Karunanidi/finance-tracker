class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final bool isExpense;
  final String? receiptUrl;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.isExpense,
    this.receiptUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      isExpense: json['is_expense'] as bool,
      receiptUrl: json['receipt_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'is_expense': isExpense,
      'receipt_url': receiptUrl,
    };
  }
}
