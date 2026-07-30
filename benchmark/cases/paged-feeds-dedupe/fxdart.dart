import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

int pagesFetched = 0;

Future<List<Event>> fetchPage(List<List<Event>> store, int page) async {
  pagesFetched++;
  await Future<void>.delayed(Duration.zero);
  return store[page];
}

FxAsync<Event> drain(List<List<Event>> store) =>
    fx(range(0, store.length)).toAsync().flatMap((p) => fetchPage(store, p));

Future<void> main() async {
  final primary = makePrimary();
  final replica = makeReplica();
  await bench(
    slug: 'paged-feeds-dedupe',
    impl: 'fxdart',
    n: n,
    run: () async {
      pagesFetched = 0;
      final events = await drain(primary)
          .concat(drain(replica))
          .uniqBy((e) => e.id)
          .take(takeN)
          .toList();
      return '${events.length}|${events.first.id}|${events.last.id}'
          '|pages=$pagesFetched';
    },
  );
}
