import 'package:fxdart/fxdart.dart';

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
  final responses = await fx(const [1, 2, 3, 4, 5])
      .toAsync()
      .map((i) async {
        // The pull pipeline is sequential — a delay in the mapper IS the pacing.
        await Future.delayed(const Duration(milliseconds: 100));
        return ping(i);
      })
      .toList();

  responses.forEach(print);
  print('spaced: ${spaced(startsMs)}');
}
