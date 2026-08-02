import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'cursor-lifetime',
    impl: 'rxdart',
    n: n,
    run: () async {
      late final LedgerCursor cursor;

      // The bracket: the resource is created on listen, read as a stream,
      // and disposed when the stream terminates — however it terminates.
      final rows = await Rx.using<String, LedgerCursor>(
        resourceFactory: () => cursor = LedgerCursor(),
        streamFactory: (c) => Rx.range(0, c.length - 1).asyncMap(c.read),
        disposer: (c) => c.close(),
      ).toList();

      return '${rows.length}|${rows.first}|${rows.last}'
          '|closed=${cursor.closed}';
    },
  );
}
