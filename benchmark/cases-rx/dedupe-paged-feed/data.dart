// Deterministic paged product feed, shared verbatim by both sides.
// Pages of 10 whose boundaries overlap by 2 (adjacent dups), plus — like the
// example's page 3 re-serving #101 — every 7th page's last slot revisits an
// item from a much earlier page (a non-adjacent dup, which is what forces
// distinctUnique over plain distinct on the rx side).
import '../../harness.dart';

final n = caseN(1000000);

const pageSize = 10;
const overlap = 2;
final int numPages = n ~/ pageSize;

List<List<(int, String)>> makePages() {
  const step = pageSize - overlap;
  return List.generate(numPages, (p) {
    final page = List.generate(pageSize, (j) {
      final id = 101 + p * step + j;
      return (id, 'Item $id');
    });
    if (p % 7 == 3) {
      final earlierId = 101 + (p ~/ 2) * step;
      page[pageSize - 1] = (earlierId, 'Item $earlierId');
    }
    return page;
  });
}
