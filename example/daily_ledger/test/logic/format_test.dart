import 'package:daily_ledger/logic/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('money', () {
    test('formats with thousands separators and cents', () {
      expect(money(0), '\$0.00');
      expect(money(4.5), '\$4.50');
      expect(money(1234.5), '\$1,234.50');
      expect(money(-1234567.89), '-\$1,234,567.89');
    });

    test('sign follows the rounded value — no -\$0.00', () {
      expect(money(-0.004), '\$0.00');
      expect(money(-0.005), '-\$0.01');
    });
  });

  group('signedMoney', () {
    test('explicit plus for income, minus for spending', () {
      expect(signedMoney(5), '+\$5.00');
      expect(signedMoney(-5), '-\$5.00');
    });

    test('values rounding to zero carry no sign', () {
      expect(signedMoney(0), '\$0.00');
      expect(signedMoney(-0.004), '\$0.00');
      expect(signedMoney(0.004), '\$0.00');
    });
  });
}
