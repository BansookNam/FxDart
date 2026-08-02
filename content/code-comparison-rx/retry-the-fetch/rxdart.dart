import 'package:rxdart/rxdart.dart';

var attempts = 0;

/// The release manifest endpoint: resets the connection exactly twice,
/// then serves the payload.
Future<String> fetchManifest() async {
  attempts += 1;
  await Future<void>.delayed(const Duration(milliseconds: 15));
  if (attempts < 3) throw StateError('connection reset');
  return 'manifest 2026-08 (12 entries)';
}

Future<void> main() async {
  // Rx.retry re-subscribes the stream FACTORY on error — up to 2 retries
  // after the first attempt, so 3 attempts in total.
  final payload =
      await Rx.retry(() => Rx.fromCallable(fetchManifest), 2).first;

  print(payload);
  print('attempts: $attempts');
}
