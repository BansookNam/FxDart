// Deterministic visit log shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

typedef Visit = ({String user, String at});

// n visits drawn from a universe of n/10 accounts — the dedupe has real
// work at every scale (~10 visits per user). User picks come from
// nextDouble (the LCG's low bits are degenerate); timestamps are a plain
// formula over i so the log stays oldest-first.
List<Visit> makeVisits() {
  final rng = Lcg(55);
  final universe = n ~/ 10;
  return List.generate(n, (i) {
    final u = (rng.nextDouble() * universe).floor();
    final hh = 9 + i * 8 ~/ n;
    final mm = i % 60;
    return (
      user: 'u$u',
      at: '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}',
    );
  });
}
