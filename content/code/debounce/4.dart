import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final saved = <int>[];

  // maxWait: a drag that never pauses still saves every 120ms.
  final save = fxDebounce<int>(
    saved.add,
    const Duration(milliseconds: 50),
    maxWait: const Duration(milliseconds: 120),
  );
  for (var v = 1; v <= 10; v++) {
    save(v);
    await fxSleep(const Duration(milliseconds: 30));
  }
  print('during the drag: ${saved.isNotEmpty}'); // during the drag: true

  // flush(): the app is going to the background — save now.
  save(99);
  print(save.isPending); // true
  save.flush();
  print(save.isPending); // false
  print(saved.last); // 99
}
