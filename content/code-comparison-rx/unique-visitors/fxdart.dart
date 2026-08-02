import 'package:fxdart/fxdart.dart';

// Today's visit log — repeat visits by the same account.
const visits = [
  (user: 'ana', at: '09:02'),
  (user: 'ben', at: '09:15'),
  (user: 'ana', at: '09:40'),
  (user: 'cho', at: '10:05'),
  (user: 'ben', at: '10:22'),
  (user: 'dee', at: '11:01'),
  (user: 'cho', at: '11:30'),
  (user: 'ana', at: '11:48'),
];

void main() {
  // uniqBy keeps the first element per key — "same visitor" is one
  // key function, and the record's user field is the key.
  final firstSeen = fx(visits)
      .uniqBy((v) => v.user)
      .map((v) => '${v.user} — first visit ${v.at}')
      .toList();

  firstSeen.forEach(print);
  print('${firstSeen.length} unique visitors in ${visits.length} visits');
}
