import 'package:fxdart/fxdart.dart';

void main() {
  final votes = ['yes', 'no', 'yes', 'yes', 'no', 'yes'];

  // TODO: the motion passes with at least 3 yes votes. Replace the
  // full count with atLeast, which can stop at the third yes.
  final passes = fx(votes).countWhere((v) => v == 'yes') >= 3;

  print(passes); // should print: true
}
