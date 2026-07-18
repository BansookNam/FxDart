import 'package:fxdart/fxdart.dart';

void main() {
  final config = {'host': 'localhost', 'port': 8080, 'debug': true};

  // TODO: use omit to drop the 'debug' key
  final publicConfig = config;

  print(publicConfig);
}
