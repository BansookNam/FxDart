import 'package:fxdart/fxdart.dart';

void main() {
  final ages = {'kim': 32, 'lee': 27, 'park': 41};

  // entries() yields (key, value) records — destructure them directly.
  for (final (name, age) in entries(ages)) {
    print('$name is $age');
  }

  print(toList(entries(ages))); // [(kim, 32), (lee, 27), (park, 41)]
}
