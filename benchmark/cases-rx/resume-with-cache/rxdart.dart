import 'package:rxdart/rxdart.dart';

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
    impl: 'rxdart',
    n: n,
    run: () async {
      // The dashboard shows the first takeCount updates. When the live feed
      // errors, onErrorResumeNext swaps in the cached tail — one operator.
      final updates = await liveFeed()
          .onErrorResumeNext(
            Stream.fromIterable(cachedTail).map((u) => '$u (from cache)'),
          )
          .take(takeCount)
          .toList();

      return '${updates.length}|${updates.first}|${updates.last}';
    },
  );
}
