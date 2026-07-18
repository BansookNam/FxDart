import 'package:fxdart/fxdart.dart';

void main() {
  final log = ['start', 'step1', 'step2', 'ERROR', 'step3'];

  // TODO: take the log lines up to and including the first 'ERROR'
  final untilError = fx(log).toArray();

  print(untilError);
}
