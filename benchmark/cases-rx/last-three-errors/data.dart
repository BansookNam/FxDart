// Deterministic service log shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

// Oldest first — ~25% ERROR lines (numbered, so the last three are
// distinct), the rest WARN/INFO noise.
List<String> makeLogLines() {
  final rng = Lcg(77);
  return List.generate(n, (i) {
    final roll = rng.nextDouble();
    if (roll < 0.25) return 'ERROR checksum mismatch on chunk $i';
    if (roll < 0.5) return 'WARN  retrying registry ($i)';
    return 'INFO  sync heartbeat $i';
  });
}
