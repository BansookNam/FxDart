import 'dart:async';

import 'package:fxdart/fxdart.dart';

final completed = <String>[];

/// A mirror fetch as a cancellable stream: the work is a timer that only
/// runs while someone is listening — cancelling really stops the fetch.
Stream<String> mirror(String name, int ms) {
  final c = StreamController<String>();
  Timer? t;
  c.onListen = () {
    t = Timer(Duration(milliseconds: ms), () {
      completed.add(name);
      c.add('payload from $name');
      c.close();
    });
  };
  c.onCancel = () => t?.cancel();
  return c.stream;
}

Future<void> main() async {
  // Not a race: head() demands ONE item, so only the primary mirror is
  // ever listened to — the backup never starts (pull cannot cancel work
  // already in flight; it can only decline to demand it).
  final winner = await fx([mirror('eu-mirror', 60), mirror('us-mirror', 180)])
      .toAsync()
      .map((m) => m.first)
      .head();

  // Wait long past the backup's 180 ms — it was never subscribed at all.
  await Future.delayed(const Duration(milliseconds: 540));

  print('winner: $winner');
  print('completed fetches: ${completed.length}');
  print('loser fetch completed: ${completed.contains('us-mirror')}');
}
