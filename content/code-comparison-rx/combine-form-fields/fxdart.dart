import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Simulated form input: each field emits at fixed offsets.
Stream<String> emails() {
  final c = StreamController<String>();
  Timer(Duration.zero, () => c.add('nam'));
  Timer(const Duration(milliseconds: 160), () => c.add('nam@fx.dev'));
  Timer(const Duration(milliseconds: 400), c.close);
  return c.stream;
}

Stream<String> passwords() {
  final c = StreamController<String>();
  Timer(const Duration(milliseconds: 80), () => c.add('hunter2'));
  Timer(const Duration(milliseconds: 240), () => c.add('box-belt-42'));
  Timer(const Duration(milliseconds: 400), c.close);
  return c.stream;
}

bool valid(String email, String password) =>
    email.contains('@') && password.length >= 8;

Future<void> main() async {
  final states = await fxEvents(emails())
      .combineLatest(passwords(), (e, p) => (e, p))
      .toList();

  for (final (e, p) in states) {
    print('email=$e password=$p -> ${valid(e, p) ? 'enabled' : 'disabled'}');
  }
  final (e, p) = states.last;
  print('submit: ${valid(e, p) ? 'enabled' : 'disabled'}');
}
