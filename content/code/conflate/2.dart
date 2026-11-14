import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final rendered = <int>[];
  Future<void> render(int v) async {
    await fxSleep(const Duration(milliseconds: 30));
    rendered.add(v);
  }

  // TODO: wrap render in fxConflate, call it for every slider value,
  // and await .idle — only the first and the last value render.
  for (final v in [1, 2, 3, 4, 5]) {
    await render(v);
  }

  print(rendered); // should print: [1, 5]
}
