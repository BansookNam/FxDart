// Deterministic n-tick price walk shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

List<double> makeTicks() {
  final rng = Lcg(13);
  var price = 100.0;
  return List.generate(n, (i) {
    // Signed cent-sized step in [-1.00, +1.00].
    price += (rng.nextInt(201) - 100) / 100;
    return price;
  });
}
