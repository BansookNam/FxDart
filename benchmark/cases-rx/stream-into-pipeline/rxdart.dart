import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

/// The log feed — the example's timed controller becomes an immediate
/// stream over the shared dataset (identical on both sides).
Stream<String> logFeed() => Stream.fromIterable(lines);

Future<void> main() async {
  await bench(
    slug: 'stream-into-pipeline',
    impl: 'rxdart',
    n: n,
    run: () async {
      // The stream is the model: filter-and-format in one rxdart operator.
      final warnings = await logFeed()
          .mapNotNull(
              (line) => line.startsWith('warn') ? line.toUpperCase() : null)
          .toList();
      return '${warnings.length}|${warnings.last}';
    },
  );
}
