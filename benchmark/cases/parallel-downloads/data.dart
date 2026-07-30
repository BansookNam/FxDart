// Deterministic file download manifest shared verbatim by both sides
// (headline 5,000). Async case: the example's per-file transfer times
// (10-30 ms) all become Duration.zero, so `ms` is kept in the model
// but is always 0 — the 3-wide download window is what is being measured.
import '../../harness.dart';

final n = caseN(5000);

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
