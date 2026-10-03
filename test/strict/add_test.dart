import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('add', () {
    group('sync', () {
      test('should add two values', () {
        expect(fxAdd(1, 2), equals(3));
        expect(fxAdd('a', 'b'), equals('ab'));
      });

      test('should be able to be used as a closure in the pipeline', () {
        final res1 = fx([1]).map((a) => fxAdd(2, a)).head();
        expect(res1, equals(3));
        final res2 = fx(['b']).map((a) => fxAdd('a', a)).head();
        expect(res2, equals('ab'));
      });
    });

    group('async', () {
      test('should add two awaited values', () async {
        expect(fxAdd(await Future.value(1), 2), equals(3));
        expect(fxAdd(1, await Future.value(2)), equals(3));
        expect(fxAdd(await Future.value(1), await Future.value(2)), equals(3));
        expect(fxAdd(await Future.value('a'), 'b'), equals('ab'));
        expect(fxAdd('a', await Future.value('b')), equals('ab'));
        expect(
          fxAdd(await Future.value('a'), await Future.value('b')),
          equals('ab'),
        );
      });

      test('should be able to be used in an async pipeline', () async {
        final res1 = await fx([1]).toAsync().map((a) => fxAdd(2, a)).head();
        expect(res1, equals(3));
        final res2 = await fx(['b']).toAsync().map((a) => fxAdd('a', a)).head();
        expect(res2, equals('ab'));
      });
    });
  });
}
