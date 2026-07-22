import 'package:fxdart/fxdart.dart';

void main() {
  // Nothing runs until a terminal operator pulls values through.
  var calls = 0;
  final chain = fx([1, 2, 3, 4, 5])
      .map((a) {
        calls++;
        return a * 10;
      })
      .filter((a) => a > 20);

  print('calls before terminal op: $calls'); // 0 — still just a plan

  final result = chain.toList();

  print(result);                 // [30, 40, 50]
  print('calls after toList: $calls'); // 5
}
