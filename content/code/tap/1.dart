import 'package:fxdart/fxdart.dart';

T Function(T) logger<T>(String label) =>
    (v) => tap((x) => print('$label: $x'), v);

void main() {
  final result = pipe(5, [
    logger<int>('start'),
    (int v) => v + 1,
    logger<int>('after +1'),
    (int v) => v * 2,
  ]);
  print('result: $result');
  // start: 5
  // after +1: 6
  // result: 12
}
