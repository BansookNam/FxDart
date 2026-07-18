import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await fx(['a', 'b', 'c'])
      .toAsync()
      .map((a) => delay(Duration(milliseconds: 50), a))
      .zipWithIndex()
      .toArray();

  print(result); // [(0, a), (1, b), (2, c)]
}
