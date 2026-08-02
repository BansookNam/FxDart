import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int fetched = 0;

// The example's 15 ms per fetch becomes Duration.zero at benchmark scale.
Future<List<String>> fetchPage(int page) async {
  fetched++;
  await Future<void>.delayed(Duration.zero);
  if (page > totalPages) return [];
  return [
    for (var i = 1; i <= pageSize; i++) 'order#${(page - 1) * pageSize + i}'
  ];
}

/// Page numbers without end — the crawl pulls one only when it is ready.
Iterable<int> pageNumbers() sync* {
  for (var page = 1;; page++) {
    yield page;
  }
}

Future<void> main() async {
  await bench(
    slug: 'crawl-the-pages',
    impl: 'fxdart',
    n: n,
    run: () async {
      fetched = 0;
      final orders = await fx(pageNumbers())
          .toAsync()
          .map(fetchPage)
          .takeWhile((page) => page.isNotEmpty)
          .flatMap((page) => page)
          .toList();
      return '${orders.length}|${orders.last}|pages=$fetched';
    },
  );
}
