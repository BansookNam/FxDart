import 'package:fxdart/fxdart.dart';

void main() {
  final deposits = [100, -30, 50, -20, 200];

  // TODO: fold deposits into a running balance, starting from 1000.
  final balance = fold<int, int>(1000, (acc, a) => acc, deposits);

  print(balance);
}
