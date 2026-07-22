import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: identical behavior to map, different intent.
  final logged = <String>[];
  final result = mapEffect((a) {
    logged.add('processing $a');
    return a * 2;
  }, [1, 2, 3]);

  print(toList(result)); // [2, 4, 6]
  print(logged); // [processing 1, processing 2, processing 3]

  // Chain form:
  final chained =
      fx([10, 20, 30]).mapEffect((a) => a ~/ 10).toList();
  print(chained); // [1, 2, 3]
}
