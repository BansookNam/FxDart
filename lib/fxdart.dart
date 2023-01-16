library fxdart;

import 'add.dart';
import 'go.dart';
import 'pipe.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

void main(List<String> args) {
  //go([0, (a) => a + 1, (a) => a + 10, (a) => a + 100, print]);

  go([
    add([0, 1]),
    (a) => a + 1,
    (a) => a + 10,
    (a) => a + 100,
    print
  ]);
  // final wow = Wow();

  final f = pipe(add, [(a) => a + 1, (a) => a + 10, (a) => a + 100, print]);
  f([0, 1]);

  // final arr = [1, 2, 3, 4, 5];

  // add(int value1, int value2) => value1 + value2;
  // multiply(int value1, int value2) => value1 * value2;
}

class Wow extends Iterable implements Iterator {
  int count = -1;
  @override
  get current => count == 0 ? "3330" : "YYYYYY";

  @override
  bool moveNext() {
    count++;
    if (count == 6) {
      return false;
    }
    return true;
  }

  @override
  Iterator get iterator => this;
}
