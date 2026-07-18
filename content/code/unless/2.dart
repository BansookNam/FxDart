import 'package:fxdart/fxdart.dart';

void main() {
  final tags = ['news', '', 'sports', ''];

  // TODO: use `unless` to fill in 'general' for any empty tag
  final filled = fx(tags)
      .map((t) => unless((s) => s.isNotEmpty, (_) => 'general', t))
      .toArray();

  print(filled); // [news, general, sports, general]
}
