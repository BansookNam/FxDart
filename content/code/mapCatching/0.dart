import 'package:fxdart/fxdart.dart';

void main() {
  final raw = ['12', '7', 'x9', '40', ''];

  // A plain map ends at the first bad row:
  try {
    fx(raw).map(int.parse).toList();
  } on FormatException catch (e) {
    print('map stopped: ${e.message}'); // map stopped: Invalid radix-10 number
  }

  // mapCatching recovers each failure in place and keeps going:
  final parsed = fx(raw).mapCatching(int.parse, (e, st) => -1).toList();
  print(parsed); // [12, 7, -1, 40, -1]

  // The handler sees the error itself, so it can be turned into data:
  final labels = fxMapCatching(
    (String s) => 'ok ${int.parse(s)}',
    (e, st) => 'bad (${e.runtimeType})',
    raw,
  );
  print(labels.toList());
  // [ok 12, ok 7, bad (FormatException), ok 40, bad (FormatException)]
}
