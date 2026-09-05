// Deterministic log file. Sized so the plain loop runs ~5 s.
import '../../harness.dart';
import 'work.dart';

final n = caseN(1500000);

const _levels = ['INFO', 'WARN', 'ERROR', 'DEBUG'];
const _routes = [
  '/api/orders',
  '/api/users',
  '/health',
  '/api/carts/checkout',
  '/static/app.js',
];

List<LogLine> makeLines() {
  final rng = Lcg(11);
  return List.generate(n, (i) {
    final level = _levels[rng.nextInt(_levels.length)];
    final route = _routes[rng.nextInt(_routes.length)];
    final ms = rng.nextInt(4000);
    final code = rng.nextDouble() < 0.08 ? 500 : 200;
    return LogLine(i, '$level $route $code ${ms}ms u${i % 9973}');
  });
}

/// One number all four variants must agree on.
int checksum(List<Fingerprint> out) {
  var acc = 0;
  for (final f in out) {
    acc = (acc * 31 + f.hash + f.digits) & 0x1FFFFFFFFFFFFF;
  }
  return acc;
}
