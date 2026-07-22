import 'package:fxdart/fxdart.dart';

void main() {
  // repeat yields the SAME value n times — pair it with zip/zipWithIndex
  // to stamp a constant onto a variable-length sequence.
  final names = ['kim', 'lee', 'park'];
  final labeled = fx(names).zip(repeat(names.length, 'pending')).toList();

  print(labeled); // [(kim, pending), (lee, pending), (park, pending)]
}
