Future<int> fetch(int id) async => id;

Future<void> mapped() async {
  // expect_lint: avoid_unbounded_future_wait
  await Future.wait([1, 2, 3].map(fetch));
}

Future<void> forElement() async {
  // expect_lint: avoid_unbounded_future_wait
  await Future.wait([
    for (final id in [1, 2, 3]) fetch(id),
  ]);
}

Future<void> mappedThenToList() async {
  // expect_lint: avoid_unbounded_future_wait
  await Future.wait([1, 2, 3].map(fetch).toList());
}

Future<void> knownSmall() async {
  final a = fetch(1);
  final b = fetch(2);
  await Future.wait([a, b]);
}

Future<void> identifier() async {
  final jobs = [fetch(1), fetch(2)];
  await Future.wait(jobs);
}
