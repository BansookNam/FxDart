import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('flattenOrAccumulate', () {
    group('sync', () {
      test('should collect every success when nothing failed', () {
        final result = flattenOrAccumulate<String, int>(
            [const Right(1), const Right(2), const Right(3)]);
        expect(result.getOrNull(), equals([1, 2, 3]));
      });

      test('should collect EVERY failure, in order', () {
        final result = flattenOrAccumulate<String, int>([
          const Right(1),
          const Left('first'),
          const Right(2),
          const Left('second'),
        ]);
        expect(result.leftOrNull()!.toList(), equals(['first', 'second']));
      });

      test('should return Right([]) for an empty iterable', () {
        final result = flattenOrAccumulate<String, int>(const []);
        expect(result.getOrNull(), isEmpty);
      });

      test('should match the hand-rolled mapOrAccumulate + bind', () {
        final verdicts = <Either<String, int>>[
          const Right(1),
          const Left('e1'),
          const Left('e2'),
        ];
        final handRolled = fx(verdicts)
            .mapOrAccumulate<String, int>((r, verdict) => r.bind(verdict));
        final combined = flattenOrAccumulate(verdicts);
        expect(combined.leftOrNull()!.deepEquals(handRolled.leftOrNull()!),
            isTrue);
      });

      test('should be fail-slow where sequence is fail-fast', () {
        final verdicts = <Either<String, int>>[
          const Left('a'),
          const Right(1),
          const Left('b'),
        ];
        expect(fx(verdicts).sequence().leftOrNull(), equals('a'));
        expect(fx(verdicts).flattenOrAccumulate().leftOrNull()!.toList(),
            equals(['a', 'b']));
      });

      test('should be able to be used as a chain terminal', () {
        Either<String, int> parse(String s) => either<String, int>(
            (r) => r.ensureNotNull(int.tryParse(s), () => 'bad: $s'));
        final result = fx(['1', 'x', '3', 'y'])
            .map(parse)
            .flattenOrAccumulate();
        expect(result.leftOrNull()!.toList(), equals(['bad: x', 'bad: y']));
      });
    });

    group('async', () {
      test('should collect every success when nothing failed', () async {
        final result = await flattenOrAccumulateAsync<String, int>(
            toAsync([const Right(1), const Right(2)]));
        expect(result.getOrNull(), equals([1, 2]));
      });

      test('should consume the whole upstream (fail-slow)', () async {
        var pulled = 0;
        final result = await fx(<Either<String, int>>[
          const Left('first'),
          const Right(1),
          const Left('last'),
        ])
            .toAsync()
            .peek((_) => pulled++)
            .flattenOrAccumulate();
        expect(pulled, equals(3));
        expect(result.leftOrNull()!.toList(), equals(['first', 'last']));
      });

      test('should be able to be used as a chain terminal', () async {
        final result = await fx([1, -2, 3, -4])
            .toAsync()
            .map((n) => either<String, int>((r) {
                  r.ensure(n > 0, () => '$n is negative');
                  return n;
                }))
            .flattenOrAccumulate();
        expect(result.leftOrNull()!.toList(),
            equals(['-2 is negative', '-4 is negative']));
      });
    });
  });
}
