import 'package:fxdart/fxdart.dart';

void main() {
  // A log store returns entries newest first.
  final logs = [
    ('09:41', 'ERROR', 'payment gateway timeout'),
    ('09:40', 'INFO', 'checkout started'),
    ('09:38', 'ERROR', 'payment gateway timeout'),
    ('09:31', 'ERROR', 'inventory service 503'),
    ('09:28', 'INFO', 'cache warmed'),
    ('09:17', 'ERROR', 'invalid session token'),
  ];

  // The three most recent DISTINCT error messages.
  // One callback does both jobs: a null key means "skip this element".
  final recent = takeUniqBy(
    3,
    (l) => l.$2 == 'ERROR' ? l.$3 : null,
    logs,
  );

  for (final l in recent) {
    print('${l.$1} ${l.$3}');
  }
  // 09:41 payment gateway timeout
  // 09:31 inventory service 503
  // 09:17 invalid session token

  // The same answer, written as three composable steps. This is the one to
  // reach for by default — takeUniqBy is the shape you drop to when a
  // profile says these callbacks are the cost.
  print(
    fx(logs)
        .filter((l) => l.$2 == 'ERROR')
        .uniqBy((l) => l.$3)
        .take(3)
        .map((l) => l.$1)
        .toList(),
  );
  // [09:41, 09:31, 09:17]
}
