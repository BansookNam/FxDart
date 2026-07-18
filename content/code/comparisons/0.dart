import 'package:fxdart/fxdart.dart';

void main() {
  print(gt(5, 3));    // true
  print(gte(5, 5));   // true
  print(lt('a', 'b')); // true
  print(lte(2, 2));   // true

  try {
    gt(5, '3');
  } catch (e) {
    print('caught: ${e.runtimeType}'); // caught: ArgumentError
  }
}
