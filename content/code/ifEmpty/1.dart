import 'package:fxdart/fxdart.dart';

Iterable<String> cachedResults() {
  print('  (reading cache)');
  return ['cached-a', 'cached-b'];
}

void main() {
  final live = ['live-1', 'live-2'];

  // The fallback is a FUNCTION — it is not even called unless needed:
  print('with live results:');
  print(fx(live).ifEmpty(cachedResults).toList());
  // with live results:
  // [live-1, live-2]        ← no "(reading cache)" line: never touched

  print('with no results:');
  print(fx(<String>[]).ifEmpty(cachedResults).toList());
  // with no results:
  //   (reading cache)
  // [cached-a, cached-b]
}
