import 'package:fxdart/fxdart.dart';

void main() {
  final flags = [true, true, false];

  print(fx(flags).some(not));  // true - at least one flag is off
  print(fx(flags).every(not)); // false - not all flags are off
}
