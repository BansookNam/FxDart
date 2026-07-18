import 'package:fxdart/fxdart.dart';

void main() {
  print(last([1, 2, 3])); // 3
  print(last(<int>[]));   // null

  try {
    fx(<int>[]).last;
  } on StateError catch (e) {
    print('Iterable.last threw: $e');
  }
}
