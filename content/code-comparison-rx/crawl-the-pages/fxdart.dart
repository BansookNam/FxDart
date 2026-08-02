import 'package:fxdart/fxdart.dart';

int fetched = 0;

// Paged orders API — pages 1-3 hold three orders each, page 4 is empty.
Future<List<String>> fetchPage(int page) async {
  fetched++;
  await Future.delayed(const Duration(milliseconds: 15));
  if (page > 3) return [];
  return [for (var i = 1; i <= 3; i++) 'order#${(page - 1) * 3 + i}'];
}

/// Page numbers without end — the crawl pulls one only when it is ready.
Iterable<int> pageNumbers() sync* {
  for (var page = 1;; page++) {
    yield page;
  }
}

Future<void> main() async {
  final orders = await fx(pageNumbers())
      .toAsync()
      .map(fetchPage)
      .takeWhile((page) => page.isNotEmpty)
      .flatMap((page) => page)
      .toList();

  orders.forEach(print);
  print('pages fetched: $fetched');
}
