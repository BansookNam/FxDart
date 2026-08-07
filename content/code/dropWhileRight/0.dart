import 'package:fxdart/fxdart.dart';

void main() {
  // Trims the trailing run, keeps everything before it.
  print(dropWhileRight((a) => a == 0, [1, 2, 0, 0])); // (1, 2)

  // An interior run is not a suffix, so it stays.
  print(dropWhileRight((a) => a == 0, [1, 0, 0, 2])); // (1, 0, 0, 2)

  final trimmed =
      fx(['log', 'log', '', '']).dropWhileRight((s) => s.isEmpty).toList();
  print(trimmed); // [log, log]
}
