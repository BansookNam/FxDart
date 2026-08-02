import 'package:rxdart/rxdart.dart';

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
    impl: 'rxdart',
    n: n,
    run: () async {
      final days = await Stream.fromIterable(forecast)
          .zipWith(Stream.fromIterable(actual), line)
          .toList();
      return '${days.length}|${days.first}|${days.last}';
    },
  );
}
