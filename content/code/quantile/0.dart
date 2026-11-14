import 'package:fxdart/fxdart.dart';

void main() {
  final frameMs = [16, 17, 16, 33, 16, 18, 16, 50, 17, 16];

  print(fxQuantile(0, frameMs)); // 16  (the minimum)
  print(fxQuantile(0.5, frameMs)); // 17  (the median)
  print(fxQuantile(0.9, frameMs)); // 33  (p90)
  print(fxQuantile(1, frameMs)); // 50  (the maximum)

  // The chain spelling, on an Fx of numbers:
  print(fx(frameMs).quantile(0.95)); // 50

  // The input is not reordered:
  print(frameMs.first); // 16
  print(fxQuantile(0.5, <num>[])); // null
}
