import 'package:fxdart/fxdart.dart';

void main() {
  final stock = [5, 0, 3];

  // TODO: use throwIf to guard against zero stock while summing
  try {
    final total = fx(stock)
        .map((n) =>
            fxThrowIf<int>((v) => v == 0, (v) => StateError('out of stock'), n))
        .reduce(fxAdd);
    print(total);
  } catch (e) {
    print('caught: $e'); // caught: Bad state: out of stock
  }
}
