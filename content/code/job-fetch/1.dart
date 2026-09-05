import 'package:fxdart/fxdart.dart';

Future<String> fetchUser(int id) async {
  await sleep(const Duration(milliseconds: 100));
  return 'user$id';
}

Future<void> main() async {
  final sw = Stopwatch()..start();
  final bad = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .mapOrAccumulate<String, String>((r, id) async {
    r.ensure(id.isOdd, () => 'id $id is even');
    return await fetchUser(id);
  }, concurrency: 3);
  print(bad); // Left([id 2 is even, id 4 is even, id 6 is even])
  print('6 ids, ~${sw.elapsedMilliseconds ~/ 100 * 100}ms'); // ~200ms
}
