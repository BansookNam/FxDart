import 'package:fxdart/fxdart.dart';

void main() {
  final steps = [1, 2, 3, 4];

  // scan emits the seed first: n values in, n + 1 out.
  print(fxScan((acc, a) => acc + a, 0, steps)); // (0, 1, 3, 6, 10)

  // mapAccum leaves the seed out: n values in, n out.
  print(fxMapAccum((acc, a) => acc + a, 0, steps)); // (1, 3, 6, 10)

  // Same as scan(...).drop(1), without the trailing drop:
  print(fx(steps).scan((acc, a) => acc + a, 0).drop(1).toList());
  // [1, 3, 6, 10]

  // Chain spelling; the accumulator may be a different type:
  final dirs = ['usr', 'local', 'bin'];
  final path = fx(dirs).mapAccum((String acc, s) => '$acc/$s', '').toList();
  print(path); // [/usr, /usr/local, /usr/local/bin]

  // Empty in, empty out — not even the seed:
  print(fxMapAccum((acc, a) => acc + a, 0, <int>[])); // ()
}
