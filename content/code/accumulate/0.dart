import 'package:fxdart/fxdart.dart';

// EitherNel<E, A> = Either<Nel<E>, A>: the failure side carries EVERY error.
EitherNel<String, (String, int)> validate(String name, int age) =>
    either((r) => r.zipOrAccumulate2(
          (r) {
            r.ensure(name.isNotEmpty, () => 'name is empty');
            return name;
          },
          (r) {
            r.ensure(age >= 0, () => 'age is negative');
            return age;
          },
          (name, age) => (name, age),
        ));

void main() {
  print(validate('kim', 30)); // Right((kim, 30))

  // Both branches run — both failures are reported, not just the first:
  print(validate('', -1)); // Left([name is empty, age is negative])
}
