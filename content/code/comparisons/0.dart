import 'package:fxdart/fxdart.dart';

void main() {
  print(fxGt(5, 3));    // true
  print(fxGte(5, 5));   // true
  print(fxLt('a', 'b')); // true
  print(fxLte(2, 2));   // true

  try {
    fxGt(5, '3');
  } catch (e) {
    print('caught: ${e.runtimeType}'); // caught: ArgumentError
  }
}
