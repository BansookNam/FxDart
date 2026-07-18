import 'package:fxdart/fxdart.dart';

void main() {
  // keys() turns a Map's key set into a plain lazy Iterable, so the usual
  // chain operators apply — here, count how many item names start with 'a'.
  final prices = {'apple': 1.5, 'banana': 0.5, 'avocado': 2.0, 'kiwi': 1.2};

  final aKeys = fx(keys(prices)).filter((k) => k.startsWith('a')).toArray();
  print(aKeys); // [apple, avocado]
  print('count: ${aKeys.length}'); // count: 2
}
