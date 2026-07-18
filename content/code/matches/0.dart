import 'package:fxdart/fxdart.dart';

void main() {
  final isClick = matches({'type': 'click'});

  print(isClick({'type': 'click', 'x': 1})); // true
  print(isClick({'type': 'scroll'}));        // false
}
