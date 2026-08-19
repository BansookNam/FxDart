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
  // Race both mirrors: first event wins, the loser is CANCELLED mid-flight.
  final winner = await FxEvents.race(
      [mirror('eu-mirror', 60), mirror('us-mirror', 180)]).head();

  // Wait long past the loser's 180 ms — its timer was cancelled at ~60 ms.
  await Future.delayed(const Duration(milliseconds: 540));

  print('winner: $winner');
  print('completed fetches: ${completed.length}');
  print('loser fetch completed: ${completed.contains('us-mirror')}');
}
