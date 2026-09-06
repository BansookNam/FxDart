import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

int doubleIt(int x) => x * 2;
int addTen(int x) => x + 10;
String stringify(int x) => '$x';

void main() {
  group('fxPipe', () {
    test('with no then is the function itself', () {
      expect(fxPipe(doubleIt)(3), 6);
    });

    test('the last then is the composed function', () {
      final f = fxPipe(doubleIt).then(addTen);
      expect(f(3), 16);
      expect(f(4), 18);
    });

    test('longer chains stay typed and left-to-right', () {
      final f = fxPipe(doubleIt).then(addTen).then(stringify);
      expect(f(3), '16');
    });

    test('then is available on a bare tear-off', () {
      expect(doubleIt.then(addTen)(3), 16);
    });

    test('works as a map callback', () {
      expect(
        fx([1, 2, 3]).map(fxPipe(doubleIt).then(addTen)).toList(),
        equals([12, 14, 16]),
      );
    });
  });

  group('fxPipe2..5', () {
    test('one closure, same values as then', () {
      expect(fxPipe2(doubleIt, addTen)(3), 16);
      expect(fxPipe(doubleIt).then(addTen)(3), 16);
      expect(fxPipe3(doubleIt, addTen, stringify)(3), '16');
      expect(fxPipe(doubleIt).then(addTen).then(stringify)(3), '16');
    });

    test('fxPipe4 and fxPipe5 keep left-to-right', () {
      expect(fxPipe4(doubleIt, addTen, doubleIt, addTen)(1), 34);
      expect(fxPipe5(doubleIt, addTen, doubleIt, addTen, doubleIt)(1), 68);
    });

    test('works as a map callback', () {
      expect(
        fx([1, 2, 3]).map(fxPipe2(doubleIt, addTen)).toList(),
        equals([12, 14, 16]),
      );
    });
  });
}
