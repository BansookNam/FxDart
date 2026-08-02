import 'package:rxdart/rxdart.dart';

int fetched = 0;

// Paged orders API — pages 1-3 hold three orders each, page 4 is empty.
Future<List<String>> fetchPage(int page) async {
  fetched++;
  await Future.delayed(const Duration(milliseconds: 15));
  if (page > 3) return [];
  return [for (var i = 1; i <= 3; i++) 'order#${(page - 1) * 3 + i}'];
}

// An endless page cursor. async* is pause-aware, so under asyncMap's
// backpressure it advances only when the previous fetch completes.
// That pause contract is load-bearing: swap asyncMap for flatMap (or a
// plain listen) and this cursor runs away unboundedly. The pull side has
// no runaway mode to avoid.
Stream<int> pages() async* {
  var page = 1;
  while (true) {
    yield page++;
  }
}

Future<void> main() async {
  final orders = await pages()
      .asyncMap(fetchPage)
      .takeWhile((page) => page.isNotEmpty)
      .expand((page) => page)
      .toList();

  orders.forEach(print);
  print('pages fetched: $fetched');
}
