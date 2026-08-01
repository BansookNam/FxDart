import 'package:fxdart/fxdart.dart';

void main() {
  final releases = [
    (version: '0.5.0', date: DateTime(2026, 6, 10)),
    (version: '0.7.0', date: DateTime(2026, 7, 29)),
    (version: '0.6.0', date: DateTime(2026, 7, 20)),
  ];

  // TODO: newest release first — one sortByDesc call on the date.
  final latest = releases;

  print(latest.first.version); // should print: 0.7.0
}
