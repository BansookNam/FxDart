import 'package:fxdart/fxdart.dart';

void main() {
  final grades = ['A', 'B', 'A', 'C', 'B', 'A'];

  // Data-first form: counts how many elements map to each key.
  print(fxCountBy((g) => g, grades)); // {A: 3, B: 2, C: 1}

  // Chain form:
  final byParity = fx(fxRange(10)).countBy((a) => a.isEven ? 'even' : 'odd');
  print(byParity); // {even: 5, odd: 5}
}
