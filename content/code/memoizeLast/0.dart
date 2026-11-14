import 'package:fxdart/fxdart.dart';

class Tank {
  final List<int> decor;
  const Tank(this.decor);
  Tank withDecor(int d) => Tank([...decor, d]);
}

void main() {
  var runs = 0;
  final beauty = fxMemoizeLast((Tank t) {
    runs++;
    return fx(t.decor).sum();
  });

  var tank = const Tank([3, 4]);
  print(beauty(tank)); // 7
  print(beauty(tank)); // 7  (same instance: from the slot)
  print(beauty(tank)); // 7

  tank = tank.withDecor(5); // a new state is a new instance
  print(beauty(tank)); // 12
  print('ran $runs times'); // ran 2 times
}
