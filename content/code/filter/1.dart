import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // whereAsync has its own dedicated concurrent path: predicates for
  // several elements run in parallel, but passing values are still
  // released downstream in the original order.
  final result = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .where((a) async {
        await delay(Duration(milliseconds: 150), null);
        return a.isEven;
      })
      .concurrent(3)
      .toList();

  print(result); // [2, 4, 6]
  print('took ${sw.elapsedMilliseconds}ms'); // ~300ms, not ~900ms
}
