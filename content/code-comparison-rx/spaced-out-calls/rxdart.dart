import 'package:rxdart/rxdart.dart';

final watch = Stopwatch()..start();
final startsMs = <int>[];

// One ping — records when it started, on a monotonic clock.
Future<String> ping(int i) async {
  startsMs.add(watch.elapsedMilliseconds);
  await Future.delayed(const Duration(milliseconds: 10));
  return 'pong #$i';
}

bool spaced(List<int> starts) {
  for (var i = 1; i < starts.length; i++) {
    if (starts[i] - starts[i - 1] < 100) return false;
  }
  return starts.length == 5;
}

Future<void> main() async {
  // interval holds each event back 100 ms before it reaches the ping.
  final responses = await Stream.fromIterable(const [1, 2, 3, 4, 5])
      .interval(const Duration(milliseconds: 100))
      .asyncMap(ping)
      .toList();

  responses.forEach(print);
  print('spaced: ${spaced(startsMs)}');
}
