import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  final result = await resolveProps({
    'a': delay(Duration(milliseconds: 100), 1),
    'b': delay(Duration(milliseconds: 100), 2),
    'c': delay(Duration(milliseconds: 100), 3),
  });

  print(result); // {a: 1, b: 2, c: 3}
  print(sw.elapsedMilliseconds < 250); // true
}
