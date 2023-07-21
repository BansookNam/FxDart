library fxdart;

import 'package:fxdart/curry.dart';
import 'package:fxdart/filter.dart';

import 'add.dart';
import 'go.dart';
import 'map.dart';
import 'pipe.dart';
import 'reduce.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

void main(List<String> args) {
  //go([0, (a) => a + 1, (a) => a + 10, (a) => a + 100, print]);

  const products = [
    {"name": "반팔티", "price": 15000},
    {"name": "긴팔티", "price": 20000},
    {"name": "핸드폰케이스", "price": 15000},
    {"name": "후드티", "price": 30000},
    {"name": "바지", "price": 25000},
  ];

  // final filteredList = filter((p) => p["price"] >= 20000, products);
  // print(filteredList);

  go([
    products,
    (products) => filter((p) => p["price"] > 24000, products),
    (products) => map((p) => p["price"], products),
    (prices) => reduce(add, prices),
    print,
  ]);
  //filter((p) => p["price"] > 24000, products);

  // go([
  //   0,
  //   (a) => a + 1,
  //   (a) => a + 10,
  //   (a) => a + 500,
  //   print,
  // ]);

  // final mult = curry((a, b) => a * b);
  // //final mult = (a, b) => a * b;

  // print(mult(5)(30));

  // final mult5 = mult(5);

  // print(mult5(30));

  // print(mult5(3));
  // print(mult5(1));
  // print(mult5(100));
  // print(mult5(3000));
  // go([
  //   add([0, 1]),
  //   (a) => a + 1,
  //   (a) => a + 10,
  //   (a) => a + 100,
  //   print
  // ]);
  // // final wow = Wow();

  // final f = pipe(add, [
  //   (a) => a + 1,
  //   (a) => a + 10,
  //   (a) => a + 100,
  //   print,
  // ]);
  // f([0, 1]);

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
