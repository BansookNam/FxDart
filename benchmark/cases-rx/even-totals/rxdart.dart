import 'package:rxdart/rxdart.dart';

import '../../harness.dart';
import 'data.dart';

Future<void> main() async {
  final amounts = makeAmounts();
  await bench(
    slug: 'even-totals',
    impl: 'rxdart',
    n: n,
    run: () async {
      final total = await Stream.fromIterable(amounts)
          .whereNotNull()
          .where((a) => a.isEven)
          .fold<int>(0, (sum, a) => sum + a);
      return total;
    },
  );
}
