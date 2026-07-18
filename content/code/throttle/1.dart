import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // leading: false — suppress the immediate call, only the trailing edge fires.
  final trailingOnlyCalls = <String>[];
  final trailingOnly = throttle<String>(
      (s) => trailingOnlyCalls.add(s), const Duration(milliseconds: 100),
      leading: false, trailing: true);
  trailingOnly('a');
  trailingOnly('b');
  print(trailingOnlyCalls); // [] — no leading call this time
  await sleep(const Duration(milliseconds: 150));
  print(trailingOnlyCalls); // [b]

  // trailing: false — only the leading edge ever fires.
  final leadingOnlyCalls = <String>[];
  final leadingOnly = throttle<String>(
      (s) => leadingOnlyCalls.add(s), const Duration(milliseconds: 100),
      leading: true, trailing: false);
  leadingOnly('x');
  leadingOnly('y');
  leadingOnly('z');
  await sleep(const Duration(milliseconds: 150));
  print(leadingOnlyCalls); // [x] — y and z are dropped, no trailing call

  // .cancel() drops a pending trailing call.
  final cancelCalls = <String>[];
  final cancelThrottled = throttle<String>(
      (s) => cancelCalls.add(s), const Duration(milliseconds: 100));
  cancelThrottled('first');
  cancelThrottled('second'); // would trigger a trailing call...
  cancelThrottled.cancel(); // ...but this cancels it
  await sleep(const Duration(milliseconds: 150));
  print(cancelCalls); // [first]
}
