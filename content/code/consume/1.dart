import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // consumeAsync forces an async chain's side effects without collecting
  // a List back — handy when you only care about the effects (logging,
  // writes, ...) and not the values.
  var processed = 0;

  await fx([1, 2, 3])
      .toAsync()
      .peek((a) async {
        await sleep(const Duration(milliseconds: 50));
        processed++;
      })
      .consume();

  print('processed: $processed'); // 3
}
