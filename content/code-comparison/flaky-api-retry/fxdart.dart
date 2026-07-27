import 'package:fxdart/fxdart.dart';

const jobId = 'export-2026-07';
int pollsMade = 0;

/// Deterministically flaky: the first four polls answer 'pending',
/// the fifth answers 'ready'. (A real API would 503; same shape.)
Future<String> pollJob(String id, int attempt) async {
  pollsMade++;
  await Future.delayed(const Duration(milliseconds: 10));
  return attempt < 5 ? 'pending' : 'ready';
}

Future<void> main() async {
  final log = <String>[];
  final winner = await fx(range(1, 11))
      .toAsync()
      .map((attempt) async => (attempt, await pollJob(jobId, attempt)))
      .peek((r) => log.add('  poll ${r.$1}: ${r.$2}'))
      .dropWhile((r) => r.$2 != 'ready')
      .head();
  print('polling $jobId (up to 10 attempts):');
  log.forEach(print);
  print('ready on attempt ${winner!.$1}; polls actually made: $pollsMade');
}
