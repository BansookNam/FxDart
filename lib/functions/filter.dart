Function filter = (f, Iterable iterable) {
  final list = [];
  for (final i in iterable) {
    if (f(i)) list.add(i);
  }
  return list;
};
