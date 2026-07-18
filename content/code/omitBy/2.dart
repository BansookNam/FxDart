import 'package:fxdart/fxdart.dart';

void main() {
  final flags = {'featureA': true, 'featureB': false, 'featureC': true};

  // TODO: use omitBy to drop entries whose value is false
  final enabledOnly = flags;

  print(enabledOnly);
}
