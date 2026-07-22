import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // zipAsync pulls both sources in parallel per pair, so it takes as long
  // as the slower side per pair — not the sum of both:
  final names =
      fx([1, 2, 3]).toAsync().map((a) => delay(Duration(milliseconds: 100), 'n$a'));
  final ages =
      fx([10, 20, 30]).toAsync().map((a) => delay(Duration(milliseconds: 100), a));

  final result = await toListAsync(zipAsync(names, ages));
  print(result); // [(n1, 10), (n2, 20), (n3, 30)]
  print('took ${sw.elapsedMilliseconds}ms'); // ~300ms, not 600ms
}
