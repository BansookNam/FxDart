import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  await bench(
    slug: 'bracket-the-session',
    impl: 'rxdart',
    n: n,
    run: () async {
      final lines = await Stream.fromIterable(events)
          .startWith('== SESSION OPEN ==')
          .endWith('== SESSION CLOSE ==')
          .toList();
      return '${lines.length}|${lines.first}|${lines[1]}|${lines[n]}|${lines.last}';
    },
  );
}
