import 'package:fxdart/fxdart.dart';

Either<String, int> bare() => either((r) {
  try {
    return int.parse('x');
    // expect_lint: avoid_bare_catch_in_raise
  } catch (e) {
    r.raise('bad');
  }
});

Either<String, int> onObject() => either((r) {
  try {
    return int.parse('x');
    // expect_lint: avoid_bare_catch_in_raise
  } on Object {
    r.raise('bad');
  }
});

Either<String, int> onException() => either((r) {
  try {
    return int.parse('x');
  } on Exception {
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
