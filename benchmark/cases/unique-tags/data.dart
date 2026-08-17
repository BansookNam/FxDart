// Deterministic n-post corpus shared verbatim by both sides (headline
// 1,000,000; the runner also runs N=100 and N=10,000 via BENCH_N).
// Tag cardinality is bounded (500 distinct tags) so the dedupe + sort at the
// end stays realistic: ~3n tag occurrences collapse to a small sorted list.
// At small N fewer than 500 distinct tags appear — fine, the checksum's
// length|first|last stays well-defined.
import '../../harness.dart';

final n = caseN(1000000);

class Post {
  final String title;
  final List<String> tags;
  const Post(this.title, this.tags);
}

final List<String> _tagPool = List.generate(
  500,
  (i) => 'tag-${i.toString().padLeft(3, '0')}',
);

List<Post> makePosts() {
  final rng = Lcg(4);
  return List.generate(n, (i) {
    final count = 2 + rng.nextInt(3); // 2..4 tags per post
    final tags = List.generate(
      count,
      (_) => _tagPool[rng.nextInt(_tagPool.length)],
    );
    return Post('Post #$i', tags);
  });
}
