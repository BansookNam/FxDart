import 'package:fxdart/fxdart.dart';

void main() {
  // range is lazy (sync*), so range(1000000) allocates nothing up front —
  // only the elements take(4) actually pulls get generated.
  var calls = 0;
  final result = fx(range(1000000))
      .map((a) {
        calls++;
        return a * a;
      })
      .take(4)
      .toList();

  print(result);          // [0, 1, 4, 9]
  print('calls: $calls'); // 4 — not 1000000
}
