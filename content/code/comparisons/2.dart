import 'package:fxdart/fxdart.dart';

void main() {
  final ages = [15, 22, 8, 30, 17];

  // TODO: keep only the ages that are gte 18 (adults)
  final adults = fx(ages).filter((a) => gte(a, 18)).toArray();

  print(adults); // [22, 30]
}
