// Deterministic file download manifest shared verbatim by both sides.
// Async case: the example's per-file transfer times
// (10-30 ms) all become Duration.zero, so `ms` is kept in the model
// but is always 0 — the 3-wide download window is what is being measured.
// Headline 100,000 — the async family's shared headline scale. It has to
// clear the runner's fixed N=10,000 pass, or the third set of bars on the
// page would just restate the second.
import '../../harness.dart';

final n = caseN(100000);

class FileSpec {
  final String name;
  final int kb;
  final int ms; // fixed simulated transfer time (always 0 in the benchmark)
  const FileSpec(this.name, this.kb, this.ms);
}

List<FileSpec> makeFiles() {
  final rng = Lcg(9);
  return List.generate(n, (i) {
    return FileSpec('file-$i.bin', 1 + rng.nextInt(1000), 0);
  });
}
