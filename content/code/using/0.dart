import 'package:fxdart/fxdart.dart';

/// A stand-in for a file / socket / cursor.
class Connection {
  Connection() {
    print('  open');
  }
  Iterable<String> rows() => ['row-1', 'row-2', 'row-3'];
  void close() => print('  close');
}

void main() {
  // acquire → use → release, tied to the ITERATION, not the declaration:
  final rows = using(
    () => Connection(),
    (conn) => fx(conn.rows()).map((r) => r.toUpperCase()),
    (conn) => conn.close(),
  );

  print('pipeline built — nothing opened yet');
  print(toList(rows));
  // pipeline built — nothing opened yet
  //   open
  //   close
  // [ROW-1, ROW-2, ROW-3]

  // Iterating again brackets again — one open/close per iteration:
  toList(rows);
  //   open
  //   close
}
