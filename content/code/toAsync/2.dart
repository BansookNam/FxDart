import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final scores = [88, 42, 95, 61];

  // TODO: lift `scores` into an async pipeline with toAsync(), keep only
  // the passing scores (>= 60), and collect them with toListAsync.
  final passing = await toListAsync(toAsync(scores));

  print(passing); // currently [88, 42, 95, 61] — should be [88, 95]
}
