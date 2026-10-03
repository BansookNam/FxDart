import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // Fetch each candidate concurrently, then keep only the ones whose
  // matching selector says "keep".
  final names = ['alice', 'bob', 'carol', 'dave'];
  final fetched = fx(names)
      .toAsync()
      .map((n) => fxDelay(Duration(milliseconds: 100), n))
      .concurrent(4);

  final selected =
      await fxAsync(fxCompressAsync([true, false, true, false], fetched))
          .toList();

  print(selected); // [alice, carol]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
