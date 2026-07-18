import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

typedef Obj = ({String category, String desc});

const given = <Obj>[
  (category: 'clothes', desc: 'good'),
  (category: 'pants', desc: 'bad'),
  (category: 'shoes', desc: 'not bad'),
  (category: 'shoes', desc: 'great'),
  (category: 'pants', desc: 'good'),
];

const then1 = {'clothes': 1, 'pants': 2, 'shoes': 2};
const then2 = {'pants': 2, 'shoes': 2};

void main() {
  group('countBy', () {
    group('sync', () {
      test("should be counted by callback to the 'Iterable'", () {
        final res = countBy((Obj a) => a.category, given);
        expect(res, equals(then1));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx(given)
            .filter((a) => a.category != 'clothes')
            .countBy((a) => a.category);
        expect(res, equals(then2));
      });
    });

    group('async', () {
      test("should be counted by callback to the 'AsyncIterable'", () async {
        final res = await countByAsync((Obj a) => a.category, toAsync(given));
        expect(res, equals(then1));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fx(given)
            .toAsync()
            .filter((a) => a.category != 'clothes')
            .countBy((a) => a.category);
        expect(res, equals(then2));
      });
    });
  });
}
