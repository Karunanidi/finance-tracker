import 'package:finance_tracker/core/models/currency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit for managing currency selection
class CurrencyCubit extends Cubit<Currency> {
  static const String _currencyKey = 'selected_currency';

  CurrencyCubit() : super(Currency.idr) {
    _loadCurrency();
  }

  /// Load saved currency from storage
  Future<void> _loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currencyCode = prefs.getString(_currencyKey);

      if (currencyCode != null) {
        emit(Currency.fromCode(currencyCode));
      }
    } catch (e) {
      // If error, keep default IDR
      emit(Currency.idr);
    }
  }

  /// Change currency
  Future<void> changeCurrency(Currency currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency.code);
      emit(currency);
    } catch (e) {
      // Handle error silently, keep current currency
    }
  }

  /// Get current currency symbol
  String get symbol => state.symbol;

  /// Get current currency code
  String get code => state.code;

  /// Format amount with current currency
  String format(double amount) => state.format(amount);
}
