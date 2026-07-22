import 'package:fxdart/fxdart.dart';

void main() {
  final words = ['tiny', 'gigantic', 'ok', 'medium'];

  // TODO: total the lengths of only the words longer than 3 characters,
  // using ONE sumBy call after the filter (no map stage).
  final total = fx(words).filter((w) => w.length > 3).size();

  print(total); // should print: 18
}
