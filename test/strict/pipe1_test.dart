import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/pipe1.spec.ts.
int add10(int a) => a + 10;
Future<int> add10Async(int a) async => a + 10;

void main() {
  group('pipe1', () {
    group('sync', () {
      test(
          'should return the value evaluated by applying the initial value to a given function',
          () {
        final result = pipe1(1, add10);
        expect(result, equals(11));
      });
    });

    group('async', () {
      test("should have an initial value of 'Future'", () async {
        final result = await pipe1(Future.value(1), add10);
        expect(result, equals(11));
      });

      test('should work even if the given function is asynchronous', () async {
        final result = await pipe1(1, add10Async);
        expect(result, equals(11));
      });

      test(
          "should work even if the given function is asynchronous and initial value is 'Future'",
          () async {
        final result = await pipe1(Future.value(1), add10Async);
        expect(result, equals(11));
      });
    });
  });
}
