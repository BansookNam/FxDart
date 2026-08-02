import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// Simulated typing: each new query replaces the previous one.
Stream<String> queries() {
  final c = StreamController<String>();
  const events = [(0, 'fx'), (40, 'fxdar'), (400, 'fxdart')];
  for (final (ms, q) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(q));
  }
  Timer(const Duration(milliseconds: 500), c.close);
  return c.stream;
}

const hits = {'fx': 19, 'fxdar': 7, 'fxdart': 12};

var searchesStarted = 0;

Future<(String, int)> search(String q) async {
  searchesStarted++;
  await Future.delayed(const Duration(milliseconds: 150));
  return (q, hits[q]!);
}

Future<void> main() async {
  final results = await queries()
      .switchMap((q) => Stream.fromFuture(search(q)))
      .toList();

  for (final (q, n) in results) {
    print('$n results for "$q"');
  }
  print('searches started: $searchesStarted, '
      'results delivered: ${results.length}');
}
