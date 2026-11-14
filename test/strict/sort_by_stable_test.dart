import 'dart:math' as math;

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// fxSortBy was stable on int/double keys only until 0.9.1; String and mixed
// keys went through List.sort, which is not. Above 32 elements List.sort
// switches from insertion sort to quicksort, which is where ties moved.
void main() {
  final rnd = math.Random(11);
  final rows = [for (var i = 0; i < 500; i++) (k: 'k${rnd.nextInt(6)}', i: i)];

  bool stableAsc(List<({String k, int i})> xs) {
    for (var j = 1; j < xs.length; j++) {
      final c = xs[j - 1].k.compareTo(xs[j].k);
      if (c > 0 || (c == 0 && xs[j - 1].i > xs[j].i)) return false;
    }
    return true;
  }

  test('String keys keep source order on ties', () {
    expect(stableAsc(fxSortBy((({String k, int i}) r) => r.k, rows)), isTrue);
    expect(stableAsc(fx(rows).sortBy((r) => r.k).toList()), isTrue);
  });

  test('descending String keys keep source order on ties', () {
    final out = sortByDesc((({String k, int i}) r) => r.k, rows);
    for (var j = 1; j < out.length; j++) {
      final c = out[j - 1].k.compareTo(out[j].k);
      expect(c > 0 || (c == 0 && out[j - 1].i < out[j].i), isTrue);
    }
  });

  test('generic (DateTime) keys keep source order on ties', () {
    final d = [
      for (var i = 0; i < 300; i++)
        (t: DateTime(2026, 1, 1 + rnd.nextInt(3)), i: i),
    ];
    final out = fxSortBy((({DateTime t, int i}) r) => r.t, d);
    for (var j = 1; j < out.length; j++) {
      final c = out[j - 1].t.compareTo(out[j].t);
      expect(c < 0 || (c == 0 && out[j - 1].i < out[j].i), isTrue);
    }
  });

  test('spilled (mixed int/double) keys keep source order on ties', () {
    final m = [for (var i = 0; i < 300; i++) (v: i.isEven ? 1 : 1.0, i: i)];
    final out = fxSortBy((({num v, int i}) r) => r.v, m);
    expect(out.map((r) => r.i).toList(), [for (var i = 0; i < 300; i++) i]);
  });
}
