import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final clicks = <String>[];

  // TODO: wrap this in throttle() with a 100ms wait so rapid clicks only
  // register once per 100ms window (leading + trailing).
  void onClick(String label) => clicks.add(label);

  onClick('click1');
  onClick('click2');
  onClick('click3');

  await sleep(const Duration(milliseconds: 150));
  print(clicks); // currently [click1, click2, click3] — want just 2 calls
}
