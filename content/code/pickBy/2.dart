import 'package:fxdart/fxdart.dart';

void main() {
  final flags = {'featureA': true, 'featureB': false, 'featureC': true};

  // TODO: use pickBy to keep only entries whose value is true
  final enabledOnly = flags;

  print(enabledOnly);
}
