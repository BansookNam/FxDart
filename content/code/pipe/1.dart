import 'package:fxdart/fxdart.dart';

void main() {
  // The honest downside of dynamic typing: a step that doesn't match what
  // the previous step produced is only caught at RUN time, not compile time.
  try {
    pipe(5, [
      (int n) => n + 1,
      (String s) => s.toUpperCase(), // wrong type — compiles fine!
    ]);
  } catch (e) {
    print('runtime error: ${e.runtimeType}');
  }

  // The typed alternative: fx() chains catch this at compile time instead.
  final safe = fx([1, 2, 3]).map((n) => n + 1).toArray();
  print(safe); // [2, 3, 4]
}
