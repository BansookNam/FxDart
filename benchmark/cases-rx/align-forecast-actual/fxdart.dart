import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

String line(double f, double a) {
  final d = a - f;
  final sign = d >= 0 ? '+' : '';
  return '${f.toStringAsFixed(1)} forecast vs ${a.toStringAsFixed(1)} '
      'actual ($sign${d.toStringAsFixed(1)})';
}

Future<void> main() async {
  await bench(
    slug: 'align-forecast-actual',
    impl: 'fxdart',
    n: n,
    run: () {
      final days = fx(forecast)
          .zip(actual)
          .map((p) => line(p.$1, p.$2))
          .toList();
      return '${days.length}|${days.first}|${days.last}';
    },
  );
}
