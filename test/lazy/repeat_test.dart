import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('repeat', () {
    test('should repeat returning specified value (int)', () {
      expect(fxToList(fxRepeat(5, 4)), equals([4, 4, 4, 4, 4]));
    });

    test('should repeat returning specified value (string)', () {
      expect(fxToList(fxRepeat(4, 'a')), equals(['a', 'a', 'a', 'a']));
    });

    test('should repeat a Future value as-is', () {
      final fut = Future.value('a');
      expect(fxToList(fxRepeat(2, fut)), equals([fut, fut]));
    });

    test('should be able to be used in the pipeline', () {
      final res = pipe(5, [
        (int v) => fxRepeat(4, v),
        (Iterable<int> v) => fxToList(v),
      ]);
      expect(res, equals([5, 5, 5, 5]));
    });
  });
}
