import 'package:fxdart/fxdart.dart';

void main() {
  print(fxThrowIf<int>((n) => n < 0, (n) => ArgumentError('negative: $n'), 5)); // 5

  try {
    fxThrowIf<int>((n) => n < 0, (n) => ArgumentError('negative: $n'), -5);
  } catch (e) {
    print('caught: $e'); // caught: Invalid argument(s): negative: -5
  }
}
