import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final scores = [3, 9, 4, 10, 8];

  // atMost: "no more than n" — false as soon as n + 1 match.
  print(fx(scores).atMost(2, (s) => s >= 8)); // false (three do)
  print(fx(scores).atMost(3, (s) => s >= 8)); // true

  // The edges: atLeast(1) is some, atMost(0) is none.
  print(fx(scores).atLeast(1, (s) => s > 9)); // true
  print(fx(scores).atMost(0, (s) => s > 10)); // true

  // Async: upstream is cancelled at the deciding match.
  final ok = await fxAsync(fxToAsync(scores))
      .atLeast(2, (s) async => s > 5);
  print(ok); // true
}
