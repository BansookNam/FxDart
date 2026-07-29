import 'package:fxdart/fxdart.dart';

Either<int, String> fetchPage(String path) =>
    either((r) => path == '/home' ? '<home>' : r.raise(404));

void main() {
  // recover: handle a raised error in a nested scope — the block keeps going.
  final n = either<String, int>((r) {
    final v = r.recover((r2) => r2.raise('boom'), (e) => -1);
    return v * 10;
  });
  print(n); // Right(-10)

  // withError: adapt a DIFFERENT error type (int) into this scope's String.
  final page = either<String, String>((r) => r.withError(
      (int code) => 'http $code', (r2) => r2.bind(fetchPage('/missing'))));
  print(page); // Left(http 404)

  // r.raise short-circuits directly; bindAll unwraps a whole list at once.
  final all = either<String, List<String>>(
      (r) => r.bindAll([fetchPage('/home').mapLeft((c) => 'http $c')]));
  print(all); // Right([<home>])
}
