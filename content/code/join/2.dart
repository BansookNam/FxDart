import 'package:fxdart/fxdart.dart';

void main() {
  final columns = ['id', 'name', 'email'];

  // TODO: join the columns into a single CSV header row, separated by ','.
  final header = join(' ', columns);

  print(header);
}
