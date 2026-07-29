import 'package:fxdart/fxdart.dart';

int? addStrings(String x, String y) => nullable((r) {
  final a = r.bind(int.tryParse(x)); // unwraps, or the block returns null
  final b = r.bind(int.tryParse(y));
  return a + b;
});

void main() {
  print(addStrings('1', '2')); // 3
  print(addStrings('1', 'nope')); // null
  print(addStrings('one', '2')); // null
}
