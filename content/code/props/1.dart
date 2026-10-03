import 'package:fxdart/fxdart.dart';

void main() {
  final coord = {'lat': 37.5, 'lng': 127.0};

  final [lat, lng] = fxProps(['lat', 'lng'], coord);
  print('lat=$lat lng=$lng'); // lat=37.5 lng=127.0
}
