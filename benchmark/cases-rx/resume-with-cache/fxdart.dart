import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

final liveUpdates = makeLiveUpdates();

/// The live order feed: [liveCount] updates arrive, then the connection dies.
Stream<String> liveFeed() async* {
  for (final update in liveUpdates) {
    yield update;
  }
  throw StateError('feed connection lost');
}

Future<void> main() async {
  final cachedTail = makeCachedTail();
  await bench(
    slug: 'resume-with-cache',
    impl: 'fxdart',
    n: n,
    run: () async {
      // Pull from the live feed until it dies, keeping everything it managed
      // to deliver — the loop is the explicit error boundary.
      final live = <String>[];
      try {
        await for (final update in liveFeed()) {
          live.add(update);
        }
      } on StateError {
        // The feed died — resume from the cached tail below.
      }

      // The dashboard shows the first takeCount updates; take means the
      // cache is only pulled as far as needed — and nothing here is async
      // anymore.
      final updates = fx(live)
          .concat(fx(cachedTail).map((u) => '$u (from cache)'))
          .take(takeCount)
          .toList();

      return '${updates.length}|${updates.first}|${updates.last}';
    },
  );
}
