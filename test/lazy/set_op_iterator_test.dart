// `differenceBy` / `intersectionBy` walk a `List` second source by index
// rather than through an `Iterator<A>` field, which is what `size()` and any
// other pulling consumer reaches.
//
// The contract that matters is agreement: what the iterator yields has to
// match what `toList` produces, dedup included, on both the indexed branch
// and the pulled one. The two loops are written separately, so a divergence
// between them is exactly the bug this pins.
import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

class Tx {
  const Tx(this.id, this.tag);
  final int id;
  final String tag;
}

/// Pulls [it] one element at a time — the path `length` must agree with.
int pulled<A>(Iterable<A> it) {
  var n = 0;
  for (final _ in it) {
    n++;
  }
  return n;
}

void main() {
  const a = [1, 2, 3, 4];
  // 5 twice: the element dedup has to drop the repeat.
  const b = [3, 4, 5, 6, 5];

  group('length agrees with iteration', () {
    for (final (name, build) in <(String, Iterable<int> Function())>[
      ('difference', () => difference(a, b)),
      ('intersection', () => intersection(a, b)),
      ('differenceBy', () => differenceBy((int v) => v % 10, a, b)),
      ('intersectionBy', () => intersectionBy((int v) => v % 10, a, b)),
    ]) {
      test('$name — length, toList and a pull all agree', () {
        expect(build().length, build().toList().length);
        expect(build().length, pulled(build()));
        expect(fx(build()).size(), build().length);
      });
    }

    test('the dedup is counted, not just filtered', () {
      // b holds 5 twice and neither is in a, so difference yields [5, 6].
      expect(difference(a, b).toList(), [5, 6]);
      expect(difference(a, b).length, 2);
    });

    test('elements distinct by identity but equal by key both count', () {
      const before = [Tx(1, 'x')];
      const after = [Tx(1, 'p'), Tx(1, 'q')];
      final it = intersectionBy((Tx t) => t.id, before, after);

      expect(it.length, 2, reason: 'the dedup is by element, not by key');
      expect(it.length, pulled(it));
    });

    test('a repeated element counts once', () {
      const t = Tx(1, 'x');
      const before = [Tx(1, 'k')];
      const after = [t, t];
      final it = intersectionBy((Tx e) => e.id, before, after);

      expect(it.length, 1);
      expect(it.length, pulled(it));
    });
  });

  group('source shapes', () {
    Iterable<int> gen(List<int> xs) sync* {
      yield* xs;
    }

    test('a non-List second source is pulled and still agrees', () {
      expect(difference(a, gen(b)).length, difference(a, b).length);
      expect(difference(a, gen(b)).toList(), difference(a, b).toList());
      expect(pulled(difference(a, gen(b))), difference(a, b).length);
    });

    test('a non-List first source builds the same key set', () {
      expect(difference(gen(a), b).length, difference(a, b).length);
    });

    test('an empty second source counts nothing', () {
      expect(difference(a, const <int>[]).length, 0);
      expect(intersection(a, const <int>[]).length, 0);
    });

    test('an empty first source keeps everything difference sees', () {
      expect(
        difference(const <int>[], b).length,
        pulled(difference(const <int>[], b)),
      );
      expect(intersection(const <int>[], b).length, 0);
    });

    test('counting twice gives the same answer', () {
      final it = difference(a, b);
      expect(it.length, it.length);
      expect(it.length, it.toList().length);
    });
  });

  group('size() and the pulled path', () {
    test('counts a set operation without materialising it', () {
      expect(fx(intersection(a, b)).size(), 2);
      expect(fx(difference(a, b)).size(), 2);
    });

    test('and still counts a plain lazy chain', () {
      expect(fx([1, 2, 3, 4]).filter((v) => v.isEven).size(), 2);
      expect(fx([1, 2, 3]).map((v) => v * 2).size(), 3);
    });

    test('stays O(1)-shaped for a List or Set', () {
      expect(size([1, 2, 3]), 3);
      expect(size({1, 2, 3}), 3);
      expect(size(const <int>[]), 0);
    });
  });
}
