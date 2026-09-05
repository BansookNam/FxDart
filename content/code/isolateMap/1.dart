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

  final layered = fx(lines).map(parse).map(normalise).map(score).toList();
  final fused = fx(lines).map(isolateMap3(parse, normalise, score)).toList();

  print(layered); // [3.0, 4.0, 6.0]
  print(fused); // [3.0, 4.0, 6.0]
  print(layered.toString() == fused.toString()); // true
}
