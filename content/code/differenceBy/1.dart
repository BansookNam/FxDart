import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();

  // The concurrency marker applies to iterable2, as with differenceAsync.
  final blocked = toAsync([
    {'id': 2},
  ]);
  final users = fx([
    {'id': 1, 'name': 'kim'},
    {'id': 2, 'name': 'lee'},
    {'id': 3, 'name': 'park'},
  ]).toAsync().map((u) => delay(Duration(milliseconds: 100), u)).concurrent(3);

  final allowed =
      await fxAsync(differenceByAsync((u) => u['id'], blocked, users)).toArray();

  print(allowed); // [{id: 1, name: kim}, {id: 3, name: park}]
  print('took ${sw.elapsedMilliseconds}ms'); // ~100ms
}
