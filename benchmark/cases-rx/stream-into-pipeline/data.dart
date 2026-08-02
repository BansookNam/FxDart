// Async case: a push stream bridged into each side's pipeline. The
// example's Timer-scheduled seven-line feed becomes an immediate
// Stream.fromIterable over this list — identical shape on both sides,
// zero wall-clock (see cases-rx/AUTHORING.md, "Event fixtures at scale").
import '../../harness.dart';

final n = caseN(10000);

const _warnBodies = [
  'disk 81% full',
  'latency 900ms',
  'retry queue at 12',
  'cpu pinned',
];
const _infoBodies = ['service up', 'heartbeat', 'sync done', 'cache warm'];

/// n log lines, ~35% warnings, each tagged with its index so every
/// formatted warning is distinct.
List<String> makeLines() {
  final rng = Lcg(49);
  return List.generate(n, (i) {
    return rng.nextDouble() < 0.35
        ? 'warn: ${_warnBodies[rng.nextInt(_warnBodies.length)]} #$i'
        : 'info: ${_infoBodies[rng.nextInt(_infoBodies.length)]} #$i';
  });
}

final lines = makeLines();
