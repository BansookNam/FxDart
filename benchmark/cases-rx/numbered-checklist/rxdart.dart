import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final steps = makeSteps();
  await bench(
    slug: 'numbered-checklist',
    impl: 'rxdart',
    n: n,
    run: () async {
      // Streams have no indexed map — the numbering rides scan's index
      // argument with a throwaway seed and an ignored accumulator.
      final numbered = await Stream.fromIterable(steps)
          .scan<String>((_, step, i) => '${i + 1}. $step', '')
          .toList();
      return '${numbered.length}|${numbered.first}|${numbered.last}';
    },
  );
}
