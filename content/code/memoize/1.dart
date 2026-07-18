import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final fetchUser = memoize<int, Future<String>>(
      (id) => delay(Duration(milliseconds: 150), 'user$id'));

  final sw = Stopwatch()..start();
  print(await fetchUser(1)); // user1, ~150ms
  print('first call: ${sw.elapsedMilliseconds}ms');

  sw.reset();
  print(await fetchUser(1)); // user1, cached — instant
  print('second call: ${sw.elapsedMilliseconds}ms');
}
