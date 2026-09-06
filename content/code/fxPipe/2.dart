import 'package:fxdart/fxdart.dart';

class Row {
  Row(this.sku, this.qty, this.price);
  final String sku;
  final int qty;
  final double price;
}

Row parse(String line) {
  final p = line.split(',');
  return Row(p[0], int.parse(p[1]), double.parse(p[2]));
}

Row normalise(Row r) => Row(r.sku.toUpperCase(), r.qty, r.price);

double score(Row r) => r.qty * r.price;

void main() {
  final lines = ['aa,2,1.5', 'bb,10,0.4', 'cc,3,2.0'];

  // TODO: compose parse → normalise → score and keep scores >= 4.
  final top = fx(lines)
      .map(fxPipe3(parse, normalise, score))
      .filter((s) => s >= 4)
      .toList();

  print(top); // [4.0, 6.0]
}
