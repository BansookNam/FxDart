import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  final users = await fx([1, 2, 3, 4, 5, 6])
      .toAsync()
      .map((id) => delay(Duration(milliseconds: 300), 'user$id'))
      .concurrent(3) // ← try 1 (sequential) or 6 (all at once)
      .toArray();

  print(users);
  print('took ${sw.elapsedMilliseconds}ms');
}
