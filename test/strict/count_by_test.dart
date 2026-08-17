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
        final res = fx(
          given,
        ).filter((a) => a.category != 'clothes').countBy((a) => a.category);
        expect(res, equals(then2));
      });

      // 0.8.4 counts into a mutable cell and rebuilds the map at the end, so
      // the properties the old read-modify-write loop got for free are pinned
      // down here.

      test('keys are in first-seen order, like groupBy', () {
        expect(
          countBy((Obj a) => a.category, given).keys.toList(),
          equals(groupBy((Obj a) => a.category, given).keys.toList()),
        );
      });

      test('an empty source yields an empty map', () {
        expect(
          countBy((Obj a) => a.category, const <Obj>[]),
          equals(<String, int>{}),
        );
      });

      test('equal but not identical keys share one count', () {
        // Two distinct String instances with the same contents: the cell is
        // found by `==`, not by identity, so these must not count separately.
        final a = 'ab';
        final b = String.fromCharCodes('ab'.codeUnits);
        expect(identical(a, b), isFalse);
        expect(countBy((String s) => s, [a, b, a]), equals({'ab': 3}));
      });

      test('a null key is counted like any other', () {
        expect(
          countBy((int? a) => a == null ? null : a.isEven, [1, null, 2, null]),
          equals({false: 1, null: 2, true: 1}),
        );
      });

      test('every key gets its own counter', () {
        // A cell accidentally shared between keys would show up as one key
        // holding the whole total.
        final counts = countBy(
          (int a) => a % 50,
          List.generate(1000, (i) => i),
        );
        expect(counts.length, equals(50));
        expect(counts.values.every((v) => v == 20), isTrue);
      });

      test('the callback runs once per element, in source order', () {
        final seen = <String>[];
        countBy((Obj a) {
          seen.add(a.category);
          return a.category;
        }, given);
        expect(seen, equals(given.map((a) => a.category).toList()));
      });

      test('agrees with groupBy lengths on a larger, skewed input', () {
        final xs = List.generate(5000, (i) => i % 7 == 0 ? 'a' : 'b$i');
        final viaGroup = groupBy(
          (String s) => s,
          xs,
        ).map((k, v) => MapEntry(k, v.length));
        expect(countBy((String s) => s, xs), equals(viaGroup));
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
