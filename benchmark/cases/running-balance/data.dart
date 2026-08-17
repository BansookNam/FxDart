// Deterministic 1,000,000-transaction statement shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

class Tx {
  final String date;
  final String label;
  final double amount; // signed: deposits positive, spending negative
  const Tx(this.date, this.label, this.amount);
}

const _labels = [
  'Salary',
  'Rent',
  'Green Grocer',
  'Refund',
  'Electric Co',
  'Cafe Aroma',
  'Metro',
  'Taxi',
  'Book Nook',
  'Gym One',
];

List<Tx> makeTxns() {
  final rng = Lcg(2);
  return List.generate(n, (i) {
    final month = 1 + rng.nextInt(12);
    final day = 1 + rng.nextInt(28);
    final label = _labels[rng.nextInt(_labels.length)];
    // Roughly 1 in 8 transactions is a deposit, the rest are spending.
    final deposit = rng.nextInt(8) == 0;
    final cents = 100 + rng.nextInt(9900);
    return Tx(
      '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      label,
      deposit ? cents / 100 : -cents / 100,
    );
  });
}
