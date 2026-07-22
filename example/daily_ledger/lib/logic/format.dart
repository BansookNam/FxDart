/// Money formatting — pure, shared by logic/ and ui/ (Round 5: previously a
/// private copy in stats.dart drifted from the UI formatter; one source now).
library;

/// `1234.5` → `$1,234.50` (own tiny formatter; no intl dependency).
String money(double value) {
  final cents = (value.abs() * 100).round();
  // Sign follows the ROUNDED value: -0.004 must print $0.00, not -$0.00.
  final sign = value < 0 && cents > 0 ? '-' : '';
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

/// Signed variant with an explicit plus for income. Values that round to
/// zero carry no sign at all.
String signedMoney(double value) {
  final rounded = (value * 100).round();
  if (rounded == 0) return money(0);
  return rounded > 0 ? '+${money(value)}' : money(value);
}
