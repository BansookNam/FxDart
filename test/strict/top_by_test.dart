import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// topBy / bottomBy keep a k-sized boundary instead of sorting the whole
// input, so what needs pinning is not the "k largest" part — it is the
// contract that lets a caller skip a second pass:
//
//   * the result is in descending (bottomBy: ascending) key order, and
//   * a tie is won by the element seen FIRST, both inside the boundary and
//     against the boundary's weakest member.
//
// The fixture has two pairs of tied keys (9 and 5) so both halves of that
// rule are exercised, and every case is run against a List source and a
// pulled source, which take different branches.
typedef Row = (String id, int score);

const _rows = <Row>[('a', 5), ('b', 9), ('c', 5), ('d', 1), ('e', 9)];

int _score(Row r) => r.$2;

List<String> _ids(Iterable<Row> rows) => [for (final r in rows) r.$1];

typedef NumericRow = (String id, double key);

const _numericRows = <NumericRow>[
  ('negative', -3.0),
  ('negative zero', -0.0),
  ('zero', 0.0),
  ('ordinary', 1.5),
  ('positive', 2.0),
  ('NaN', double.nan),
];

double _numericKey(NumericRow row) => row.$2;

List<String> _numericIds(Iterable<NumericRow> rows) => [
  for (final row in rows) row.$1,
];

Type _thrownType(void Function() action) {
  try {
    action();
  } on Object catch (error) {
    return error.runtimeType;
  }
  throw StateError('Expected action to throw');
}

