import 'package:fxdart/fxdart.dart';

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
  // retry re-runs the function — up to 3 attempts in total, rethrowing
  // the last error once the budget is spent.
  final payload = await retry(3, fetchManifest);

  print(payload);
  print('attempts: $attempts');
}
