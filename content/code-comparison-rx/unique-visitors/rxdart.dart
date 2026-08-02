import 'package:rxdart/rxdart.dart';

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

Future<void> main() async {
  // distinctUnique dedups across the WHOLE stream (plain Stream.distinct
  // is adjacent-only); "same visitor" is spelled as equals + hashCode.
  final firstSeen = await Stream.fromIterable(visits)
      .distinctUnique(
          equals: (a, b) => a.user == b.user, hashCode: (v) => v.user.hashCode)
      .map((v) => '${v.user} — first visit ${v.at}')
      .toList();

  firstSeen.forEach(print);
  print('${firstSeen.length} unique visitors in ${visits.length} visits');
}
