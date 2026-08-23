import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // A search box: four keystrokes in one burst, then one more after quiet.
  // The selector is a 50ms future — the same idea as debounce(Duration),
  // except the quiet window is a stream per value, not a clock.
  final keys = StreamController<String>();
  final searches = fxEvents(keys.stream)
      .debounceOn((_) => Stream<void>.fromFuture(
            Future<void>.delayed(const Duration(milliseconds: 50)),
          ))
      .toList();

  keys
    ..add('h')
    ..add('he')
    ..add('hel')
    ..add('hello');
  await Future<void>.delayed(const Duration(milliseconds: 80));
  keys.add('hello!');
  await keys.close();

  print(await searches); // [hello, hello!]
  // Each newer keystroke aborted the previous inner. The first next of
  // the surviving inner emitted 'hello'; 'hello!' was still pending when
  // the source closed and was flushed, matching Duration debounce.
}
