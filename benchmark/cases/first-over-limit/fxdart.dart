import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final readings = makeReadings();
  await bench(
    slug: 'first-over-limit',
    impl: 'fxdart',
    n: n,
    run: () {
      // head() is lazy-friendly: nothing past the first match is examined.
      final first = fx(readings).dropWhile((r) => r.celsius <= limit).head();
      return first == null
          ? 'No reading over ${limit.toStringAsFixed(1)} C'
          : 'First over ${limit.toStringAsFixed(1)} C: '
                '${first.time} at ${first.celsius.toStringAsFixed(1)} C';
    },
  );
}
