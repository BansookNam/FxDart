import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

(String, int) parse(String line) {
  final parts = line.split('=');
  final value = int.tryParse(parts[1]);
  if (value == null) throw FormatException(line);
  return (parts[0], value);
}

(String, int)? tryParse(String line) {
  try {
    return parse(line);
  } on FormatException {
    return null;
  }
}

Future<void> main() async {
  final lines = makeLines();
  await bench(
    slug: 'audit-with-outcomes',
    impl: 'fxdart',
    n: n,
    run: () {
      // The throw lands one try/catch away from being a plain value again,
      // and a single pass splits outcomes into the two lists the report needs.
      final (ok, failed) = fx(lines).map(tryParse).partition((r) => r != null);

      var okCount = 0, valueSum = 0;
      for (final o in ok.whereType<(String, int)>()) {
        okCount++;
        valueSum += o.$2;
      }
      return 'ok=$okCount|sum=$valueSum|failures=${failed.length}';
    },
  );
}
