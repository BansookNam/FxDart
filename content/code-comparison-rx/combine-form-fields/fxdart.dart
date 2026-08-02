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

/// Tag both fields into one stream — the merge Rx.combineLatest2 does for us.
Stream<(String, String)> fields() {
  final c = StreamController<(String, String)>();
  var open = 2;
  void done() {
    if (--open == 0) c.close();
  }

  emails().listen((e) => c.add(('email', e)), onDone: done);
  passwords().listen((p) => c.add(('password', p)), onDone: done);
  return c.stream;
}

Future<void> main() async {
  final states = await fxStream(fields())
      .scan<(String, String)>(
          (acc, ev) =>
              ev.$1 == 'email' ? (ev.$2, acc.$2) : (acc.$1, ev.$2),
          ('', ''))
      .filter((s) => s.$1.isNotEmpty && s.$2.isNotEmpty)
      .toList();

  for (final (e, p) in states) {
    print('email=$e password=$p -> ${valid(e, p) ? 'enabled' : 'disabled'}');
  }
  final (e, p) = states.last;
  print('submit: ${valid(e, p) ? 'enabled' : 'disabled'}');
}
