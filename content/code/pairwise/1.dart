import 'package:fxdart/fxdart.dart';

void main() {
  final prices = [102.0, 101.5, 103.2, 103.2, 99.8];

  // Both sides of every change stay in reach — value AND direction:
  final report = fx(prices)
      .pairwise()
      .map((p) => switch (p.$2.compareTo(p.$1)) {
            > 0 => '${p.$1} → ${p.$2}  ▲',
            < 0 => '${p.$1} → ${p.$2}  ▼',
            _ => '${p.$1} → ${p.$2}  =',
          })
      .toList();

  report.forEach(print);
  // 102.0 → 101.5  ▼
  // 101.5 → 103.2  ▲
  // 103.2 → 103.2  =
  // 103.2 → 99.8  ▼

  // Only the drops, with how far they fell:
  final drops = fx(prices)
      .pairwise()
      .filter((p) => p.$2 < p.$1)
      .map((p) => (p.$1 - p.$2).toStringAsFixed(1))
      .toList();
  print(drops); // [0.5, 3.4]
}
