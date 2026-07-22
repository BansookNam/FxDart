import 'package:fxdart/fxdart.dart';

void main() {
  final books = [
    (title: 'A', pages: 120, read: true),
    (title: 'B', pages: 900, read: false),
    (title: 'C', pages: 240, read: true),
  ];

  // TODO: average page count of only the books you have READ,
  // using ONE averageBy call after the filter (no map stage).
  final avg = fx(books).filter((b) => b.read).size();

  print(avg); // should print: 180.0
}
