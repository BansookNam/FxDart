import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final names = ['ann', 'bo', 'cara', 'di'];

  // TODO: use the *Async twin of `map` (data-first, on toAsync(names)) to
  // uppercase every name, then toArrayAsync to collect the result.
  final shouted = await toArrayAsync(toAsync(names));

  print(shouted); // currently [ann, bo, cara, di] — should be uppercase
}
