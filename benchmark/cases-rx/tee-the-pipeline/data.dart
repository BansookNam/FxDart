// Sync-shaped example (async: false), but the rx side still drives every
// element through the event loop (publish/connect delivers each reading to
// two listeners as stream events). 1,000,000 readings shared verbatim by
// both sides — one rx iteration stays well under 2 s.
import '../../harness.dart';

final n = caseN(1000000);

/// n sensor readings, values 0..999, replacing the example's six literals.
List<int> makeReadings() {
  final rng = Lcg(48);
  return List.generate(n, (i) => rng.nextInt(1000));
}

final baseReadings = makeReadings();
