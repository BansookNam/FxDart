// Constants shared verbatim by both sides. The example compounds over 6
// years; the scaled case compounds over n periods (headline 1,000,000; the
// runner also runs N=100 and N=10,000 via BENCH_N). The per-period rate is
// tiny so the balance stays finite (1000 * (1 + 5e-7)^1e6 ~ 1648.72) instead
// of overflowing to Infinity at the example's 5%. At small N the total is
// simply smaller — both sides format it with the same toStringAsFixed(2).
import '../../harness.dart';

final n = caseN(1000000);

const principal = 1000.0;
const rate = 0.0000005;
