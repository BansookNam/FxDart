import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Fetch each profile concurrently, then pluck the id out of each one.
  // No chain method exists for pluck, so wrap the data-first result with
  // fxAsync(...) to keep chaining.
  final userIds = [1, 2, 3];
  final fetched = fx(userIds)
      .toAsync()
      .map((id) => delay(Duration(milliseconds: 150), {'id': id, 'name': 'user$id'}))
      .concurrent(3);

  final ids = await fxAsync(pluckAsync('id', fetched)).toList();

  print(ids); // [1, 2, 3]
  print('took ${sw.elapsedMilliseconds}ms'); // ~150ms, not ~450ms
}
