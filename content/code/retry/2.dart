import 'package:fxdart/fxdart.dart';

final attempts = <String, int>{};

/// Every row fails on its first import call.
Future<String> importRow(String row) async {
  final n = (attempts[row] ?? 0) + 1;
  attempts[row] = n;
  await Future.delayed(const Duration(milliseconds: 10));
  if (n == 1) throw Exception('lock contention on $row');
  return 'imported $row';
}

void main() async {
  final rows = ['r1', 'r2', 'r3'];

  // TODO: this pipeline dies on the first flaky row. Give each row a
  // retry budget of 2 by swapping .map for .mapRetry(2, ...).
  final results = await fx(rows)
      .toAsync()
      .map(importRow) // ← change me
      .toList();

  results.forEach(print);
  // Expected once solved:
  // imported r1
  // imported r2
  // imported r3
}
