import 'package:fxdart/fxdart.dart';

void main() {
  final logs = ['info: ok', 'error: disk full', 'info: ok', 'error: timeout'];

  // TODO: use whereNot to drop the 'info: ok' lines, keeping only the errors.
  final errors = fx(logs).toList();

  print(errors);
}
