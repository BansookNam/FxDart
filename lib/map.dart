import 'package:fxdart/curry.dart';

Function map = (f, Iterable iterable) {
  final list = [];
  for (final i in iterable) {
    list.add(f(i));
  }
  return list;
};
