import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final calls = <String>[];
  final debounced =
      debounce<String>((s) => calls.add(s), const Duration(milliseconds: 100));

  // Simulates rapid typing: only the trailing call survives.
  debounced('a');
  debounced('b');
  debounced('c');
  print(calls); // [] — nothing has fired yet

  await sleep(const Duration(milliseconds: 150));
  print(calls); // [c] — only the last call, 100ms after it stopped
}
