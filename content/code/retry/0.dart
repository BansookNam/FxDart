import 'package:fxdart/fxdart.dart';

int calls = 0;

/// A fetch that fails twice before succeeding.
Future<String> fetchConfig() async {
  calls++;
  await Future.delayed(const Duration(milliseconds: 20));
  if (calls <= 2) throw Exception('network hiccup #$calls');
  return '{"theme": "dark"}';
}

void main() async {
  // Run again on failure — up to 4 runs, waiting a little longer each time:
  final config = await retry(
    4,
    fetchConfig,
    delay: (failed) {
      print('attempt $failed failed, backing off ${failed * 100}ms');
      return Duration(milliseconds: failed * 100);
    },
  );

  print('got $config after $calls calls');
  // attempt 1 failed, backing off 100ms
  // attempt 2 failed, backing off 200ms
  // got {"theme": "dark"} after 3 calls

  // When the budget runs out, the LAST error rethrows — stack trace intact.
}
