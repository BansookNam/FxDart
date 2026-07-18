import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Every sync op has a data-first *Async twin that works on
  // FxAsyncIterable instead of Iterable.
  final doubled = await toArrayAsync(
      mapAsync((a) => a * 2, toAsync([1, 2, 3])));
  print(doubled); // [2, 4, 6]

  final evens = await toArrayAsync(
      filterAsync((a) async => a.isEven, toAsync([1, 2, 3, 4, 5, 6])));
  print(evens); // [2, 4, 6]

  final total = await reduceAsync((acc, a) => acc + a, toAsync([1, 2, 3, 4]));
  print(total); // 10
}
