import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();
  final v = await delay(Duration(milliseconds: 150), 'done');
  print(v); // done
  print(sw.elapsedMilliseconds >= 150); // true

  await sleep(Duration(milliseconds: 50));
  print('after sleep'); // after sleep
}
