import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  final result = await resolveProps({
    'a': Future.value(1),
    'b': 2,
    'c': Future.value(3),
  });
  print(result); // {a: 1, b: 2, c: 3}
}
