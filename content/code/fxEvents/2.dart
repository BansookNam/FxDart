import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A raw feed of readings, some of them junk (negative = sensor glitch).
  final readings = Stream.fromIterable([21, -1, 22, -3, 24]);

  // TODO: wrap the stream with fxEvents(...), then
  //   .where(...)  — drop the negative glitches
  //   .map(...)    — format each reading as '<value>°C'
  //   .toList()    — collect the results
  final out = await readings.toList();

  print(out);
  // currently [21, -1, 22, -3, 24] — want [21°C, 22°C, 24°C]
}
