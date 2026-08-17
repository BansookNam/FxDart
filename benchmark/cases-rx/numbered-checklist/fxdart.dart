import 'package:fxdart/fxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final steps = makeSteps();
  await bench(
    slug: 'numbered-checklist',
    impl: 'fxdart',
    n: n,
    run: () {
      // zipWithIndex pairs each element with its position: (index, value).
      final numbered = fx(
        steps,
      ).zipWithIndex().map((e) => '${e.$1 + 1}. ${e.$2}').toList();
      return '${numbered.length}|${numbered.first}|${numbered.last}';
    },
  );
}
