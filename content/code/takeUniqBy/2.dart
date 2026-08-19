import 'package:fxdart/fxdart.dart';

void main() {
  final visits = [
    (user: 'ana', page: '/pricing'),
    (user: 'bo', page: '/'),
    (user: 'ana', page: '/docs'),
    (user: 'cy', page: '/pricing'),
    (user: 'bo', page: '/pricing'),
    (user: 'dee', page: '/docs'),
  ];

  // TODO: the first three DISTINCT users who landed on '/pricing'.
  // Hint: one callback — return the user when the page matches, null
  // otherwise. Remember the argument order: count, key, iterable.
  final firstPricingUsers = takeUniqBy(
    3,
    (v) => v.user, // ← almost: this ignores the page. Skip the others.
    visits,
  );

  print(firstPricingUsers.map((v) => v.user).toList());
  // Expected once solved:
  // [ana, cy, bo]
}
