/// Supported currencies
enum Currency {
  idr('IDR', 'Rp', 'Indonesian Rupiah'),
  usd('USD', '\$', 'US Dollar');

  final String code;
  final String symbol;
  final String name;

  const Currency(this.code, this.symbol, this.name);

  /// Format amount with currency
  String format(double amount) {
    if (this == Currency.idr) {
      // IDR: Rp 1.000.000
      return '$symbol ${_formatIDR(amount)}';
    } else {
      // USD: $1,000.00
      return '$symbol${_formatUSD(amount)}';
    }
  }

  String _formatIDR(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  String _formatUSD(double amount) {
    final intPart = amount.toInt();
    final decimalPart = ((amount - intPart) * 100).toInt();

    final intStr = intPart.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intStr[i]);
    }

    buffer.write('.');
    buffer.write(decimalPart.toString().padLeft(2, '0'));

    return buffer.toString();
  }

  /// Get currency from code
  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => Currency.idr, // Default to IDR
    );
  }
}
