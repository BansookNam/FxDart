import 'package:fxdart/fxdart.dart';

void main() {
  final centsAmounts = [1050, 2200, 375];

  // TODO: use mapEffect to log 'billing $<dollars>' for each amount while
  // converting cents to dollars (a double).
  final dollars = fx(centsAmounts).map((c) => c / 100).toList();

  print(dollars);
}
