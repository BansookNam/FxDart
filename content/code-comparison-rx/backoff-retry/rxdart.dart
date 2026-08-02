import 'package:rxdart/rxdart.dart';

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
  var failures = 0;
  // retryWhen wants a NOTIFIER stream per error: emit → retry, error →
  // give up. Backoff means mapping each failure to a timer stream, and
  // the attempt budget is tracked by hand outside the factory.
  final payload = await Rx.retryWhen(
    () => Rx.fromCallable(fetchRates),
    (error, stackTrace) {
      failures += 1;
      if (failures >= 3) return Stream<void>.error(error, stackTrace);
      final ms = 40 * failures;
      backoffMs.add(ms);
      return Rx.timer<void>(null, Duration(milliseconds: ms));
    },
  ).first;

  print(payload);
  print('attempts: $attempts');
  print('backoff: ${backoffMs.map((ms) => '${ms}ms').join(', ')}');
}
