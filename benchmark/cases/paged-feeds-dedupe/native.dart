import '../../harness.dart';
import 'data.dart';

int pagesFetched = 0;

Future<List<Event>> fetchPage(List<List<Event>> store, int page) async {
  pagesFetched++;
  await Future<void>.delayed(Duration.zero);
  return store[page];
}

Future<void> main() async {
  final primary = makePrimary();
  final replica = makeReplica();
  await bench(
    slug: 'paged-feeds-dedupe',
    impl: 'native',
    n: n,
    run: () async {
      pagesFetched = 0;
      final events = <Event>[];
      final seen = <String>{};
      outer:
      for (final store in [primary, replica]) {
        for (var page = 0; page < store.length; page++) {
          for (final e in await fetchPage(store, page)) {
            if (!seen.add(e.id)) continue;
            events.add(e);
            if (events.length == takeN) break outer;
          }
        }
      }
      return '${events.length}|${events.first.id}|${events.last.id}'
          '|pages=$pagesFetched';
    },
  );
}
