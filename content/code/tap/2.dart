import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: use tap to print each value as it passes through
  final result = fx([1, 2, 3])
      .map((n) => tap((v) => print('processing $v'), n) * 10)
      .toList();

  print(result); // [10, 20, 30]
}
