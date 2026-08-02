import 'package:fxdart/fxdart.dart';

var attempts = 0;
final backoffMs = <int>[];

/// The FX rate service: unavailable exactly twice, then serves.
Future<String> fetchRates() async {
  attempts += 1;
  await Future<void>.delayed(const Duration(milliseconds: 10));
  if (attempts < 3) throw StateError('rate service unavailable');
  return 'rates: EUR 0.85, GBP 0.74, JPY 148.20';
}

Future<void> main() async {
  // Backoff is the delay hook: it receives the failure count (1, 2, …)
  // and returns how long to wait before the next attempt.
  final payload = await retry(3, fetchRates, delay: (failed) {
    final ms = 40 * failed;
    backoffMs.add(ms);
    return Duration(milliseconds: ms);
  });

  print(payload);
  print('attempts: $attempts');
  print('backoff: ${backoffMs.map((ms) => '${ms}ms').join(', ')}');
}
