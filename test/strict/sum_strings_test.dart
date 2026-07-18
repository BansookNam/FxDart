import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('sumStrings', () {
    test('should concatenate every string', () {
      expect(sumStrings(['a', 'b', 'c']), equals('abc'));
    });

    test('should return an empty string for an empty iterable', () {
      expect(sumStrings(<String>[]), equals(''));
    });

    test('should be able to be used in the pipeline', () {
      final res = pipe(['a', 'b'], [sumStrings]);
      expect(res, equals('ab'));
    });
  });

  group('reduceAsync', () {
    test('should reduce without an initial value', () async {
      expect(await reduceAsync((acc, a) => acc + a, toAsync([1, 2, 3])),
          equals(6));
    });

    test('should support an asynchronous reducer', () async {
      expect(
        await reduceAsync((acc, a) async => acc + a, toAsync([1, 2, 3])),
        equals(6),
      );
    });

    test('should return the only element of a single-element iterable',
        () async {
      expect(await reduceAsync((acc, a) => acc + a, toAsync([7])), equals(7));
    });

    test('should throw on an empty iterable with no initial value', () {
      expect(
        reduceAsync<int>((acc, a) => acc + a, toAsync(<int>[])),
        throwsStateError,
      );
    });
  });
}
