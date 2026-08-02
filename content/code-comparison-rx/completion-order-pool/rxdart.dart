import 'package:rxdart/rxdart.dart';

// Six lookups with distinct response times — the fastest should print first.
const ids = [1, 2, 3, 4, 5, 6];
const delaysMs = {1: 100, 2: 40, 3: 240, 4: 120, 5: 200, 6: 220};

Future<String> lookup(int id) async {
  await Future.delayed(Duration(milliseconds: delaysMs[id]!));
  return 'user#$id';
}

Future<void> main() async {
  // flatMap runs 3 lookups at a time and emits each result the moment it
  // completes — completion order is its native behavior.
  final results = await Stream.fromIterable(ids)
      .flatMap((id) => Rx.fromCallable(() => lookup(id)), maxConcurrent: 3)
      .toList();

  results.forEach(print);
}
