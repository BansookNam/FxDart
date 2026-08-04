import 'package:fxdart/fxdart.dart';

void main() {
  const names = ['ada', 'linus', 'grace'];
  const langs = ['analytical', 'linux', 'cobol'];
  const years = [1843, 1991, 1959];

  // Three iterables, one record per step:
  final rows = zip3(names, langs, years).toList();
  print(rows.first); // (ada, analytical, 1843)

  // Destructure with pattern matching, not $1/$2/$3:
  for (final (name, lang, year) in rows) {
    print('$name · $lang · $year');
  }

  // Like zip, it stops the moment the SHORTEST input runs out:
  print(zip3([1, 2, 3], ['a', 'b'], [true, false, true]).toList());
  // [(1, a, true), (2, b, false)]

  // zip3 has no chain method — feed its result back into fx() to keep going:
  final labels = fx(zip3(names, langs, years))
      .map((r) => '${r.$1}/${r.$3}')
      .toList();
  print(labels); // [ada/1843, linus/1991, grace/1959]
}
