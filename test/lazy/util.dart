import 'package:fxdart/fxdart.dart';

/// Wraps an [FxAsyncIterable] so that every `.iterator` access returns the
/// same underlying iterator — mirroring FxTS `toAsync`, whose result is both
/// an iterable and its own (stateful) iterator. Lets a test consume part of
/// a source through a pipeline and then observe where the source stopped.
class SharedAsyncIterable<T> implements FxAsyncIterable<T> {
  final FxAsyncIterator<T> _iterator;

  SharedAsyncIterable(FxAsyncIterable<T> source) : _iterator = source.iterator;

  @override
  FxAsyncIterator<T> get iterator => _iterator;
}

/// An infinite iterable 0, 1, 2, ... — stand-in for FxTS `range(Infinity)`.
Iterable<int> naturals() sync* {
  var i = 0;
  while (true) {
    yield i++;
  }
}
