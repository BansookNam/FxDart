import 'dart:async';

import 'package:fxdart/fxdart.dart';

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
  // Hand-rolled switch: remember which search is newest, and drop a stale
  // result when it finally lands.
  final results = <(String, int)>[];
  var epoch = 0;
  var last = Future<void>.value();
  final done = Completer<void>();
  final sub = queries().listen((q) {
    final mine = ++epoch;
    last = search(q).then((r) {
      if (mine == epoch) results.add(r);
    });
  }, onDone: done.complete);
  await done.future;
  await sub.cancel();
  await last;

  final lines = fx(results).map((r) => '${r.$2} results for "${r.$1}"').toList();
  lines.forEach(print);
  print('searches started: $searchesStarted, '
      'results delivered: ${results.length}');
}
