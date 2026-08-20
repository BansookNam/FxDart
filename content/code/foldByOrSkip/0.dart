import 'package:fxdart/fxdart.dart';

void main() {
  final txns = [
    (date: '2026-06-28', category: 'Food', amount: 31.10),
    (date: '2026-07-02', category: 'Food', amount: 12.50),
    (date: '2026-07-03', category: 'Transport', amount: 2.75),
    (date: '2026-07-05', category: 'Food', amount: 43.20),
    (date: '2026-08-01', category: 'Transport', amount: 50.00),
  ];

  // July's spend per category. One callback answers both questions:
  // "is this row in scope?" and "which bucket?" — null means skip.
  final july = foldByOrSkip(
    (t) => t.date.startsWith('2026-07') ? t.category : null,
    0.0,
    (double sum, t) => sum + t.amount,
    txns,
  );
  print(july);
  // {Food: 55.7, Transport: 2.75}

  // The same answer as two named steps. This is the one to write by default —
  // foldByOrSkip is what you drop to when a profile says the filter's
  // predicate is the cost.
  print(
    fx(txns)
        .filter((t) => t.date.startsWith('2026-07'))
        .foldBy((t) => t.category, 0.0, (sum, t) => sum + t.amount),
  );
  // {Food: 55.7, Transport: 2.75}
}
