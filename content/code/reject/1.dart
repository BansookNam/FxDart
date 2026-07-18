import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // rejectAsync delegates to filterAsync's concurrent predicate evaluation.
  final result = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .reject((a) async {
        await delay(Duration(milliseconds: 150), null);
        return a.isEven;
      })
      .concurrent(3)
      .toArray();

  print(result); // [1, 3, 5]
  print('took ${sw.elapsedMilliseconds}ms'); // ~300ms, not ~900ms
}
