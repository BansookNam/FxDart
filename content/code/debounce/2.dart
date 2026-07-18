import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final saved = <int>[];

  // TODO: wrap the save function in debounce() with a 100ms wait so that
  // only the final value ('3') gets saved after the rapid calls settle.
  void save(int value) => saved.add(value);

  save(1);
  save(2);
  save(3);

  await sleep(const Duration(milliseconds: 150));
  print(saved); // currently [1, 2, 3] — should be [3]
}
