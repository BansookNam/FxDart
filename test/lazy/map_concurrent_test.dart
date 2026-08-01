import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('mapConcurrent', () {
    group('sync source', () {
      test('should map every element and keep source order', () async {
        final result =
            await toListAsync(mapConcurrent(3, (int n) async => n * 10, [1, 2, 3, 4, 5]));
        expect(result, equals([10, 20, 30, 40, 50]));
      });

      test('should evaluate up to [concurrency] elements at once', () async {
        var inFlight = 0;
        var maxInFlight = 0;
        Future<int> work(int n) async {
          inFlight++;
          if (inFlight > maxInFlight) maxInFlight = inFlight;
          await Future.delayed(const Duration(milliseconds: 5));
          inFlight--;
          return n;
        }

        final result =
            await toListAsync(mapConcurrent(3, work, [1, 2, 3, 4, 5, 6]));
        expect(result, equals([1, 2, 3, 4, 5, 6]));
        expect(maxInFlight, equals(3));
      });

      test('should keep source order even when later elements finish first',
          () async {
        Future<int> work(int n) async {
          await Future.delayed(Duration(milliseconds: n.isEven ? 1 : 15));
          return n;
        }

        final result = await toListAsync(mapConcurrent(4, work, [1, 2, 3, 4]));
        expect(result, equals([1, 2, 3, 4]));
      });

      test('should accept a synchronous callback', () async {
        final result =
            await toListAsync(mapConcurrent(2, (int n) => n + 1, [1, 2, 3]));
        expect(result, equals([2, 3, 4]));
      });

      test('should handle an empty iterable', () async {
        final result =
            await toListAsync(mapConcurrent(3, (int n) async => n, <int>[]));
        expect(result, isEmpty);
      });

      test('should be able to be used in the pipeline', () async {
        var maxInFlight = 0;
        var inFlight = 0;
        final result = await fx([1, 2, 3, 4, 5, 6])
            .filter((n) => n.isEven)
            .mapConcurrent(2, (n) async {
              inFlight++;
              if (inFlight > maxInFlight) maxInFlight = inFlight;
              await Future.delayed(const Duration(milliseconds: 5));
              inFlight--;
              return n * 10;
            })
            .toList();
        expect(result, equals([20, 40, 60]));
        expect(maxInFlight, equals(2));
      });
    });

    group('async source', () {
      test('should map every element and keep source order', () async {
        final result = await toListAsync(
            mapConcurrentAsync(3, (int n) async => n * 10, toAsync([1, 2, 3])));
        expect(result, equals([10, 20, 30]));
      });

      test('should evaluate up to [concurrency] elements at once', () async {
        var inFlight = 0;
        var maxInFlight = 0;
        final result = await fxAsync(toAsync([1, 2, 3, 4, 5, 6]))
            .mapConcurrent(3, (n) async {
          inFlight++;
          if (inFlight > maxInFlight) maxInFlight = inFlight;
          await Future.delayed(const Duration(milliseconds: 5));
          inFlight--;
          return n;
        }).toList();
        expect(result, equals([1, 2, 3, 4, 5, 6]));
        expect(maxInFlight, equals(3));
      });

      test('should behave exactly like map + concurrent', () async {
        Future<int> work(int n) async {
          await Future.delayed(const Duration(milliseconds: 2));
          return n * 3;
        }

        final combined =
            await fx([1, 2, 3, 4]).toAsync().mapConcurrent(2, work).toList();
        final split = await fx([1, 2, 3, 4])
            .toAsync()
            .map(work)
            .concurrent(2)
            .toList();
        expect(combined, equals(split));
      });

      test('should be able to be used mid-pipeline', () async {
        final result = await fxStream(Stream.fromIterable([1, 2, 3, 4]))
            .mapConcurrent(2, (n) async => n * 2)
            .filter((n) => n > 2)
            .toList();
        expect(result, equals([4, 6, 8]));
      });
    });
  });
}
