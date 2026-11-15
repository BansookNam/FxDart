import 'package:fxdart/fxdart.dart';

int ageOf(Raise<String> r, String raw) {
  final age = r.ensureNotNull(int.tryParse(raw), () => 'not a number');
  r.ensure(age >= 18, () => 'too young');
  return age;
}

void main() {
  // TODO: fold the scope directly with fxFoldRaise<String, int, String>
  // (onValue / onRaise) instead of building an Either and switching on it.
  String check(String raw) =>
      switch (fxEither<String, int>((r) => ageOf(r, raw))) {
        Right(:final value) => 'welcome, $value',
        Left(:final value) => 'denied: $value',
      };

  print([check('30'), check('12'), check('?')]);
  // should print: [welcome, 30, denied: too young, denied: not a number]
}
