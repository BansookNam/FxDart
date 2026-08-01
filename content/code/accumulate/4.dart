import 'package:fxdart/fxdart.dart';

/// Two independent branches plus one rule that DEPENDS on both: an expense
/// needs a positive amount. Reading a sibling's .value is only safe once
/// every earlier branch succeeded — dependent runs its block exactly then.
EitherNel<String, String> classify(String type, String rawAmount) =>
    either<Nel<String>, String>((r) => r.accumulate((acc) {
          final t = acc.accumulating((br) => br.ensureNotNull(
              {'expense', 'income'}.contains(type) ? type : null,
              () => 'unknown type: $type'));
          final a = acc.accumulating((br) => br.ensureNotNull(
              double.tryParse(rawAmount), () => 'bad amount: $rawAmount'));

          // was: if (!acc.hasErrors) { acc.accumulating((br) => ...); }
          acc.dependent((br) {
            br.ensure(t.value != 'expense' || a.value > 0,
                () => 'an expense needs a positive amount');
            return null;
          });

          return '${t.value} of ${a.value}';
        }));

void main() {
  print(classify('expense', '12.5')); // Right(expense of 12.5)
  print(classify('expense', '-3'));
  // Left([an expense needs a positive amount])

  // Both independent branches fail — the dependent rule never runs, so
  // the report holds exactly the independent errors:
  print(classify('meal', 'x')); // Left([unknown type: meal, bad amount: x])
}
