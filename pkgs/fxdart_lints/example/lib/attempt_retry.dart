import 'package:fxdart/fxdart.dart';

FxEvents<Either<String, int>> before() {
  return fxEvents(Stream<int>.empty())
      .attempt((e, st) => e.toString())
      // expect_lint: attempt_after_retry
      .retryOnError();
}

FxEvents<Either<String, int>> after() {
  return fxEvents(
    Stream<int>.empty(),
  ).retryOnError().attempt((e, st) => e.toString());
}

FxEvents<int> retryOnly() {
  return fxEvents(Stream<int>.empty()).retryOnError();
}
