import 'package:daily_ledger/logic/errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fxdart/fxdart.dart' show Nel;

void main() {
  group('FieldError', () {
    test('renders as "field: detail"', () {
      expect(
        const FieldError('amount', 'not a number').message,
        'amount: not a number',
      );
    });

    test('has value equality, so tests can pin accumulated lists', () {
      expect(const FieldError('a', 'b'), const FieldError('a', 'b'));
      expect(const FieldError('a', 'b'), isNot(const FieldError('a', 'c')));
      expect(
        const FieldError('a', 'b').hashCode,
        const FieldError('a', 'b').hashCode,
      );
    });
  });

  group('RowError', () {
    test('one() wraps a single field', () {
      final e = RowError.one(4, const FieldError('date', 'bad'));
      expect(e.line, 4);
      expect(e.fields.head, const FieldError('date', 'bad'));
      expect(e.fields.tail, isEmpty);
      expect(e.message, 'line 4 — date: bad');
    });

    test('carries every bad field of the row, in order', () {
      final e = RowError(
        7,
        Nel.of(const FieldError('date', 'bad'), const [
          FieldError('amount', 'missing'),
        ]),
      );
      expect(e.message, 'line 7 — date: bad, amount: missing');
      // Nel.map preserves non-emptiness in the type, so `head` stays total
      // after mapping.
      expect(e.fields.map((f) => f.field).head, 'date');
    });
  });

  group('Nel as the error carrier', () {
    test(
      'orNull is the bridge from an accumulated list to "panel or none"',
      () {
        expect(Nel.orNull(<FieldError>[]), isNull);
        expect(
          Nel.orNull([const FieldError('a', 'b')])?.head,
          const FieldError('a', 'b'),
        );
      },
    );

    test('head cannot hit an empty receiver — that is the whole invariant', () {
      final errors = Nel.of(const FieldError('a', 'b'));
      expect(errors.head, isNotNull); // no isEmpty check needed anywhere
      expect(errors.tail, isEmpty);
    });

    test('+ merges two non-empty lists (header errors + row errors)', () {
      final merged =
          Nel.of(const FieldError('header', 'x')) +
          Nel.of(const FieldError('row', 'y'), const [FieldError('row', 'z')]);
      expect(merged.length, 3);
      expect(merged.head.field, 'header');
    });

    test('== is identity — use deepEquals for a structural comparison', () {
      // Extension types cannot override ==, so it stays List identity. This
      // is the trap the type forces you to think about: two Nels with equal
      // contents are NOT ==.
      final a = Nel.of(const FieldError('a', 'b'));
      final b = Nel.of(const FieldError('a', 'b'));
      expect(a == b, isFalse);
      expect(a.deepEquals(b), isTrue);
    });

    test('toList hands out a defensive copy', () {
      final errors = Nel.of(const FieldError('a', 'b'));
      errors.toList().add(const FieldError('c', 'd'));
      expect(errors.length, 1);
    });
  });

  test('LedgerError is sealed — switching over it is exhaustive', () {
    // No `default` arm: adding a subclass would be a compile error here,
    // which is the reason the family is sealed.
    String describe(LedgerError e) => switch (e) {
      FieldError(:final field) => 'field $field',
      RowError(:final line) => 'row $line',
    };
    expect(describe(const FieldError('amount', 'x')), 'field amount');
    expect(describe(RowError.one(2, const FieldError('a', 'b'))), 'row 2');
  });
}
