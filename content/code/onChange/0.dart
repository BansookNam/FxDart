import 'package:fxdart/fxdart.dart';

void main() {
  var rebuilds = 0;
  final show = fxOnChange<int>((s) {
    rebuilds++;
    print('rebuild: ${s}s');
  });

  // A timer polling four times a second hands it the same second
  // several times; only a new value gets through.
  for (final elapsed in [0, 0, 0, 0, 1, 1, 1, 1, 2]) {
    show(elapsed);
  }
  print('$rebuilds rebuilds for 9 ticks'); // 3 rebuilds for 9 ticks
}
