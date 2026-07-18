import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final rowA = fx([1, 2, 3]).toAsync().map((a) => delay(Duration(milliseconds: 50), a));
  final rowB = fx([4, 5, 6]).toAsync().map((a) => delay(Duration(milliseconds: 50), a));

  final result = await toArrayAsync(transposeAsync([rowA, rowB]));
  print(result); // [[1, 4], [2, 5], [3, 6]]
}
