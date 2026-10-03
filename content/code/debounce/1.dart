import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // leading: true fires on the *first* call of a burst instead of the last.
  final leadingCalls = <String>[];
  final leadingDebounced = fxDebounce<String>(
      (s) => leadingCalls.add(s), const Duration(milliseconds: 100),
      leading: true);
  leadingDebounced('x'); // fires right away
  print(leadingCalls); // [x]
  leadingDebounced('y');
  leadingDebounced('z'); // both suppressed — still inside the same burst
  print(leadingCalls); // [x]
  await fxSleep(const Duration(milliseconds: 150));

  // .cancel() drops a pending trailing call before it fires.
  final cancelCalls = <String>[];
  final cancelDebounced = fxDebounce<String>(
      (s) => cancelCalls.add(s), const Duration(milliseconds: 100));
  cancelDebounced('should never appear');
  cancelDebounced.cancel();
  await fxSleep(const Duration(milliseconds: 150));
  print(cancelCalls); // []
}
