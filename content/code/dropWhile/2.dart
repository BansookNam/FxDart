import 'package:fxdart/fxdart.dart';

void main() {
  final temps = [18, 19, 21, 30, 22, 17];

  // TODO: drop temperatures while they stay below 25, keep the rest
  final rest = fx(temps).toArray();

  print(rest);
}
