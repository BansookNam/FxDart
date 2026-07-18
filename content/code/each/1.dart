import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // eachAsync awaits f for every element, strictly in order — even though
  // each delay is a different length, they always print as 1, 2, 3.
  await fx([1, 2, 3]).toAsync().each((a) async {
    await sleep(Duration(milliseconds: 50 * (4 - a)));
    print('processed $a');
  });

  print('done');
}
