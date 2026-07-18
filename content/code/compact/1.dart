import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Fetch concurrently -- some "lookups" miss and resolve to null -- then
  // compact drops the misses and narrows the type to non-nullable.
  final ids = [1, 2, 3, 4];
  final fetched = fx(ids)
      .toAsync()
      .map((id) => delay(Duration(milliseconds: 150), id.isEven ? null : id))
      .concurrent(4);

  final found = await fxAsync(compactAsync(fetched)).toArray();

  print(found); // [1, 3]
  print('took ${sw.elapsedMilliseconds}ms'); // ~150ms
}
