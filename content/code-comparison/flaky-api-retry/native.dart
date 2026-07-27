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
  (int, String)? winner;
  for (var attempt = 1; attempt <= 10; attempt++) {
    final status = await pollJob(jobId, attempt);
    log.add('  poll $attempt: $status');
    if (status == 'ready') {
      winner = (attempt, status);
      break;
    }
  }
  print('polling $jobId (up to 10 attempts):');
  log.forEach(print);
  print('ready on attempt ${winner!.$1}; polls actually made: $pollsMade');
}
