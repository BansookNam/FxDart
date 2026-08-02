import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'bracket-the-session',
    impl: 'fxdart',
    n: n,
    run: () {
      final lines = fx(events)
          .prepend('== SESSION OPEN ==')
          .append('== SESSION CLOSE ==')
          .toList();
      return '${lines.length}|${lines.first}|${lines[1]}|${lines[n]}|${lines.last}';
    },
  );
}
