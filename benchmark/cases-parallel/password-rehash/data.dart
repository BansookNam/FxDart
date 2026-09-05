// Deterministic credential table. Sized so the plain loop runs ~5 s.
import '../../harness.dart';
import 'work.dart';

final n = caseN(20000);

List<Credential> makeCredentials() {
  final rng = Lcg(7);
  return List.generate(
    n,
    (i) => Credential(i, rng.nextInt(1 << 30), rng.nextInt(1 << 40)),
  );
}

/// One number both sides must agree on.
int checksum(List<Derived> out) {
  var acc = 0;
  for (final d in out) {
    acc = (acc * 33 + d.key + d.user) & 0x1FFFFFFFFFFFFF;
  }
  return acc;
}
