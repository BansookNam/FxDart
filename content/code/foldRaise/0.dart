import 'package:fxdart/fxdart.dart';

/// Raises a typed error for a rule, and lets int.parse throw.
int portOf(Raise<String> r, String raw) {
  final n = int.parse(raw); // may THROW FormatException
  r.ensure(n > 0 && n < 65536, () => '$n is out of range');
  return n;
}

String describe(String raw) => fxFoldRaise<String, int, String>(
  (r) => portOf(r, raw),
  onValue: (port) => 'ok: port $port',
  onRaise: (error) => 'rule: $error',
  onThrow: (e, st) => 'crash: ${e.runtimeType}',
);

void main() {
  // One call, three outcomes, each folded into the same type:
  print(describe('8080')); // ok: port 8080
  print(describe('99999')); // rule: 99999 is out of range
  print(describe('http')); // crash: FormatException

  // Without onThrow, a thrown exception is simply rethrown:
  try {
    fxFoldRaise<String, int, int>(
      (r) => portOf(r, 'http'),
      onValue: (port) => port,
      onRaise: (error) => 0,
    );
  } on FormatException {
    print('rethrown'); // rethrown
  }
}
