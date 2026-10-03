import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();
  final v = await fxDelay(Duration(milliseconds: 150), 'done');
  print(v); // done
  print(sw.elapsedMilliseconds >= 150); // true

  await fxSleep(Duration(milliseconds: 50));
  print('after sleep'); // after sleep
}
