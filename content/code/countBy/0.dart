import 'package:fxdart/fxdart.dart';

void main() {
  final grades = ['A', 'B', 'A', 'C', 'B', 'A'];

  // Data-first form: counts how many elements map to each key.
  print(countBy((g) => g, grades)); // {A: 3, B: 2, C: 1}

  // Chain form:
  final byParity = fx(range(10)).countBy((a) => a.isEven ? 'even' : 'odd');
  print(byParity); // {even: 5, odd: 5}
}
