import 'package:fxdart/fxdart.dart';

void main() {
  final temps = [18, 19, 21, 24, 30, 22, 17];

  // TODO: keep temperatures only while they stay below 25
  final mild = fx(temps).toArray();

  print(mild);
}
