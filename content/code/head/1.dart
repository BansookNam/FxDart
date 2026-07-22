import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  var pulled = 0;
  // Sync chain: .firstOrNull is the inherited getter — no parens.
  final first = fx(range(1000000)).peek((_) => pulled++).firstOrNull;
  print(first);            // 0
  print('pulled $pulled'); // pulled 1

  // Async chain: .firstOrNull() is a method — with parens.
  final firstReady = await fx(['slow', 'never awaited'])
      .toAsync()
      .map((v) => delay(Duration(milliseconds: 50), v))
      .firstOrNull();
  print(firstReady); // slow — only the first delay() ever fires
}
