import 'package:fxdart/fxdart.dart';

Either<String, int> bare() => fxEither((r) {
  try {
    return int.parse('x');
    // expect_lint: avoid_bare_catch_in_raise
  } catch (e) {
    r.raise('bad');
  }
});

Either<String, int> onObject() => fxEither((r) {
  try {
    return int.parse('x');
    // expect_lint: avoid_bare_catch_in_raise
  } on Object {
    r.raise('bad');
  }
});

Either<String, int> onException() => fxEither((r) {
  try {
    return int.parse('x');
  } on Exception {
    r.raise('bad');
  }
});

Either<String, int> onError() => fxEither((r) {
  try {
    return int.parse('x');
    // expect_lint: avoid_bare_catch_in_raise
  } on Error {
    r.raise('bad');
  }
});

Either<String, int> onSpecific() => fxEither((r) {
  try {
    return int.parse('x');
  } on FormatException {
    r.raise('bad');
  }
});

int outside() {
  try {
    return 1;
  } catch (e) {
    return 0;
  }
}
