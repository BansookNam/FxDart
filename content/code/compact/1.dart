import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Fetch concurrently -- some "lookups" miss and resolve to null -- then
  // nonNullsAsync drops the misses and narrows the type to non-nullable.
  final ids = [1, 2, 3, 4];
  final fetched = fx(ids)
      .toAsync()
      .map((id) => delay(Duration(milliseconds: 150), id.isEven ? null : id))
      .concurrent(4);

  // There is no async .nonNulls getter, so use the top-level form here.
  // FxTS alias: compactAsync(fetched) does the same thing.
  final found = await fxAsync(nonNullsAsync(fetched)).toList();

  print(found); // [1, 3]
  print('took ${sw.elapsedMilliseconds}ms'); // ~150ms
}
