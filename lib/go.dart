import 'reduce.dart';

go(List args) {
  reduce((a, f) => f(a), args);
}
