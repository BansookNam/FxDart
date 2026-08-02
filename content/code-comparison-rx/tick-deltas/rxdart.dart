import 'package:rxdart/rxdart.dart';

// Closing price ticks for one symbol, oldest first.
const ticks = [101.20, 101.65, 101.40, 102.10, 102.10, 101.85, 102.30];

Future<void> main() async {
  final deltas = await Stream.fromIterable(ticks)
      .pairwise() // each tick with its predecessor, as a 2-element list
      .map((p) {
        final d = p.last - p.first;
        final sign = d >= 0 ? '+' : '';
        return '${p.first.toStringAsFixed(2)} -> '
            '${p.last.toStringAsFixed(2)}  $sign${d.toStringAsFixed(2)}';
      })
      .toList();

  deltas.forEach(print);
}
