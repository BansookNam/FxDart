import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

/// The example's second spelling, `foldByOrSkip`. Not what the headline bar
/// measures — that is the composable chain the page presents as the default —
/// but run once here so the two spellings cannot drift apart.
String _strictChecksum(List<Tx> txns) {
  final byCategory = fx(txns).foldByOrSkip(
    (t) => t.date.startsWith('2026-07') ? t.category : null,
    0.0,
    (sum, t) => sum + t.amount,
  );
  final lines = fx(byCategory.entries)
      .map((kv) => (kv.key, kv.value))
      .sortBy((row) => -row.$2)
      .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)}')
      .toList();
  return '${lines.length}|${lines.first}|${lines.last}';
}

String _chainChecksum(List<Tx> txns) {
  final byCategory = fx(txns)
      .filter((t) => t.date.startsWith('2026-07'))
      .foldBy((t) => t.category, 0.0, (sum, t) => sum + t.amount);
  // The example joins the formatted rows; the checksum stays O(1) instead
  // of embedding all 250 lines.
  final lines = fx(byCategory.entries)
      .map((kv) => (kv.key, kv.value))
      .sortBy((row) => -row.$2)
      .map((row) => '${row.$1}: \$${row.$2.toStringAsFixed(2)}')
      .toList();
  return '${lines.length}|${lines.first}|${lines.last}';
}

Future<void> main() async {
  final txns = makeTxns();
  // Outside the timed closure: the headline bar measures the chain alone.
  if (_chainChecksum(txns) != _strictChecksum(txns)) {
    throw StateError('foldByOrSkip disagrees with the composable chain');
  }
  await bench(
    slug: 'monthly-category-report',
    impl: 'fxdart',
    n: n,
    run: () => _chainChecksum(txns),
  );
}
