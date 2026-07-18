import 'package:fxdart/fxdart.dart';

void main() {
  final classify = cases<int, String>([
    ((n) => n > 0, (n) => 'positive'),
    ((n) => n == 0, (n) => 'zero'),
  ], orElse: throwError((n) => ArgumentError('unsupported value: $n')));

  print(classify(7)); // positive

  try {
    classify(-1);
  } catch (e) {
    print('caught: $e'); // caught: Invalid argument(s): unsupported value: -1
  }
}
