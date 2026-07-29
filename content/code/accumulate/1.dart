import 'package:fxdart/fxdart.dart';

// The general form: open an accumulating scope with r.accumulate, run each
// branch with acc.accumulating, combine the .value results at the end.
EitherNel<String, String> validate(Map<String, String> input) =>
    either((r) => r.accumulate((acc) {
          final name = acc.accumulating((r) {
            final v = r.ensureNotNull(input['name'], () => 'name missing');
            r.ensure(v.isNotEmpty, () => 'name is empty');
            return v;
          });
          final age = acc.accumulating((r) {
            final raw = r.ensureNotNull(input['age'], () => 'age missing');
            return r.ensureNotNull(
                int.tryParse(raw), () => 'age is not a number');
          });
          // Reading .value raises the FULL error list if anything failed:
          return '${name.value} (${age.value})';
        }));

void main() {
  print(validate({'name': 'kim', 'age': '30'})); // Right(kim (30))
  print(validate({'name': '', 'age': 'abc'}));
  // Left([name is empty, age is not a number])
}
