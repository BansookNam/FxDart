import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  var pulled = 0;
  final first = fx(range(1000000)).peek((_) => pulled++).head();
  print(first);            // 0
  print('pulled $pulled'); // pulled 1

  final firstReady = await fx(['slow', 'never awaited'])
      .toAsync()
      .map((v) => delay(Duration(milliseconds: 50), v))
      .head();
  print(firstReady); // slow — only the first delay() ever fires
}
