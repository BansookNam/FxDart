import 'package:fxdart/fxdart.dart';

Future<int> slowDouble(int n) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return n * 2;
}

void main() async {
  // The pre-combined step...
  final combined = await fx([1, 2, 3, 4]).mapConcurrent(2, slowDouble).toList();

  // ...is exactly the three-operator long form:
  final longForm =
      await fx([1, 2, 3, 4]).toAsync().map(slowDouble).concurrent(2).toList();

  print(combined); // [2, 4, 6, 8]
  print(longForm); // [2, 4, 6, 8]

  // On an already-async chain it composes map + concurrent (no bridge),
  // and it can sit mid-pipeline like any other operator:
  final result = await fxStream(Stream.fromIterable([1, 2, 3, 4, 5]))
      .mapConcurrent(2, slowDouble)
      .filter((n) => n > 4)
      .toList();
  print(result); // [6, 8, 10]
}
