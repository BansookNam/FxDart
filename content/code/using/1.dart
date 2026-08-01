import 'package:fxdart/fxdart.dart';

class Cursor {
  var closed = false;
  void close() {
    closed = true;
    print('cursor closed (before the error escaped)');
  }
}

Future<int> parse(String raw) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return int.parse(raw); // 'oops' throws
}

void main() async {
  final cursor = Cursor();

  // release runs BEFORE the error propagates — exactly once:
  try {
    await toListAsync(usingAsync(
      () async => cursor,
      (c) => mapAsync(parse, toAsync(['1', '2', 'oops', '4'])),
      (c) async => c.close(),
    ));
  } catch (e) {
    print('caught: $e');
    print('cursor.closed == ${cursor.closed}');
  }
  // cursor closed (before the error escaped)
  // caught: FormatException: ...
  // cursor.closed == true
}
