import 'package:fxdart/fxdart.dart';

// Six lookups with distinct response times — the fastest should print first.
const ids = [1, 2, 3, 4, 5, 6];
const delaysMs = {1: 100, 2: 40, 3: 240, 4: 120, 5: 200, 6: 220};

Future<String> lookup(int id) async {
  await Future.delayed(Duration(milliseconds: delaysMs[id]!));
  return 'user#$id';
}

Future<void> main() async {
  // concurrentPool runs 3 lookups at a time and yields in COMPLETION order.
  final results =
      await fx(ids).toAsync().map(lookup).concurrentPool(3).toList();

  results.forEach(print);
}
