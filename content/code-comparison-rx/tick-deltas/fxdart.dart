import 'package:fxdart/fxdart.dart';

// Closing price ticks for one symbol, oldest first.
const ticks = [101.20, 101.65, 101.40, 102.10, 102.10, 101.85, 102.30];

void main() {
  final deltas = fx(ticks)
      .pairwise() // each tick with its predecessor, as a (prev, next) record
      .map((p) {
        final d = p.$2 - p.$1;
        final sign = d >= 0 ? '+' : '';
        return '${p.$1.toStringAsFixed(2)} -> '
            '${p.$2.toStringAsFixed(2)}  $sign${d.toStringAsFixed(2)}';
      })
      .toList();

  deltas.forEach(print);
}
