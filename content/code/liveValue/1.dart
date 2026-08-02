import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final selection = LiveValue<String>();

  // Before any add: no value, and .value throws rather than guessing.
  print(selection.hasValue); // false
  try {
    selection.value;
  } on StateError {
    print('no value yet — check hasValue first');
  }

  selection.add('row-1');
  selection.add('row-4');
  print(selection.hasValue); // true
  print(selection.value); // row-4 — a synchronous read, no subscription

  await selection.close();
  print(selection.isClosed); // true

  // Even closed, the last value still replays to a late subscriber
  // (then the stream closes).
  print(await selection.stream.toList()); // [row-4]

  try {
    selection.add('row-9');
  } on StateError {
    print('add after close throws');
  }
}
