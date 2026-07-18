import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final calls = <String>[];
  final throttled =
      throttle<String>((s) => calls.add(s), const Duration(milliseconds: 100));

  // Default is leading: true, trailing: true.
  throttled('a'); // fires immediately (leading edge)
  print(calls); // [a]

  throttled('b');
  throttled('c'); // both arrive inside the 100ms window, so they're throttled
  print(calls); // [a] — still just the leading call

  await sleep(const Duration(milliseconds: 150));
  print(calls); // [a, c] — trailing edge fires with the latest argument
}
