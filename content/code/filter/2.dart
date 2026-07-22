import 'package:fxdart/fxdart.dart';

void main() {
  final ages = [12, 19, 25, 8, 40, 17];

  // TODO: use where to keep only ages 18 and over.
  final adults = fx(ages).toList();

  print(adults);
}
