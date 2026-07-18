import 'package:fxdart/fxdart.dart';

void main() {
  final transforms = <String, String Function(String)>{
    'upper': (s) => s.toUpperCase(),
    'none': identity,
  };

  print(transforms['upper']!('hi')); // HI
  print(transforms['none']!('hi'));  // hi
}
