import 'package:rxdart/rxdart.dart';

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
  final results = await Stream.fromIterable(rows)
      // Each row gets its own retrying inner stream, 3 subscribed at a
      // time — but flatMap emits in COMPLETION order, so every result
      // must carry its row id for the sort back to source order.
      .flatMap(
          (row) => Rx.retry(() => Rx.fromCallable(() => importRow(row)), 1)
              .map((line) => (row.$1, line)),
          maxConcurrent: 3)
      .toList();

  results.sort((a, b) => a.$1.compareTo(b.$1));
  for (final (_, line) in results) {
    print(line);
  }
}
