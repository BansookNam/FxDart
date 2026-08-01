import 'package:fxdart/fxdart.dart' hide isEmpty, isNotNull, isNull;
import 'package:test/test.dart';

void main() {
  group('Accumulator.dependent', () {
    test('should run the block when no branch has failed', () {
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            final a = acc.accumulating((_) => 2);
            final b = acc.dependent((_) => a.value + 1);
            return b.value;
          }));
      expect(result, equals(const Right<Nel<String>, int>(3)));
    });

    test('should skip the block entirely once a branch has failed', () {
      var ran = false;
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            acc.accumulating<int>((br) => br.raise('bad'));
            acc.dependent((_) {
              ran = true;
              return 1;
            });
            return 0;
          }));
      expect(ran, isFalse);
      expect(result.leftOrNull()!.toList(), equals(['bad']));
    });

    test('should detonate with the accumulated errors when reading a '
        'skipped dependent value', () {
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            acc.accumulating<int>((br) => br.raise('first'));
            acc.accumulating<int>((br) => br.raise('second'));
            final d = acc.dependent((_) => 1);
            return d.value;
          }));
      expect(result.leftOrNull()!.toList(), equals(['first', 'second']));
    });

    test('should accumulate errors raised inside a running dependent block',
        () {
      final result = either<Nel<String>, int>((r) => r.accumulate((acc) {
            final a = acc.accumulating((_) => 1);
            acc.dependent<int>((br) => br.raise('dependent failed'));
            return a.value;
          }));
      expect(result.leftOrNull()!.toList(), equals(['dependent failed']));
    });

    test('should report hasErrors after a failed dependent block', () {
      either<Nel<String>, int>((r) => r.accumulate((acc) {
            expect(acc.hasErrors, isFalse);
            acc.dependent<int>((br) => br.raise('e'));
            expect(acc.hasErrors, isTrue);
            return 0;
          }));
    });

    test('should let a dependent rule read sibling values safely', () {
      // The round-11 daily_ledger shape: an amount rule that depends on the
      // parsed type — only evaluated when both independent branches parsed.
      Either<Nel<String>, (String, double)> parse(String type, String amount) =>
          either<Nel<String>, (String, double)>((r) => r.accumulate((acc) {
                final t = acc.accumulating((br) => br.ensureNotNull(
                    ['expense', 'income'].contains(type) ? type : null,
                    () => 'unknown type'));
                final a = acc.accumulating((br) => br.ensureNotNull(
                    double.tryParse(amount), () => 'bad amount'));
                acc.dependent((br) {
                  br.ensure(t.value != 'expense' || a.value > 0,
                      () => 'an expense needs a positive amount');
                  return null;
                });
                return (t.value, a.value);
              }));

      expect(parse('expense', '5.0').getOrNull(), equals(('expense', 5.0)));
      expect(parse('expense', '-1').leftOrNull()!.toList(),
          equals(['an expense needs a positive amount']));
      // Both independent branches fail: the dependent rule never runs, so
      // the report holds exactly the two independent errors.
      expect(parse('meal', 'x').leftOrNull()!.toList(),
          equals(['unknown type', 'bad amount']));
    });
  });
}
