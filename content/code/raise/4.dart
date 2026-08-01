import 'package:fxdart/fxdart.dart';

/// One builder for both failure channels: a raise stays typed, a THROWN
/// exception is mapped into the same error type by the second argument.
Either<String, int> parsePort(String raw) => eitherCatching(
      (r) {
        final port = int.parse(raw); // may throw FormatException
        r.ensure(port > 0 && port < 65536, () => 'port out of range: $port');
        return port;
      },
      (thrown, _) => 'not a number: $raw',
    );

void main() {
  print(parsePort('8080')); // Right(8080)
  print(parsePort('99999')); // Left(port out of range: 99999) — raised
  print(parsePort('http')); // Left(not a number: http) — thrown, mapped

  // was: either((r) => catching(() => ..., (e, _) => r.raise(...)))

  // recover gained the same third clause (Arrow's recover/catch):
  final fallback = either<String, int>((r) => r.recover(
        (inner) => int.parse('x'), // throws
        (raised) => -1,
        onThrow: (thrown, _) => 0,
      ));
  print(fallback); // Right(0)
}
