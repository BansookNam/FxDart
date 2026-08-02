import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final samples = makeSamples();
  await bench(
    slug: 'clean-nullable-readings',
    impl: 'fxdart',
    n: n,
    run: () {
      // compact narrows Iterable<double?> to Iterable<double>.
      final clean =
          fx(compact(samples)).map((v) => '${v.toStringAsFixed(1)} V').toList();
      final dropped = samples.length - clean.length;
      return '${clean.length}|${clean.first}|${clean.last}|dropped=$dropped';
    },
  );
}
