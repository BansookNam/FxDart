import 'package:fxdart/fxdart.dart';

Either<String, int> lookup(String where, int? value) {
  print('tried $where');
  return value == null ? Left('$where miss') : Right(value);
}

void main() {
  // alt is a fallback ladder: nothing after the first hit is touched.
  print(lookup('cache', null)
      .alt(() => lookup('disk', 7))
      .alt(() => lookup('network', 9)));
  // tried cache / tried disk / Right(7)

  // orElse gets to see what went wrong.
  print(Left<String, int>('boom').orElse<String>((e) => Left('wrapped: $e')));
  // Left(wrapped: boom)

  // filterOrElse demotes a Right whose value fails a check.
  print(Right<String, int>(200)
      .filterOrElse((n) => n < 150, (n) => 'age $n is implausible'));
  // Left(age 200 is implausible)
}
