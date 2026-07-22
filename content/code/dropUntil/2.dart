import 'package:fxdart/fxdart.dart';

void main() {
  final log = ['start', 'step1', 'READY', 'step2', 'step3'];

  // TODO: drop everything up to and including 'READY'
  final afterReady = fx(log).toList();

  print(afterReady);
}
