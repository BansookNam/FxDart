// Deterministic access log shared verbatim by both sides (headline 1M).
import '../../harness.dart';

final n = caseN(1000000);

class Req {
  final String endpoint;
  final int ms;
  final int status;
  const Req(this.endpoint, this.ms, this.status);
}

// Endpoint count derives from n (20 at the 1M headline, as before) so each
// endpoint keeps enough samples that the per-endpoint p95s stay distinct at
// small N — verified for this seed at N=100/10,000/1,000,000.
final _endpoints = List<String>.generate(
    (n ~/ 500).clamp(4, 20).toInt(), (i) => '/ep${i.toString().padLeft(2, '0')}');

List<Req> makeReqs() {
  final rng = Lcg(5);
  return List.generate(n, (i) {
    final e = rng.nextInt(_endpoints.length);
    // ~2% of requests fail and are filtered out.
    final status = rng.nextInt(50) == 0 ? 503 : 200;
    // A per-endpoint base offset (50ms apart, jitter < 400ms) keeps every
    // endpoint's p95 distinct — the -p95 sort must be tie-free because
    // package:collection's sortedBy and fxdart's sortBy order ties
    // differently.
    return Req(_endpoints[e], (e + 1) * 50 + rng.nextInt(400), status);
  });
}
