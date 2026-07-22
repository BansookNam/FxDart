/// Money formatting — pure, shared by logic/ and ui/ (Round 5: previously a
/// private copy in stats.dart drifted from the UI formatter; one source now).
library;

/// `1234.5` → `$1,234.50` (own tiny formatter; no intl dependency).
String money(double value) {
  final sign = value < 0 ? '-' : '';
  final cents = (value.abs() * 100).round();
  final whole = cents ~/ 100;
  final frac = (cents % 100).toString().padLeft(2, '0');
  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '$sign\$$buf.$frac';
}

/// Signed variant with an explicit plus for income.
String signedMoney(double value) =>
    value > 0 ? '+${money(value)}' : money(value);
