// Async case (#31 cursor-lifetime): n sequential cursor reads inside the
// example's acquire/read/dispose bracket (Rx.using vs usingAsync). Headline
// 10,000 — the RxDartComparison async family's headline scale; reads are
// Duration.zero so the bracket machinery is what is measured.
import '../../harness.dart';

final n = caseN(10000);

/// n ledger rows, generated once and shared verbatim by both sides.
final ledgerRows = _makeRows();

List<String> _makeRows() {
  final rng = Lcg(31);
  return List.generate(n, (i) {
    final month = (1 + i ~/ 28 % 12).toString().padLeft(2, '0');
    final day = (1 + i % 28).toString().padLeft(2, '0');
    final balance = ((100 + rng.nextInt(99900)) / 100).toStringAsFixed(2);
    return '2026-$month-$day  balance $balance';
  });
}

/// A fake database cursor: sequential reads plus a [closed] flag the
/// checksum can attest to. Reading after close throws.
class LedgerCursor {
  var closed = false;

  int get length => ledgerRows.length;

  Future<String> read(int i) async {
    if (closed) throw StateError('read after close');
    await Future<void>.delayed(Duration.zero);
    return ledgerRows[i];
  }

  void close() => closed = true;
}
