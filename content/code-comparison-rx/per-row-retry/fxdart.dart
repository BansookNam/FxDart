import 'package:fxdart/fxdart.dart';

/// Six import rows; the even rows hit a flaky endpoint that fails exactly
/// once before succeeding. Per-row delays make completion order differ
/// from source order under concurrency.
const rows = [
  (1, 'alpha'),
  (2, 'bravo'),
  (3, 'charlie'),
  (4, 'delta'),
  (5, 'echo'),
  (6, 'foxtrot'),
];
const importMs = [0, 70, 30, 50, 30, 20, 40]; // indexed by row id

final attemptsByRow = <int, int>{};

Future<String> importRow((int, String) row) async {
  final (id, name) = row;
  final attempt = attemptsByRow.update(id, (n) => n + 1, ifAbsent: () => 1);
  await Future<void>.delayed(Duration(milliseconds: importMs[id]));
  if (id.isEven && attempt == 1) throw StateError('endpoint reset on $name');
  return 'row $id ($name) imported on attempt $attempt';
}

Future<void> main() async {
  // Two attempts per row, three rows in flight — each in-flight row
  // retries independently, and mapRetry under concurrent yields in
  // SOURCE order by construction.
  final results = await fx(rows)
      .toAsync()
      .mapRetry(2, importRow)
      .concurrent(3)
      .toList();

  results.forEach(print);
}
