import 'package:fxdart/fxdart.dart';

void main() {
  final temperatures = [18, 25, 31, 22, 29, 15];

  // TODO: find the HIGHEST temperature in the list.
  final highest = fx(temperatures).sum();

  print(highest);
}
