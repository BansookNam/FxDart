import 'package:fxdart/fxdart.dart';

void main() {
  final ages = [22, 17, 30];

  try {
    final validated = fx(ages)
        .map((a) =>
            throwIf<int>((n) => n < 18, (n) => ArgumentError('too young: $n'), a))
        .toArray();
    print(validated);
  } catch (e) {
    print('caught: $e'); // caught: Invalid argument(s): too young: 17
  }
}
