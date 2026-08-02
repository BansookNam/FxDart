import 'package:fxdart/fxdart.dart';

/// The live order feed: three updates arrive, then the connection dies.
Stream<String> liveFeed() async* {
  yield 'ORD-7011 packed';
  yield 'ORD-7012 shipped';
  yield 'ORD-7013 packed';
  throw StateError('feed connection lost');
}

/// Last night's cached snapshot of the rest of the queue.
const cachedTail = [
  'ORD-7014 picking',
  'ORD-7015 picking',
  'ORD-7016 received',
  'ORD-7017 received',
];

Future<void> main() async {
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

  // The dashboard shows the first six updates; take(6) means the cache is
  // only pulled as far as needed — and nothing here is async anymore.
  final updates = fx(live)
      .concat(fx(cachedTail).map((u) => '$u (from cache)'))
      .take(6)
      .toList();

  updates.forEach(print);
}
