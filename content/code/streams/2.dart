import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final source = Stream.fromIterable([5, 12, 8, 20, 3]);

  // TODO: use fxStream(source) and .filter(...) to keep only values >= 10,
  // then .toArray() to collect them.
  final result = await fxStream(source).toArray();

  print(result); // currently [5, 12, 8, 20, 3] — should be [12, 20]
}
