import 'package:fxdart/fxdart.dart';

void main() {
  final env = {'API_KEY': 'x', 'API_URL': 'y', 'DEBUG': 'true'};

  final apiOnly = pickBy((e) => e.$1.startsWith('API_'), env);
  print(apiOnly); // {API_KEY: x, API_URL: y}
}
