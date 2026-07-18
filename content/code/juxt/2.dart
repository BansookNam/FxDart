import 'package:fxdart/fxdart.dart';

void main() {
  final numbers = [4, 1, 7, 3];

  // TODO: use juxt to compute sum and average together
  final stats = juxt([sum, average]);

  print(stats(numbers)); // [15, 3.75]
}
