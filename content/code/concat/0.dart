import 'package:fxdart/fxdart.dart';

void main() {
  print(concat([1, 2], [3, 4])); // (1, 2, 3, 4)

  // Lazy: the second iterable is never touched unless pulled that far.
  var secondTouched = false;
  Iterable<int> second() sync* {
    secondTouched = true;
    yield 99;
  }

  final result = fx(concat([1, 2], second())).take(2).toList();
  print(result); // [1, 2]
  print('second touched: $secondTouched'); // false
}
