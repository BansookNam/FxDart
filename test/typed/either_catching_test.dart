import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('eitherCatching', () {
    group('sync', () {
      test('should return Right on success', () {
        final result = eitherCatching<String, int>((r) => 42, (e, _) => '$e');
        expect(result, equals(const Right<String, int>(42)));
      });

      test('should return Left when the block raises', () {
        final result = eitherCatching<String, int>(
          (r) => r.raise('typed'),
          (e, _) => 'thrown: $e',
        );
        expect(result, equals(const Left<String, int>('typed')));
      });

      test('should hand a thrown exception to onThrow', () {
        final result = eitherCatching<String, int>(
          (r) => throw const FormatException('bad'),
          (e, _) => 'caught: ${(e as FormatException).message}',
        );
        expect(result, equals(const Left<String, int>('caught: bad')));
      });

      test('should receive the stack trace in onThrow', () {
        StackTrace? seen;
        eitherCatching<String, int>((r) => throw StateError('x'), (e, st) {
          seen = st;
          return 'e';
        });
        expect(seen, isNotNull);
      });

      test('should rethrow a foreign scope signal instead of catching it', () {
        var onThrowRan = false;
        final outer = either<String, int>((outerR) {
          eitherCatching<int, int>((_) => outerR.raise('outer error'), (e, _) {
            onThrowRan = true;
            return -1;
          });
          return 0;
        });
        expect(outer, equals(const Left<String, int>('outer error')));
        expect(onThrowRan, isFalse);
      });

      test('should replace the either + catching envelope', () {
        Either<String, int> viaEnvelope(String raw) => either<String, int>(
          (r) => catching(
            () => int.parse(raw) * 2,
            (e, _) => r.raise('unparseable'),
          ),
        );
        Either<String, int> viaCombined(String raw) =>
            eitherCatching<String, int>(
              (r) => int.parse(raw) * 2,
              (e, _) => 'unparseable',
            );
        expect(viaCombined('21'), equals(viaEnvelope('21')));
        expect(viaCombined('nope'), equals(viaEnvelope('nope')));
      });
    });

    group('async', () {
      test('should return Right on success', () async {
        final result = await eitherCatchingAsync<String, int>((r) async {
          await Future.delayed(Duration.zero);
          return 7;
        }, (e, _) => '$e');
        expect(result, equals(const Right<String, int>(7)));
      });

      test('should return Left when the block raises after an await', () async {
        final result = await eitherCatchingAsync<String, int>((r) async {
          await Future.delayed(Duration.zero);
          r.raise('typed');
        }, (e, _) => 'thrown');
        expect(result, equals(const Left<String, int>('typed')));
      });

      test(
        'should hand an exception thrown after an await to onThrow',
        () async {
          final result = await eitherCatchingAsync<String, int>((r) async {
            await Future.delayed(Duration.zero);
            throw StateError('boom');
          }, (e, _) async => 'caught');
          expect(result, equals(const Left<String, int>('caught')));
        },
      );

      test(
        'should rethrow a foreign scope signal instead of catching it',
        () async {
          var onThrowRan = false;
          final outer = await eitherAsync<String, int>((outerR) async {
            await eitherCatchingAsync<int, int>(
              (_) async => outerR.raise('outer'),
              (e, _) {
                onThrowRan = true;
                return -1;
              },
            );
            return 0;
          });
          expect(outer, equals(const Left<String, int>('outer')));
          expect(onThrowRan, isFalse);
        },
      );
    });
  });
}
