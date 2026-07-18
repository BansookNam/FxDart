import 'package:fxdart/fxdart.dart';

void main() {
  final handlers = <String, Function>{
    'sum': (int a, int b) => a + b,
    'shout': (String s) => s.toUpperCase(),
  };

  final calls = [
    ('sum', [1, 2]),
    ('shout', ['hi']),
  ];

  for (final (name, args) in calls) {
    print(apply(handlers[name]!, args));
  }
  // 3
  // HI
}
