import 'package:fxdart/fxdart.dart';

class NotFound implements Exception {}

Future<void> main() async {
  var calls = 0;
  Future<String> fetch() async {
    calls++;
    if (calls < 3) throw StateError('timeout');
    return 'photo bytes';
  }

  // retryIf: only a timeout is worth another try.
  // onRetry: log every failure that will be retried.
  final bytes = await fxRetry(
    5,
    fetch,
    retryIf: (e) => e is StateError,
    onRetry: (e, failed) => print('retry $failed after: $e'),
  );
  // retry 1 after: Bad state: timeout
  // retry 2 after: Bad state: timeout
  print(bytes); // photo bytes

  // A 404 will not get better: rethrown at once, attempts unspent.
  var tries = 0;
  try {
    await fxRetry(5, () {
      tries++;
      throw NotFound();
    }, retryIf: (e) => e is! NotFound);
  } on NotFound {
    print('gave up after $tries try'); // gave up after 1 try
  }
}
