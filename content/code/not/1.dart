import 'package:fxdart/fxdart.dart';

void main() {
  final flags = [true, true, false];

  print(fx(flags).some(fxNot));  // true - at least one flag is off
  print(fx(flags).every(fxNot)); // false - not all flags are off
}
