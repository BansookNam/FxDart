T fold<T, E>(T initialValue, T Function(T previousValue, E element) combine,
    Iterable<E> iterable) {
  var value = initialValue;
  for (E element in iterable) {
    value = combine(value, element);
  }
  return value;
}
