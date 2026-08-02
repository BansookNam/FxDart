import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Application state: the current zoom level.
  final zoom = LiveValue.seeded(1.0);

  // TODO: .live is an FxEvents chain — map the zoom into a percent label,
  // then use the plain-Stream escape hatch to take the first three:
  //   zoom.live.map((z) => '${(z * 100).round()}%').stream.take(3).toList()
  final labels = zoom.stream.take(3).toList();

  zoom.add(1.25);
  zoom.add(1.5);

  print(await labels);
  // currently [1.0, 1.25, 1.5] — want [100%, 125%, 150%]
  await zoom.close();
}
