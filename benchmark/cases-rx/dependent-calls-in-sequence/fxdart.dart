import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

// The example's 15 ms per call becomes Duration.zero at benchmark scale.
Future<String> call(String request) async {
  await Future<void>.delayed(Duration.zero);
  return apiResponse(request);
}

Future<void> main() async {
  await bench(
    slug: 'dependent-calls-in-sequence',
    impl: 'fxdart',
    n: n,
    run: () async {
      // scan threads the previous response into the next request; the pull
      // pipeline is sequential, so each call waits for the one before it.
      final log = await fx(steps)
          .toAsync()
          .scan<(String, String)>(
              (acc, step) async => (step, await call('$step(${acc.$2})')),
              ('', 'guest'))
          .map((r) => '${r.$1} -> ${r.$2}')
          .toList();
      // scan emits its seed first — drop it, as the example does.
      final body = log.sublist(1);
      return '${body.length}|${body.last}';
    },
  );
}
