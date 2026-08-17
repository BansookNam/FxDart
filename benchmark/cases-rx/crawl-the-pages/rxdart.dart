// Faithful scaled copy of the RxDart panel. The panel's pipeline only uses
// core Stream operators (asyncMap / takeWhile / expand), so no rxdart import
// is needed here — the example's point is that asyncMap's pause contract
// keeps the endless cursor bounded.
import '../../harness.dart';
import 'data.dart';

int fetched = 0;

// The example's 15 ms per fetch becomes Duration.zero at benchmark scale.
Future<List<String>> fetchPage(int page) async {
  fetched++;
  await Future<void>.delayed(Duration.zero);
  if (page > totalPages) return [];
  return [
    for (var i = 1; i <= pageSize; i++) 'order#${(page - 1) * pageSize + i}',
  ];
}

// An endless page cursor. async* is pause-aware, so under asyncMap's
// backpressure it advances only when the previous fetch completes.
Stream<int> pages() async* {
  var page = 1;
  while (true) {
    yield page++;
  }
}

Future<void> main() async {
  await bench(
    slug: 'crawl-the-pages',
    impl: 'rxdart',
    n: n,
    run: () async {
      fetched = 0;
      final orders = await pages()
          .asyncMap(fetchPage)
          .takeWhile((page) => page.isNotEmpty)
          .expand((page) => page)
          .toList();
      return '${orders.length}|${orders.last}|pages=$fetched';
    },
  );
}
