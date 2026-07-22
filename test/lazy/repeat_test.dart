import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('repeat', () {
    test('should repeat returning specified value (int)', () {
      expect(toList(repeat(5, 4)), equals([4, 4, 4, 4, 4]));
    });

    test('should repeat returning specified value (string)', () {
      expect(toList(repeat(4, 'a')), equals(['a', 'a', 'a', 'a']));
    });

    test('should repeat a Future value as-is', () {
      final fut = Future.value('a');
      expect(toList(repeat(2, fut)), equals([fut, fut]));
    });

    test('should be able to be used in the pipeline', () {
      final res = pipe(5, [
        (int v) => repeat(4, v),
        (Iterable<int> v) => toList(v),
      ]);
      expect(res, equals([5, 5, 5, 5]));
    });
  });
}
