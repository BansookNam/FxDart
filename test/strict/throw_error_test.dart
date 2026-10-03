import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/throwError.spec.ts.
void main() {
  group('throwError', () {
    test('throw in a pipeline via unless', () {
      try {
        fxUnless<Object>(
          fxIsNum,
          fxThrowError((input) => Exception('input is $input')),
          '0',
        );
        fail('should have thrown');
      } on Exception catch (error) {
        expect(error.toString(), contains('input is 0'));
      }
    });

    test('throw error', () {
      try {
        fxThrowError((input) => Exception('input is $input'))(0);
      } on Exception catch (error) {
        expect(error.toString(), contains('input is 0'));
      }
    });
  });
}
