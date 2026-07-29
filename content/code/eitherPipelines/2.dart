import 'package:fxdart/fxdart.dart';

Future<String> fetchUser(int id) async {
  await sleep(const Duration(milliseconds: 100));
  return 'user$id';
}

Future<void> main() async {
  // Fail-slow validation over an async chain, 3 elements in flight at a
  // time — results stay in order, and EVERY failure is collected.
  final sw = Stopwatch()..start();
  final ok = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .mapOrAccumulate<String, String>((r, id) async {
    return await fetchUser(id);
  }, concurrency: 3);
  print(ok); // Right([user1, user2, user3, user4, user5, user6])
  print('6 fetches, ~${sw.elapsedMilliseconds ~/ 100 * 100}ms'); // ~200ms

  final bad = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .mapOrAccumulate<String, String>((r, id) async {
    r.ensure(id.isOdd, () => 'id $id is even');
    return await fetchUser(id);
  }, concurrency: 3);
  print(bad); // Left([id 2 is even, id 4 is even, id 6 is even])
}
