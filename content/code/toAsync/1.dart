import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // These three Futures are created right here, eagerly — Dart starts a
  // Future's work the moment it's constructed, not when it's awaited.
  // By the time toAsync/toListAsync touch them, all three are already
  // racing in parallel, so the total time is ~200ms, not ~600ms.
  final alreadyStarted = toAsync([
    delay(const Duration(milliseconds: 200), 'a'),
    delay(const Duration(milliseconds: 200), 'b'),
    delay(const Duration(milliseconds: 200), 'c'),
  ]);
  print(await toListAsync(alreadyStarted)); // [a, b, c]
  print('eager futures: ${sw.elapsedMilliseconds}ms'); // ~200ms

  // Contrast: mapAsync creates one Future per element, lazily, only when
  // pulled — so without concurrent(n) they run one at a time.
  sw.reset();
  final lazyPerPull = await fx(['x', 'y', 'z'])
      .toAsync()
      .map((a) => delay(const Duration(milliseconds: 200), a))
      .toList();
  print(lazyPerPull); // [x, y, z]
  print('lazy pulls: ${sw.elapsedMilliseconds}ms'); // ~600ms
}
