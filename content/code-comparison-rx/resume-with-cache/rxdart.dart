import 'package:rxdart/rxdart.dart';

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
  // The dashboard shows the first six updates. When the live feed errors,
  // onErrorResumeNext swaps in the cached tail — one operator.
  final updates = await liveFeed()
      .onErrorResumeNext(
          Stream.fromIterable(cachedTail).map((u) => '$u (from cache)'))
      .take(6)
      .toList();

  updates.forEach(print);
}