void main() {
  group('topBy', () {
    test('returns the k largest, largest first', () {
      expect(_ids(topBy(2, _score, _rows)), ['b', 'e']);
    });

    test('ties keep input order', () {
      // 9 twice (b before e), then the first of the two 5s (a before c).
      expect(_ids(topBy(3, _score, _rows)), ['b', 'e', 'a']);
    });

    test('a key that only ties the boundary does not displace it', () {
      // e also scores 9, and b was seen first.
      expect(_ids(topBy(1, _score, _rows)), ['b']);
    });

    test('k = 0 is empty', () {
      expect(topBy(0, _score, _rows), <Row>[]);
    });

    test('a negative k is empty', () {
      expect(topBy(-3, _score, _rows), <Row>[]);
    });

    test('k = 1 is the single largest', () {
      expect(_ids(topBy(1, _score, [('x', 2), ('y', 7)])), ['y']);
    });

    test('k past the end returns everything, ordered', () {
      expect(_ids(topBy(10, _score, _rows)), ['b', 'e', 'a', 'c', 'd']);
    });

    test('empty input is empty for any k', () {
      expect(topBy(3, _score, <Row>[]), <Row>[]);
    });

    test('a pulled source agrees with a list', () {
      expect(
        _ids(topBy(3, _score, _rows.map((r) => r))),
        _ids(topBy(3, _score, _rows)),
      );
    });

    test('a partial insertion scan stops at the first key that is not '
        'smaller', () {
      expect(_ids(topBy(3, _score, [('p', 5), ('q', 1), ('r', 3)])), [
        'p',
        'r',
        'q',
      ]);
    });

    test('String keys compare as they do in sortBy', () {
      expect(_ids(topBy(2, (Row r) => r.$1, _rows)), ['e', 'd']);
    });

    test('keys that do not compare all tie, so the first k win', () {
      expect(_ids(topBy(2, (Row r) => null, _rows)), ['a', 'b']);
    });

    test('agrees with sortByDesc().take() on distinct keys', () {
      const distinct = <Row>[('a', 3), ('b', 8), ('c', 1), ('d', 6)];
      expect(
        _ids(topBy(2, _score, distinct)),
        _ids(sortByDesc(_score, distinct).take(2)),
      );
    });

    test('numeric ordering agrees with sortByDesc().take()', () {
      expect(
        _numericIds(topBy(4, _numericKey, _numericRows)),
        _numericIds(sortByDesc(_numericKey, _numericRows).take(4)),
      );
    });
  });

  group('bottomBy', () {
    test('returns the k smallest, smallest first', () {
      expect(_ids(bottomBy(2, _score, _rows)), ['d', 'a']);
    });

    test('ties keep input order', () {
      expect(_ids(bottomBy(3, _score, _rows)), ['d', 'a', 'c']);
    });

    test('a key that only ties the boundary does not displace it', () {
      expect(_ids(bottomBy(2, _score, [('p', 1), ('q', 5), ('r', 5)])), [
        'p',
        'q',
      ]);
    });

    test('k = 0 is empty', () {
      expect(bottomBy(0, _score, _rows), <Row>[]);
    });

    test('k past the end returns everything, ordered', () {
      expect(_ids(bottomBy(10, _score, _rows)), ['d', 'a', 'c', 'b', 'e']);
    });

    test('a pulled source agrees with a list', () {
      expect(
        _ids(bottomBy(3, _score, _rows.map((r) => r))),
        _ids(bottomBy(3, _score, _rows)),
      );
    });

    test('agrees with sortBy().take() on distinct keys', () {
      const distinct = <Row>[('a', 3), ('b', 8), ('c', 1), ('d', 6)];
      expect(
        _ids(bottomBy(2, _score, distinct)),
        _ids(sortBy(_score, distinct).take(2)),
      );
    });

    test('numeric ordering agrees with sortBy().take()', () {
      expect(
        _numericIds(bottomBy(4, _numericKey, _numericRows)),
        _numericIds(sortBy(_numericKey, _numericRows).take(4)),
      );
    });
  });

  group('comparison failures', () {
    test('incompatible Comparable keys fail as the sort family does', () {
      final values = <Object>['string', 1];
      Object key(Object value) => value;

      expect(
        _thrownType(() => topBy(1, key, values)),
        _thrownType(() => sortByDesc(key, values)),
      );
      expect(
        _thrownType(() => bottomBy(1, key, values)),
        _thrownType(() => sortBy(key, values)),
      );
    });
  });

  group('the async twins', () {
    test('topByAsync agrees with the sync spelling', () async {
      expect(
        _ids(await topByAsync(3, _score, toAsync(_rows))),
        _ids(topBy(3, _score, _rows)),
      );
    });

    test('bottomByAsync agrees with the sync spelling', () async {
      expect(
        _ids(await bottomByAsync(3, _score, toAsync(_rows))),
        _ids(bottomBy(3, _score, _rows)),
      );
    });

    test('numeric ordering agrees with the sort spellings', () async {
      expect(
        _numericIds(await topByAsync(4, _numericKey, toAsync(_numericRows))),
        _numericIds(sortByDesc(_numericKey, _numericRows).take(4)),
      );
      expect(
        _numericIds(
          await bottomByAsync(4, _numericKey, toAsync(_numericRows)),
        ),
        _numericIds(sortBy(_numericKey, _numericRows).take(4)),
      );
    });

    test('k = 0 is empty without pulling the source', () async {
      var pulled = 0;
      final source = toAsync(
        _rows.map((r) {
          pulled++;
          return r;
        }),
      );
      expect(await topByAsync(0, _score, source), <Row>[]);
      expect(pulled, 0);
    });

    test('bottomByAsync k = 0 is empty', () async {
      expect(await bottomByAsync(0, _score, toAsync(_rows)), <Row>[]);
    });

    test('an empty source is empty', () async {
      expect(await topByAsync(2, _score, toAsync(<Row>[])), <Row>[]);
    });
  });

  group('the chain members', () {
    test('Fx.topBy agrees with the top-level function', () {
      final Fx<Row> chained = fx(_rows).topBy(2, _score);
      expect(_ids(chained.toList()), _ids(topBy(2, _score, _rows)));
    });

    test('Fx.bottomBy agrees with the top-level function', () {
      final Fx<Row> chained = fx(_rows).bottomBy(2, _score);
      expect(_ids(chained.toList()), _ids(bottomBy(2, _score, _rows)));
    });

    test('Fx.topBy stays chainable', () {
      expect(fx(_rows).topBy(2, _score).map((r) => r.$1).toList(), ['b', 'e']);
    });

    test('FxAsync.topBy agrees with the top-level function', () async {
      expect(
        _ids(await fxAsync(toAsync(_rows)).topBy(2, _score)),
        _ids(topBy(2, _score, _rows)),
      );
    });

    test('FxAsync.bottomBy agrees with the top-level function', () async {
      expect(
        _ids(await fxAsync(toAsync(_rows)).bottomBy(2, _score)),
        _ids(bottomBy(2, _score, _rows)),
      );
    });
  });
}
