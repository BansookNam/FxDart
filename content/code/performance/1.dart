import 'package:fxdart/fxdart.dart';

// Rule 3: pick the operator that produces the answer you actually want.
// groupBy keeps every element; foldBy keeps only the running total.
void main() {
  final txns = [
    ('food', 12.5),
    ('rent', 800.0),
    ('food', 8.0),
    ('travel', 30.0),
    ('rent', 200.0),
  ];

  // Allocates a List per key, then throws the lists away.
  final viaGroup = fx(txns)
      .groupBy((t) => t.$1)
      .map((k, v) => MapEntry(k, fx(v).sumBy((t) => t.$2)));
  print(viaGroup);

  // Accumulates straight into the result map — no per-key lists at all.
  final viaFold = fx(txns).foldBy((t) => t.$1, 0.0, (sum, t) => sum + t.$2);
  print(viaFold); // same answer

  // Same idea: countBy is foldBy with a counter, already named.
  print(fx(txns).countBy((t) => t.$1));

  // Rule 4: a chain you iterate more than once re-runs its upstream every
  // time. Materialize once when you need the result twice.
  var runs = 0;
  final lazy = fx(txns).map((t) {
    runs++;
    return t.$1;
  }).distinct();
  lazy.toList();
  lazy.toList();
  print('lazy, two passes: $runs callback calls');

  runs = 0;
  final once = fx(txns).map((t) {
    runs++;
    return t.$1;
  }).uniqStrict();
  once.toList();
  once.toList();
  print('uniqStrict, two passes: $runs callback calls');
}
