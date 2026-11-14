import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A slow seek: 50ms each. The scrubber moves faster than that.
  final seek = fxConflate<int>((ms) async {
    print('seek to $ms');
    await fxSleep(const Duration(milliseconds: 50));
  });

  for (final ms in [0, 100, 200, 300, 400]) {
    seek(ms); // 0 starts now; 100–300 are replaced by 400
  }
  await seek.idle;
  // seek to 0
  // seek to 400
}
