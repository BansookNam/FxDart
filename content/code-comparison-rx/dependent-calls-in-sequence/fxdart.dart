import 'package:fxdart/fxdart.dart';

const steps = ['login', 'profile', 'orders', 'invoice'];

// Each response is the input of the next request.
const api = {
  'login(guest)': 'session-9',
  'profile(session-9)': 'user-42',
  'orders(user-42)': 'order-7',
  'invoice(order-7)': 'pdf-3',
};

Future<String> call(String request) async {
  await Future.delayed(const Duration(milliseconds: 15));
  return api[request]!;
}

Future<void> main() async {
  // scan threads the previous response into the next request; the pull
  // pipeline is sequential, so each call waits for the one before it.
  final log = await fx(steps)
      .toAsync()
      .scan<(String, String)>(
          (acc, step) async => (step, await call('$step(${acc.$2})')),
          ('', 'guest'))
      .map((r) => '${r.$1} -> ${r.$2}')
      .toList();

  // scan emits its seed first — skip that line in the printout.
  log.skip(1).forEach(print);
}
