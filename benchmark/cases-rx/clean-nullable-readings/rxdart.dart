import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final samples = makeSamples();
  await bench(
    slug: 'clean-nullable-readings',
    impl: 'rxdart',
    n: n,
    run: () async {
      // whereNotNull narrows Stream<double?> to Stream<double>.
      final clean = await Stream.fromIterable(samples)
          .whereNotNull()
          .map((v) => '${v.toStringAsFixed(1)} V')
          .toList();
      final dropped = samples.length - clean.length;
      return '${clean.length}|${clean.first}|${clean.last}|dropped=$dropped';
    },
  );
}
