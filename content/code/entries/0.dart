import 'package:fxdart/fxdart.dart';

void main() {
  final ages = {'kim': 32, 'lee': 27, 'park': 41};

  // entries() yields (key, value) records — destructure them directly.
  for (final (name, age) in fxEntries(ages)) {
    print('$name is $age');
  }

  print(fxToList(fxEntries(ages))); // [(kim, 32), (lee, 27), (park, 41)]
}
