import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // mapEffectAsync -- same execution engine as mapAsync, used here to
  // fire off a "save to db" side effect while producing a result.
  final saved = <int>[];
  final result = await fx([1, 2, 3, 4])
      .toAsync()
      .mapEffect((a) async {
        await delay(Duration(milliseconds: 100), null);
        saved.add(a);
        return a * a;
      })
      .concurrent(4)
      .toArray();

  print(result); // [1, 4, 9, 16]
  print(saved.length); // 4
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms with concurrency
}
