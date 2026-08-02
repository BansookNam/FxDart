import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final temp = LiveValue.seeded(21.0);

  // An early subscriber: gets the seed immediately, then every update.
  final earlySeen = <double>[];
  temp.stream.listen(earlySeen.add);

  temp.add(21.5);
  temp.add(22.0);

  // A LATE subscriber — arriving after all those updates.
  final lateSeen = <double>[];
  temp.stream.listen(lateSeen.add);

  temp.add(22.5);
  await temp.close();
  await Future<void>.delayed(Duration.zero);

  print('early: $earlySeen'); // [21.0, 21.5, 22.0, 22.5]
  print('late:  $lateSeen'); // [22.0, 22.5]
  // The late subscriber missed nothing that matters: it got the LATEST
  // value first (22.0), then the live updates — no gap, no stale start.
}
