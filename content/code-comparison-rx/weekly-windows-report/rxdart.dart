import 'package:rxdart/rxdart.dart';

// Daily spend in cents, 2026-08-01 through 2026-08-21.
const dailyCents = [
  1240, 830, 1555, 905, 2210, 480, 1130, // week 1
  1875, 760, 1420, 2005, 640, 1310, 985, // week 2
  1050, 1660, 815, 2140, 505, 1275, 1730, // week 3
];

Future<void> main() async {
  final lines = await Stream.fromIterable(dailyCents)
      .bufferCount(7)
      // No indexed operator — scan is drafted as the week counter.
      .scan<(int, List<int>)>((acc, week, _) => (acc.$1 + 1, week), (0, []))
      .map((w) => 'week ${w.$1}: '
          '\$${w.$2.fold<double>(0, (s, c) => s + c / 100).toStringAsFixed(2)}')
      .toList();

  lines.forEach(print);
}
