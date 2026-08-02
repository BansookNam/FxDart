import 'package:fxdart/fxdart.dart';

/// A fake database cursor: sequential reads plus a [closed] flag the
/// output can attest to. Reading after close throws.
class LedgerCursor {
  static const _rows = [
    '2026-08-01  balance 120.00',
    '2026-08-02  balance 84.50',
    '2026-08-03  balance 210.25',
    '2026-08-04  balance 45.00',
    '2026-08-05  balance 99.90',
  ];

  var closed = false;

  int get length => _rows.length;

  Future<String> read(int i) async {
    if (closed) throw StateError('read after close');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return _rows[i];
  }

  void close() => closed = true;
}

Future<void> main() async {
  late final LedgerCursor cursor;

  // The bracket: the resource is acquired on the first pull, read lazily,
  // and released exactly once — after the last row, or right before an
  // error would propagate.
  final rows = await fxAsync(usingAsync(
    () => cursor = LedgerCursor(),
    (c) => toAsync(Iterable.generate(c.length, c.read)),
    (c) => c.close(),
  )).toList();

  rows.forEach(print);
  print('closed: ${cursor.closed}');
}
