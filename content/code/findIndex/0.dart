import 'package:fxdart/fxdart.dart';

void main() {
  final nums = [4, 8, 15, 16, 23, 42];
  print(indexWhere((a) => a > 15, nums));      // 3
  // FxTS alias: findIndex is the same operator.
  print(fx(nums).indexWhere((a) => a > 100));  // -1
}
