import 'package:fxdart/fxdart.dart';

void main() {
  var calls = 0;
  Iterable<int> source() sync* {
    for (var i = 1; i <= 5; i++) {
      calls++;
      yield i;
    }
  }

  final shared = source();
  final a = fork(shared).iterator;
  final b = fork(shared).iterator;

  a.moveNext();
  print('a: ${a.current}, calls: $calls'); // a: 1, calls: 1
  a.moveNext();
  print('a: ${a.current}, calls: $calls'); // a: 2, calls: 2

  // b catches up by replaying the buffer — no new calls to source() yet:
  b.moveNext();
  print('b: ${b.current}, calls: $calls'); // b: 1, calls: 2
  b.moveNext();
  print('b: ${b.current}, calls: $calls'); // b: 2, calls: 2

  // Only now does b need a value neither fork has buffered:
  b.moveNext();
  print('b: ${b.current}, calls: $calls'); // b: 3, calls: 3
}
