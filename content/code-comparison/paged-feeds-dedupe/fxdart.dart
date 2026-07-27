import 'package:fxdart/fxdart.dart';

class Event {
  final String id;
  final String msg;
  const Event(this.id, this.msg);
}

// Two log stores, paged 3 per call. The replica overlaps the primary:
// some events were shipped to both.
const primary = [
  [Event('e1', 'boot'), Event('e2', 'login user 7'), Event('e3', 'cache miss')],
  [Event('e4', 'queue drained'), Event('e5', 'login user 12'), Event('e6', 'gc pause 18ms')],
];
const replica = [
  [Event('e5', 'login user 12'), Event('e6', 'gc pause 18ms'), Event('e7', 'disk 81% full')],
  [Event('e8', 'cert renewed'), Event('e9', 'login user 3'), Event('e10', 'backup done')],
  [Event('e11', 'shutdown'), Event('e12', 'boot'), Event('e13', 'login user 9')],
];

int pagesFetched = 0;

Future<List<Event>> fetchPage(List<List<Event>> store, int page) async {
  pagesFetched++;
  await Future.delayed(const Duration(milliseconds: 10));
  return store[page];
}

FxAsync<Event> drain(List<List<Event>> store) =>
    fx(range(0, store.length)).toAsync().flatMap((p) => fetchPage(store, p));

Future<void> main() async {
  final events = await drain(primary)
      .concat(drain(replica))
      .uniqBy((e) => e.id)
      .take(8)
      .toList();
  print('first 8 unique events (primary first, then replica):');
  for (final e in events) {
    print('  ${e.id}  ${e.msg}');
  }
  print('pages fetched: $pagesFetched of 5');
}
