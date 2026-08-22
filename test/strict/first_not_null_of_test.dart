import 'package:fxdart/fxdart.dart' hide isEmpty, isNull;
import 'package:test/test.dart';

// firstNotNullOf returns the *projection* of the first hit, which is what
// find cannot do. A null projection means "no result here", so it is skipped
// rather than returned. Both the indexed list loop and the pulled loop run.
void main() {
  group('firstNotNullOf', () {
    test('returns the first non-null projection', () {
      expect(firstNotNullOf((String s) => int.tryParse(s), ['x', '2', '3']), 2);
    });

    test('null when every projection is null', () {
      expect(firstNotNullOf((String s) => int.tryParse(s), ['x', 'y']), isNull);
    });

    test('null on empty input', () {
      expect(firstNotNullOf((int a) => a, <int>[]), isNull);
    });

    test('single element, hit and miss', () {
      expect(firstNotNullOf((int a) => a.isEven ? 'even' : null, [2]), 'even');
      expect(firstNotNullOf((int a) => a.isEven ? 'even' : null, [1]), isNull);
    });

    test('short-circuits at the first hit', () {
      var seen = 0;
      final res = firstNotNullOf((int a) {
        seen++;
        return a > 1 ? a * 10 : null;
      }, [1, 2, 3, 4]);
      expect(res, 20);
      expect(seen, 2);
    });

    test('a pulled source agrees with a list', () {
      String? f(int a) => a > 2 ? 'v$a' : null;
      expect(
        firstNotNullOf(f, Iterable<int>.generate(5)),
        firstNotNullOf(f, [0, 1, 2, 3, 4]),
      );
      expect(firstNotNullOf(f, Iterable<int>.generate(2)), isNull);
    });

    test('returns the projection, where find returns the element', () {
      final xs = ['x', '2', '3'];
      expect(firstNotNullOf((String s) => int.tryParse(s), xs), 2);
      expect(find((String s) => int.tryParse(s) != null, xs), '2');
    });

    test('async agrees with the sync spelling', () async {
      int? f(String s) => int.tryParse(s);
      final xs = ['x', '2', '3'];
      expect(await firstNotNullOfAsync(f, toAsync(xs)), firstNotNullOf(f, xs));
      expect(await firstNotNullOfAsync(f, toAsync(['x'])), isNull);
      expect(await firstNotNullOfAsync(f, toAsync(<String>[])), isNull);
    });

    test('async awaits the projection', () async {
      expect(
        await firstNotNullOfAsync(
          (int a) async => a > 1 ? a * 10 : null,
          toAsync([1, 2, 3]),
        ),
        20,
      );
    });

    test('Fx.firstNotNullOf agrees with the top-level function', () {
      int? f(String s) => int.tryParse(s);
      final xs = ['x', '2', '3'];
      expect(fx(xs).firstNotNullOf(f), firstNotNullOf(f, xs));
      expect(fx(['x']).firstNotNullOf(f), isNull);
    });

    test('FxAsync.firstNotNullOf agrees with the top-level function', () async {
      int? f(String s) => int.tryParse(s);
      final xs = ['x', '2', '3'];
      expect(
        await fxAsync(toAsync(xs)).firstNotNullOf(f),
        firstNotNullOf(f, xs),
      );
      expect(await fxAsync(toAsync(['x'])).firstNotNullOf(f), isNull);
    });
  });
}
