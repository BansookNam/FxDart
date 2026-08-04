import 'package:fxdart/fxdart.dart';

void main() {
  // The two accumulators are independent, and need not share a type:
  final (chars, longest) = tee2(
      ['alpha', 'be', 'gamma!', 'de'],
      (seed: 0, step: (int acc, String s) => acc + s.length),
      (seed: '', step: (String acc, String s) => s.length > acc.length ? s : acc));

  print('chars: $chars'); // 15
  print('longest: $longest'); // gamma!

  // tee3 adds a third. Here: sum, max, and a running count.
  final (sum, max, count) = tee3(
      [4, 8, 2],
      (seed: 0, step: (int a, int x) => a + x),
      (seed: 0, step: (int a, int x) => x > a ? x : a),
      (seed: 0, step: (int a, int _) => a + 1));

  print('$sum / $max / $count'); // 14 / 8 / 3

  // On a chain, tee2 folds what the chain produces — not the source:
  final (odds, doubled) = fx([1, 2, 3, 4, 5])
      .filter((a) => a.isOdd)
      .tee2((seed: 0, step: (int a, int x) => a + 1),
          (seed: <int>[], step: (List<int> a, int x) => a..add(x * 2)));

  print('$odds odd values, doubled: $doubled'); // 3 odd values, doubled: [2, 6, 10]
}
