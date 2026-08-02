import 'package:rxdart/rxdart.dart';

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
  // asyncMap pauses the source per future, so the calls are sequential
  // by construction; a closure variable threads each response onward.
  var token = 'guest';
  final log = await Stream.fromIterable(steps).asyncMap((step) async {
    token = await call('$step($token)');
    return '$step -> $token';
  }).toList();

  log.forEach(print);
}
