import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final requests = {
    'user': Future.value('kim'),
    'role': Future.value('admin'),
  };

  // TODO: use resolveProps to await every value in `requests`
  final Map<String, String> resolved = {};

  print(resolved);
}
