import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Start a pull, then push 1, 2, 3 on a sync controller. The four
/// policies disagree about what that burst becomes.
Future<List<Object?>> drainBurst<T>(
  FxAsyncIterable<T> Function(Stream<int>) wrap,
) async {
  final c = StreamController<int>(sync: true);
  final it = wrap(c.stream).iterator;
  final first = it.next();
  c
    ..add(1)
    ..add(2)
    ..add(3)
    ..close();
  final out = <Object?>[];
  var r = await first;
  if (!r.done) out.add(r.value);
  while (true) {
    r = await it.next();
    if (r.done) break;
    out.add(r.value);
  }
  return out;
}

Future<void> main() async {
  print('fromStream        ${await drainBurst(fromStream)}');
  // [1, 2, 3] — lossless FIFO
  print('fromStreamLatest  ${await drainBurst(fromStreamLatest)}');
  // [3] — latest-wins
  print('fromStreamChunked ${await drainBurst(fromStreamChunked)}');
  // [[1, 2, 3]] — batched
  print('fromStreamNext    ${await drainBurst(fromStreamNext)}');
  // [1] — demand-gated

  // Same four, from the events chain:
  //   fxEvents(s).pull() / pullLatest() / pullChunked() / pullNext()
}
