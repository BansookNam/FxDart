import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  final result = await fx([1, 2, 2, 3, 1, 4])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 100), a))
      .concurrent(3)
      .uniq()
      .toArray();

  print(result); // [1, 2, 3, 4] -- correct even with concurrent fetching
  print('took ${sw.elapsedMilliseconds}ms'); // ~200ms (2 batches of 3)
}
