import 'package:fxdart/fxdart.dart';

void main() async {
  final sw = Stopwatch()..start();

  // Five items at ~60ms each: the WHOLE pipeline takes ~300ms, but each
  // individual pull stays under the 100ms limit — so nothing times out.
  // The limit is demand-to-item time, not total time and not "gaps
  // between events" (that is what Rx's push-based timeout measures).
  final readings = await fx([1, 2, 3, 4, 5])
      .toAsync()
      .map((id) => delay(const Duration(milliseconds: 60), 'reading-$id'))
      .timeout(const Duration(milliseconds: 100))
      .toList();

  print(readings);
  print('whole pipeline: ${sw.elapsedMilliseconds}ms — fine');
  // [reading-1, ..., reading-5]
  // whole pipeline: ~300ms — fine

  // To bound the WHOLE pipeline, put the timeout on the terminal Future:
  //   await fxAsync(...).toList().timeout(const Duration(seconds: 1));
}
