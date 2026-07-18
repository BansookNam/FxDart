import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

Iterable<int> _sideEffectGen(List<int> seen) sync* {
  for (var i = 1; i <= 5; i++) {
    seen.add(i);
    yield i;
  }
}

void main() {
  group('consume', () {
    group('sync', () {
      test('should be consumed the given number', () {
        final seen = <int>[];
        consume(_sideEffectGen(seen), 2);
        expect(seen, equals([1, 2]));
      });

      test('should consume everything when n is omitted', () {
        final seen = <int>[];
        consume(_sideEffectGen(seen));
        expect(seen, equals([1, 2, 3, 4, 5]));
      });

      test('should consume everything when n exceeds the length', () {
        final seen = <int>[];
        consume(_sideEffectGen(seen), 100);
        expect(seen, equals([1, 2, 3, 4, 5]));
      });

      test('should be able to be used in the pipeline', () {
        var res = 0;
        fx([1, 2, 3, 4]).peek((a) {
          res += a;
        }).consume();
        expect(res, equals(10));
      });
    });

    group('async', () {
      test('should be consumed the given number', () async {
        final seen = <int>[];
        await consumeAsync(
            peekAsync((a) => seen.add(a), toAsync([1, 2, 3, 4, 5])), 2);
        expect(seen, equals([1, 2]));
      });

      test('should consume everything when n is omitted', () async {
        final seen = <int>[];
        await consumeAsync(
            peekAsync((a) => seen.add(a), toAsync([1, 2, 3, 4, 5])));
        expect(seen, equals([1, 2, 3, 4, 5]));
      });

      test('should be able to be used in the pipeline', () async {
        var res = 0;
        await fx([1, 2, 3, 4]).toAsync().peek((a) {
          res += a;
        }).consume();
        expect(res, equals(10));
      });
    });
  });
}
