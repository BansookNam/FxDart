import 'package:fxdart/fxdart.dart';

// The whole point of the strict form: WHEN the upstream runs.
void main() {
  final ids = [3, 1, 3, 2, 1, 2];

  // Lazy: nothing has run yet, and the upstream re-runs on every iteration.
  var lazyCalls = 0;
  final lazy = fx(ids).map((a) {
    lazyCalls++;
    return a;
  }).distinct();
  print('lazy, before iterating: $lazyCalls'); // 0
  print(lazy.toList()); // [3, 1, 2]
  print(lazy.toList()); // [3, 1, 2]
  print('lazy, after 2 passes: $lazyCalls'); // 12 -- ran twice

  // Strict: the upstream runs once, right here at the call.
  var strictCalls = 0;
  final strict = fx(ids).map((a) {
    strictCalls++;
    return a;
  }).uniqStrict();
  print('strict, before iterating: $strictCalls'); // 6 -- already done
  print(strict.toList()); // [3, 1, 2]
  print(strict.toList()); // [3, 1, 2]
  print('strict, after 2 passes: $strictCalls'); // 6 -- still once

  // The trade-off: nothing downstream can cut a strict pass short.
  var lazyScanned = 0;
  fx(ids).map((a) {
    lazyScanned++;
    return a;
  }).distinct().take(2).toList();
  print('lazy + take(2) scanned: $lazyScanned'); // 2 -- stopped early

  var strictScanned = 0;
  fx(ids).map((a) {
    strictScanned++;
    return a;
  }).uniqStrict().take(2).toList();
  print('strict + take(2) scanned: $strictScanned'); // 6 -- scanned it all
}
