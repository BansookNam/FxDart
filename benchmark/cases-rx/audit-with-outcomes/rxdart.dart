import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

(String, int) parse(String line) {
  final parts = line.split('=');
  final value = int.tryParse(parts[1]);
  if (value == null) throw FormatException(line);
  return (parts[0], value);
}

Future<void> main() async {
  final lines = makeLines();
  await bench(
    slug: 'audit-with-outcomes',
    impl: 'rxdart',
    n: n,
    run: () async {
      // An error normally terminates the stream, so keeping every failure
      // means one inner stream per line, its error smuggled back as data.
      final outcomes = await Stream.fromIterable(lines)
          .asyncExpand(
              (line) => Rx.fromCallable<(String, int)?>(() => parse(line))
                  .onErrorReturn(null))
          .toList();

      var okCount = 0, valueSum = 0, failures = 0;
      for (final o in outcomes) {
        if (o == null) {
          failures++;
        } else {
          okCount++;
          valueSum += o.$2;
        }
      }
      return 'ok=$okCount|sum=$valueSum|failures=$failures';
    },
  );
}
