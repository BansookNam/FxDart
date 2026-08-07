import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // The index is the element's position in the SOURCE, so the last element
  // arrives first carrying the highest index.
  final seen = <String>[];
  foldRightWithIndex(0, (acc, String a, i) {
    seen.add('$i:$a');
    return acc;
  }, ['a', 'b', 'c']);
  print(seen); // [2:c, 1:b, 0:a]

  print(fx([1, 2, 3]).foldRightWithIndex<int>(0, (acc, a, i) => acc + a * i));
  // 8

  // Async drains the stream first — there is no end to start from until it
  // has arrived.
  final source = toAsync([1, 2, 3]);
  print(await foldRightAsync<int, int>(0, (acc, a) => a - acc, source)); // 2
}
